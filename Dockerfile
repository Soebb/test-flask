FROM python:3.10-slim-bullseye

WORKDIR /app

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y ffmpeg

COPY . ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

RUN cd /videos && python -m http.server 0.0.0.0 5000 && cd ..

EXPOSE 5000
CMD gunicorn --workers=3 -b 0.0.0.0:5000 --reload --access-logfile - --error-logfile - app:app
