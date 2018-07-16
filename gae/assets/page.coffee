sprintf = require("sprintf")
VueLocalStorage = require('vue-localstorage')
Watch = require('./watch')
Weather = require('./weather')
Analytics = require('./analytics')
# バージョン取得
version = parseInt($('#version').text())
# いちウェア
HASHTAG = encodeURIComponent("いちウェア")
# ローカルストレージを使う1
Vue.use(VueLocalStorage,{name: 'ls'})
# ページ更新担当クラス
class Page
  # 表示でデータの設定
  constructor: ->
    self = this
    @analytics = new Analytics()
    # 表示データ
    @data = {
      # デバッグモード
      debug: false
      # 読み込み中
      loading : false
      # 精度
      accuracy : null
      # GPSエラー
      locationError: null
      # ネットワークエラー
      networkError: false
      # 読み込み完了
      station : false
      # 自動更新スイッチ
      autoUpdate : false
      # 大きい文字スイッチ
      largeFont : false
      # 近い駅が更新されたフラグ
      updated : false
      # 近い駅リンク
      nearestLink : "/"
      # 駅データ
      name: ""
      ruby: ""
      address: ""
      triples: []
      links: {
        wikipedia: ""
        google: ""
        map: ""
        twitter: ""
        twitter_share: ""
      }
      # 天気データ
      weather:
        # 温度
        temp: null
        # 天気
        list: []
      # 時計データ
      watch:
        mode: 1
        text: ""
      # アニメ用
      satelliteClass : ""
      # デバッグ用ログ
      logs : []
    }
    # バインディング設定
    vm = new Vue({
      el : '#main'
      delimiters: ['[[',']]']
      data : @data
      created: () ->
        this.$data.autoUpdate = (this.$ls.get("autoUpdate") == 'true')
        this.$data.largeFont = (this.$ls.get("largeFont") == 'true')
        # 時計モード
        mode = this.$ls.get("watchMode")
        if mode? == false
          mode = '1'
        this.$data.watch.mode = parseInt(mode)
        # Analytics
        # trueの時はwatchの側が呼ばれる
        if this.$data.autoUpdate == false
          self.analytics.status("autoUpdate",this.$data.autoUpdate)
        if this.$data.largeFont == false
          self.analytics.status("largeFont",this.$data.largeFont)
        self.analytics.status("watch",this.$data.watch.mode)
        # Twitter初期リンクを設定する
        encodedURL = encodeURIComponent("https://ichiwear.jp/")
        this.$data.links.twitter_share =
          "https://twitter.com/intent/tweet?hashtags=#{HASHTAG}&url=#{encodedURL}&related=ichiwear"
      watch:
        autoUpdate: (flag) ->
          this.$ls.set("autoUpdate",flag)
          self.analytics.status("autoUpdate",flag)
        largeFont: (flag) ->
          this.$ls.set("largeFont",flag)
          self.analytics.status("largeFont",flag)
      methods:
        # リロードする
        reload: () ->
          location.reload()
        onClickWatch: () ->
          self.watch.onClick()
          this.$ls.set("watchMode",this.$data.watch.mode)
          self.analytics.status("watch",this.$data.watch.mode)
    })
    # 時計
    @watch = new Watch(@data.watch)
    # 天気
    @weather = new Weather(@data.weather)

    # アニメーション
    setTimeout(
      =>
        @data.satelliteClass = "satellite-enter-active"
      200
    )
  # フォアグランド
  setForeground: (flag) ->
    @watch.setForeground(flag)

  # 読み込み中画面の表示非表示
  showLoading: (flag) ->
    @data.loading = flag
  # 読み込み完了
  showStation: (flag) ->
    @data.station = flag

  showUpdated: (flag) ->
    @data.updated = flag

  isAutoUpdate: () ->
    return @data.autoUpdate

  setAutoUpdate: (flag) ->
    @data.autoUpdate = flag

  updateAccuracy: (accuracy) ->
    @data.accuracy = Math.floor(accuracy)

  showLocationError: (code) ->
    @data.locationError = code

  showNetworkError: (flag) ->
    @data.networkError = flag

  download: (id) ->
    #id = 1130208
    # 重複ダウンロードを防止する
    if id != lastId
      #7桁0埋め
      path = ('0000000' + id).slice(-7)
      path = "/station/#{path}?v=#{version}"
      lastId = id
      Vue.http.get(path,{timeout:30000}).then((response) =>
          #ここからは公開関数しか呼べない
          @showLoading(false)
          @showStation(true)
          @update(response.data)
        ,(error) =>
          @data.networkError = true
        )

  #ページを更新する
  update: (station) ->
    @data.name = station.name
    @data.ruby = station.ruby
    @data.address = station.address
    # 3つずつに分離する
    @data.triples = []
    for i in [0...station.companies.length]
      if i%3 == 0
        @data.triples.push([])
      @data.triples[@data.triples.length - 1].push(station.companies[i])
    # プログラム的生成部分
    for companies in @data.triples
      for company in companies
        for line in company.lines
          line.color_style = { "background-color" : line.color}
          line.previous.link = "/" + line.previous.id
          line.next.link = "/" + line.next.id
    # リンクを生成
    sne = encodeURIComponent(station.name + "駅")
    encodedURL = encodeURIComponent("https://ichiwear.jp/#{station.id}")
    @data.links.wikipedia = "https://ja.wikipedia.org/wiki/" + sne
    @data.links.google = "https://www.google.co.jp/search?q=" + sne
    @data.links.map = "https://www.google.co.jp/maps/@#{station.y},#{station.x},15z"
    @data.links.twitter = "https://twitter.com/search?q=" + sne
    @data.links.twitter_share =
      "https://twitter.com/intent/tweet?hashtags=#{HASHTAG}&url=#{encodedURL}&related=ichiwear"
    # 天気を更新
    @weather.update(station.weather)

  #近い駅を更新する
  updateNearest: (id) ->
    @data.nearestLink = "/#{id}?nearest=1"

  #デバッグ用ログの追加
  addLog: (log) ->
    date = new Date()
    log.time = date.toLocaleTimeString()
    if typeof log.latitude == "number"
      log.latitude = sprintf("%.4f",log.latitude)
    if typeof log.longitude == "number"
      log.longitude = sprintf("%.4f",log.longitude)
    if typeof log.accuracy == "number"
      log.accuracy = sprintf("%d",log.accuracy)
    @data.logs.unshift(log)
    if @data.logs.length > 10
      @data.logs.pop()

#公開モジュールにする
module.exports = Page
