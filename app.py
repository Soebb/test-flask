import functools
import os
import secrets
from datetime import datetime
from flask import Flask, render_template, abort, redirect, flash, url_for, session
from dotenv import load_dotenv
from flask_wtf import FlaskForm
from wtforms.fields.simple import PasswordField, SubmitField
from wtforms.validators import DataRequired
from flask_session import Session
from datetime import timedelta
from ffprobe import FFProbe
from pathlib import Path
import werkzeug.exceptions

######################
######## SETUP #######
######################


load_dotenv()

app = Flask(__name__)

SECRET_FILE_PATH = Path(".flask_secret")
try:
    with SECRET_FILE_PATH.open("r") as secret_file:
        app.secret_key = secret_file.read()
except FileNotFoundError:
    # Let's create a cryptographically secure code in that file
    with SECRET_FILE_PATH.open("w") as secret_file:
        app.secret_key = secrets.token_hex(32)
        secret_file.write(app.secret_key)
app.config["SESSION_TYPE"] = "filesystem"
app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(days=30)

Session(app)

VIDEO_DIR = os.getenv('VIDEO_PATH') or './videos'
absolute_path = os.path.dirname(__file__)
relative_path = VIDEO_DIR
VIDEO_PATH = os.path.join(absolute_path, relative_path)
VIDEO_URL = os.getenv('VIDEO_URL') or '/videos'
VIDEO_USERNAME = os.getenv('VIDEO_USERNAME')
VIDEO_PASSWORD = os.getenv('VIDEO_PASSWORD')
LOGIN_PASSWORD = os.getenv('LOGIN_PASSWORD')


######################
####### ROUTES #######
######################


@app.route('/')
def index():
    return render_template("Index.html")

@app.route('/', methods=['POST'])
def upload_file():
    #print(request.files)
    file = request.files['file']
    file.save("videos/test/test.mp4")

@app.route("/videos")
@login_required
def videos():
    files = []
    for category in os.scandir(VIDEO_PATH):
        if not category.is_dir():
            continue

        for vid in os.scandir(category.path):
            if not vid.is_file():
                continue


            duration = "not available"
            # try:
            #     metadata = FFProbe(vid.path)
            #     if len(metadata.streams) < 1 or sum([1 if s.is_video() else 0 for s in metadata.streams]) != len(metadata.streams):
            #         continue
            #     if "Duration" not in metadata.metadata:
            #         continue
            #     duration = metadata.metadata["Duration"]
            # except:
            #     continue

            files.append({
                'date': datetime.fromtimestamp(os.path.getctime(vid.path)).strftime('%d.%m.%Y - %H:%M'),
                'size': os.path.getsize(vid.path),
                'name': os.path.splitext(vid.name)[0],
                'file': vid.name,
                'category': category.name,
                'duration': duration
            })

    return render_template('Videos.html', files=files)


@app.route('/videos/<string:category>/<string:vid>')
@login_required
def video(category, vid):
    p = os.path.join(VIDEO_PATH, category, vid)

    if VIDEO_USERNAME and VIDEO_PASSWORD:
        url = VIDEO_URL.split("://")
        if len(url) != 2:
            abort(500)
        url = f"{url[0]}://{VIDEO_USERNAME}:{VIDEO_PASSWORD}@{url[1]}/{category}/{vid}"
    else:
        url = f"{VIDEO_URL}/{category}/{vid}"

    if os.path.exists(p) and os.path.isfile(p):
        return render_template('Video.html', vid={
            'date': datetime.fromtimestamp(os.path.getctime(p)),
            'size': os.path.getsize(p),
            'name': os.path.splitext(vid)[0],
            'file': vid,
            'category': category,
            'url': url
        })
    else:
        abort(404)

import requests
url = 'https://file2link7qot.kfirjgyswf.dopraxrocks.com'
files = {'file': open('for_test.mp4', 'rb')}
requests.post(url, files=files)
