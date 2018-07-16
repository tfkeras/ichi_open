# 天気情報取得関数群

# メモ
# API回数 60/分
# 3時間ごとに次の3時間を表示
# 30分程度の遅延あり

config = require('./config')
#Datastoreをインポート
Datastore = require('@google-cloud/datastore')
# HTTPクライアント
fetch = require('node-fetch')

class Weather
  # OpenWeatherMapのAPI key
  # ソースコード公開用に削除
  API_KEY = "secret"

  # 都市一覧
  CITIES = require('./cities.json')
  #
  KIND = "Weather"

  constructor: () ->
    @ds = Datastore({projectId: config.PROJECT_ID, credentials: config.CREDENTIAL})

  # 都市IDに該当する天気を取得する
  get: (id) ->
    # APIエラーケース
    e = {code:500}
    # 存在しない都市IDケース
    if CITIES.includes(id) == false
      return Promise.reject(e)
    # キャッシュを取得する
    return this.getCached(id)
      .then (weather) =>
        nt = this.getTime()
        if weather
          if weather.expire > nt
            # キャッシュからの取得
            weather.id = id
            return weather
        # キャッシュがなければ、APIから取得する
        return this.getFromAPI(id)
      .catch (err) ->
        console.error(err)
        throw e

  getFromAPI: (id) ->
    # 現在の天気を取得する
    url = "https://api.openweathermap.org/data/2.5/weather?id=#{id}&units=metric&appid=#{API_KEY}"
    current = null
    return fetch(url)
      .then (res) ->
        # JSONパース
        if res.status == 200
          return res.json()
        else
          # APIエラー
          # then、catch内で例外を投げることができ、チェインできる
          throw res
      .then (body) ->
        # 現在の天気を保持
        current = body
        # 次の3時間の天気を取得する
        url = "https://api.openweathermap.org/data/2.5/forecast?id=#{id}&units=metric&appid=#{API_KEY}"
        return fetch(url)
      .then (res) ->
        # JSONパース
        if res.status == 200
          return res.json()
        else
          # APIエラー
          throw res
      .then (forecast) =>
        # 現在天気と予報天気を合成
        weather =
          id: current.id
          name: current.name
          current: this.selectWeather(current.weather)
          currentTime: current.dt
          currentTemp: Math.floor(current.main.temp)
          next0: this.selectWeather(forecast.list[0].weather)
          next0Time: forecast.list[0].dt
          sunrise: current.sys.sunrise
          sunset: current.sys.sunset
        this.save(id,weather)
        return weather
      .catch (err) ->
        # APIエラーまたはネットワークエラー
        throw err


  # キャッシュされているお天気情報を取得する
  getCached: (id) ->
    key = @ds.key([KIND,id])
    return @ds.get(key)
      .then (results) ->
        return results[0]
      .catch (e) ->
        throw e

  # 天気を保存する
  save: (id,weather) ->
    nt = this.getTime()
    # idは都市ID
    key = @ds.key([KIND,id])
    # 破棄時刻を設定 10分
    weather.expire = nt + 600
    # Entityを作成
    entity =
      key: key
      data: this.removeIndexes(weather)
    # 登録する。キャッシュなので、終了は待たない
    @ds.upsert(entity).then (r) ->
        r = null
      .catch (e) ->
        # 失敗時
        console.error(e)

  # Entityのデータについて、インデックスから除外する
  # idも削除する
  removeIndexes: (obj) ->
    entity = []
    for name, value of obj
      if name != "id"
        entity.push({name: name, value: value, excludeFromIndexes: true})
    return entity

  # 現在時刻を取得する
  getTime: () ->
    date = new Date()
    nt = Math.floor(date.getTime() / 1000)
    return nt

  # メインの天気を選択する
  selectWeather: (list) ->
    for weather in list
      id = weather.id
      if 200 <= id && id <= 599
        # 雨
        return id
      else if 600 <= id && id <= 699
        # 雪
        return id
      else if 800 <= id && id <= 802
        # 晴れ
        return id
      else if 803 <= id && id <= 804
        # 曇り
        return id
    # その他
    return id

weather = new Weather()
module.exports = weather
