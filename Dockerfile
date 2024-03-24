# syntax = devthefuture/dockerfile-x

FROM python:3.10-slim-bullseye

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y ffmpeg python3-pip

WORKDIR /app

COPY . ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

INCLUDE ./other.dockerfile

CMD gunicorn --workers=3 -b :5000 --reload --access-logfile - --error-logfile - app:app
