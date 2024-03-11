FROM nginx:mainline-alpine-slim
EXPOSE 5000
USER root
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y ffmpeg python3 python3-pip

COPY . ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

CMD gunicorn --workers=3 -b 0.0.0.0:5000 --reload --access-logfile - --error-logfile - app:app
