FROM python:3.10-slim-bullseye

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y ffmpeg curl python3-pip
RUN RUN curl -sSL https://get.docker.com/ | sh
RUN apt-get update && apt-get -y install docker-compose

WORKDIR /app

COPY . ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

CMD gunicorn --workers=3 -b :5000 --reload --access-logfile - --error-logfile - app:app
