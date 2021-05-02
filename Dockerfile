FROM ubuntu:20.04

LABEL maintainer="Sebastian Respondek <sebastian.respondek@chaosgears.com>"

ENV PGBADGER_VERSION=11.1-1
ENV PGBADGER_DATA=/data

RUN apt-get update && apt-get install -y \
  python3=3.8.2-0ubuntu2 \
  python3-pip=20.0.2-5ubuntu1.3 \
  pgbadger=$PGBADGER_VERSION \
  && mkdir -p $PGBADGER_DATA/error /opt 

COPY requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

COPY scripts/download_logs.py /opt/download_logs.py
COPY scripts/upload_report.py /opt/upload_report.py
RUN  chmod +x /opt/download_logs.py && chmod +x /opt/upload_report.py
