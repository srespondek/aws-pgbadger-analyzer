import os

import boto3
import datetime
import logging

import sys

ENVIRONMENT = os.environ['ENVIRONMENT']
TENANT = os.environ['TENANT']
BUCKET_NAME = os.environ['BUCKET_NAME']


class InitClientException(Exception):
    pass


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


def get_today_date():
    return datetime.datetime.now().replace(second=0, microsecond=0, minute=0, hour=0).strftime("%Y-%m-%d")


def get_client():
    try:
        client = boto3.client('s3')
        return client

    except Exception as exc:
        logger.exception(exc)
        raise InitClientException


def save_report_to_s3(client):
    todays_date = get_today_date()
    with open("/data/error/out.html", "rb") as fh:
        client.upload_fileobj(fh, f"{BUCKET_NAME}", f"{TENANT}/{todays_date}/report.html")


def env_logging():
    logger.info(f'ENVIRONMENT: {ENVIRONMENT}')
    logger.info(f'TENANT: {TENANT}')
    logger.info(f'BUCKET_NAME: {BUCKET_NAME}')


def main():
    env_logging()
    client = get_client()
    save_report_to_s3(client)


if __name__ == "__main__":
    main()
