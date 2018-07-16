いちウェアのソースコード
====

スマホの位置情報を用いて、今居る場所に一番近い駅の情報を表示するWebアプリのソースコードです。

## アプリ公開URL

https://ichiwear.jp/

## ソースコード掲載範囲

ソースコードの掲載範囲はGoogle App EngineとGoogle Cloud Functionsにデプロイしている分のみとなります。
駅の情報はGoogle Cloud Storageに格納していますが、駅データ．ｊｐ (http://www.ekidata.jp/) 様からの有料購入データを加工したものなので、掲載していません。また、API利用キーなどもセキュリティ上の問題から掲載していません。

## Google App Engine アプリ

gaeフォルダにあります。

### 構成

|ディレクトリ、ファイル|説明|
|----|----|
|assets/|クライアントサイドのCoffeeScriptとSass|
|static/|クライアントサイドの静的ファイル|
|templates/|HTMLファイルのテンプレート|
|app.yaml|アプリ設定ファイル|
|appengine_config.py|ライブラリフォルダを追加|
|main.py|サーバサイドのメイン|
|package.json|CoffeeScriptとSassのコンパイルに必要なnode.jsライブラリを定義|
|requirements.txt|サーバサイドの依存ライブラリ|
|webpack.config.coffee|CoffeeScriptとSassをwebpackでコンパイルするための設定ファイル|

## Google Cloud Functions アプリ

天気情報の取得に利用しています。gcfフォルダにあります。

### 構成

|ディレクトリ、ファイル|説明|
|----|----|
|dist/|gulpによるCoffeeScriptコンパイル結果が格納されます|
|index.coffee、api.coffee、weather.coffee、config.coffee|お天気APIの実装です。|
|cities.json|お天気取得の対象となるOpenWeatherMapの都市コード一覧|
|gulpfile.coffee|gulpによるCoffeeScriptコンパイル設定|
|package.json|CoffeeScriptのコンパイルに必要なnode.jsライブラリを定義|
|debug_keyfile.json|Google Cloud Datastoreの認証ファイル(未掲載)|




