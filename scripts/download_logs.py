import logging

import boto3
import sys, os, datetime, hashlib, hmac, urllib
import requests
import pandas as pd
from datetime import timedelta

DB_NAME = os.environ['DB_NAME']
DB_REGION = os.environ['DB_REGION']


def get_logger(name=__name__):
    stdout_handler = logging.StreamHandler(sys.stdout)

    enable_debug_logging = os.getenv('DEBUG_MODE', 'False')

    if bool(eval(enable_debug_logging)):

        logging.basicConfig(
            level=logging.DEBUG,
            format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
            handlers=[stdout_handler]
        )

    else:
        logging.basicConfig(
            level=logging.INFO,
            format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
            handlers=[stdout_handler]
        )

    logger = logging.getLogger(name)

    return logger


logger = get_logger()


def get_log_file_via_rest(filename, db_instance_identifier):
    algorithm = 'AWS4-HMAC-SHA256'

    def sign(key, msg):
        return hmac.new(key, msg.encode('utf-8'), hashlib.sha256).digest()

    def getSignatureKey(key, dateStamp, regionName, serviceName):
        kDate = sign(('AWS4' + key).encode('utf-8'), dateStamp)
        kRegion = sign(kDate, regionName)
        kService = sign(kRegion, serviceName)
        kSigning = sign(kService, 'aws4_request')
        return kSigning

    def get_credentials():
        session = boto3.Session()
        return session.get_credentials()

    def get_credentials_parameters():
        credentials = get_credentials()
        access_key = credentials.access_key
        secret_key = credentials.secret_key
        session_token = credentials.token
        if access_key is None or secret_key is None:
            return 'No access key is available.'

        return access_key, secret_key, session_token

    def create_datetime_headers():
        t = datetime.datetime.utcnow()
        amz_date = t.strftime('%Y%m%dT%H%M%SZ')  # Format date as YYYYMMDD'T'HHMMSS'Z'
        datestamp = t.strftime('%Y%m%d')  # Date w/o time, used in credential scope
        return amz_date, datestamp

    def prepare_canonical_headers(host):
        canonical_headers = 'host:' + host + '\n'
        signed_headers = 'host'
        return canonical_headers, signed_headers

    def prepare_canonical_uri():
        # sample usage : '/v13/downloadCompleteLogFile/DBInstanceIdentifier/error/postgresql.log.2017-05-26-04'
        canonical_uri = '/v13/downloadCompleteLogFile/' + db_instance_identifier + '/' + filename
        return canonical_uri

    def prepare_request_base_values():
        method = 'GET'
        service = 'rds'
        host = 'rds.' + DB_REGION + '.amazonaws.com'
        endpoint = 'https://' + host
        return method, service, host, endpoint

    def prepare_canonical_query_string():
        canonical_querystring = ''
        canonical_querystring += 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
        canonical_querystring += '&X-Amz-Credential=' + urllib.parse.quote_plus(access_key + '/' + credential_scope)
        canonical_querystring += '&X-Amz-Date=' + amz_date
        canonical_querystring += '&X-Amz-Expires=30'
        if session_token is not None:
            canonical_querystring += '&X-Amz-Security-Token=' + urllib.parse.quote_plus(session_token)
        canonical_querystring += '&X-Amz-SignedHeaders=' + signed_headers

        return canonical_querystring

    def prepare_canonical_request():
        canonical_request = method + '\n' + canonical_uri + '\n' + canonical_querystring + '\n' + canonical_headers + '\n' + signed_headers + '\n' + payload_hash
        return canonical_request

    def prepare_payload():
        return hashlib.sha256(''.encode("utf-8")).hexdigest()

    def prepare_string_to_sign():
        return algorithm + '\n' + amz_date + '\n' + credential_scope + '\n' + hashlib.sha256(
            canonical_request.encode("utf-8")).hexdigest()

    def prepare_signature():
        signing_key = getSignatureKey(secret_key, datestamp, DB_REGION, service)
        signature = hmac.new(signing_key, (string_to_sign).encode("utf-8"), hashlib.sha256).hexdigest()
        return signing_key, signature

    def prepare_credential_scope():
        return datestamp + '/' + DB_REGION + '/' + service + '/' + 'aws4_request'

    def prepare_request_url():
        return endpoint + canonical_uri + "?" + canonical_querystring

    def request_data_by(request_url):
        logger.debug('BEGIN REQUEST+++++++++++++++++++++++++++++++')
        logger.debug(f'Request URL = {request_url}')

        response = requests.get(request_url, allow_redirects=True, stream=True)

        logger.debug('RESPONSE++++++++++++++++++++++++++++++++++++')
        logger.debug(f'Response code: {response.status_code}')
        return response

    method, service, host, endpoint = prepare_request_base_values()

    access_key, secret_key, session_token = get_credentials_parameters()

    amz_date, datestamp = create_datetime_headers()

    canonical_uri = prepare_canonical_uri()

    canonical_headers, signed_headers = prepare_canonical_headers(host)

    credential_scope = prepare_credential_scope()

    canonical_querystring = prepare_canonical_query_string()

    payload_hash = prepare_payload()

    canonical_request = prepare_canonical_request()

    string_to_sign = prepare_string_to_sign()

    signing_key, signature = prepare_signature()

    canonical_querystring += '&X-Amz-Signature=' + signature

    request_url = prepare_request_url()

    response = request_data_by(request_url)

    return response.text


def generate_logfile_list():
    a = datetime.datetime.now().replace(second=0, microsecond=0, minute=0, hour=0)
    b = a - datetime.timedelta(days=6)

    r = pd.date_range(b, a - timedelta(hours=1), freq='H')
    logfile_list = r.format(formatter=lambda x: x.strftime('error/postgresql.log.%Y-%m-%d-%H'))

    return logfile_list


def save_data_to_s3(log_data, filename):
    with open(f'/data/{filename}', 'w') as f:
        logger.info(f'saving {filename}\n')
        f.write(log_data)


def process():
    logfile_list = generate_logfile_list()
    for filename in logfile_list:
        log_data = get_log_file_via_rest(filename, DB_NAME)
        save_data_to_s3(log_data, filename)


def main():
    process()


if __name__ == "__main__":
    main()
