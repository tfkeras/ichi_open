# -*- coding: utf-8 -*-
import os
import urllib
from flask import Flask, render_template, make_response, abort, request
from google.appengine.api import urlfetch
import cloudstorage as gcs

app = Flask(__name__)
# メモ
# パッケージのインストール方法
# pip install -t lib -r requirements.txt

hostname = "ichiwear.jp"
bucket_name = "ichiwearjp.appspot.com"

def is_dev():
    "開発モードならばTrueを返却する"
    server_software = os.getenv('SERVER_SOFTWARE', '')
    if server_software.startswith("Development"):
        return True
    else:
        return False

@app.route("/")
def index():
    "トップページ"
    return render_template('index.html',
        version=1,station_id=0,hostname=hostname)

@app.route("/<int:id>")
def station(id):
    "個別駅ページ"
    if(id < 1):
        abort(404)
    return render_template('index.html',
        version=1,station_id=id,hostname=hostname)


@app.route("/station/<int:id>")
def station_json(id):
    try:
        gcs_file = gcs.open("/%s/json/%07d.json" % (bucket_name,id));
        body = gcs_file.read()
        gcs_file.close()
        res = make_response(body)
        res.headers['Content-Type'] = 'application/json'
        res.headers['cache-control'] = 'public, max-age=3600'
        return res
    except gcs.errors.NotFoundError:
        # 見つからないケース
        abort(404)

@app.route("/twitter_card_image/<int:id>")
def station_image(id):
    try:
        gcs_file = gcs.open("/%s/image/%07d.png" % (bucket_name,id));
        body = gcs_file.read()
        gcs_file.close()
        res = make_response(body)
        res.headers['Content-Type'] = 'image/png'
        res.headers['cache-control'] = 'public, max-age=3600'
        return res
    except gcs.errors.NotFoundError:
        # 見つからないケース
        abort(404)


@app.route("/guide.html")
def guide():
    return render_template('guide.html',version=1)

@app.route("/privacy.html")
def privacy():
    return render_template('privacy.html',version=1)

@app.route("/upload/<string:path>",methods=['POST'])
def setup(path):
    "gcsにファイルをアップロードする。ローカルサーバーでのみ使える"
    # URLデコードする
    path = urllib.unquote(path)
    if is_dev():
        # ローカルサーバーのみで使える
        filename = "/%s/%s" % (bucket_name,path)
        write_retry_params = gcs.RetryParams(backoff_factor=1.1)
        content_type = request.headers["Content-Type"]
        gcs_file = gcs.open(filename,'w',content_type=content_type,retry_params=write_retry_params)
        gcs_file.write(request.data)
        gcs_file.close()
        return "OK"
    else:
        abort(404)

@app.route("/twitter_card")
def twitter_card():
    if is_dev():
        ruby = request.args.get('ruby','')
        name = request.args.get('name','')
        address = request.args.get('address','')
        return render_template('twitter_card.html',ruby=ruby,name=name,address=address)
    else:
        abort(404)

@app.route("/w285ng")
def test_twitter_card():
    "トップページ"
    return render_template('test_twitter_card.html',hostname=hostname)
