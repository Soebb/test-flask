FROM nginx:mainline-alpine-slim
EXPOSE 5000
USER root
COPY nginx.conf /etc/nginx/nginx.conf

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
WORKDIR /app

COPY . ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

CMD gunicorn --workers=3 -b 0.0.0.0:5000 --reload --access-logfile - --error-logfile - app:app
