
PositionBase = require("./position_base")

# ベースクラスを作成する
# 退避用this
PositionWatchThis = null

# Geolocation.watchPosition() メソッドを用いた位置情報
class PositionWatch extends PositionBase
  # コンストラクタ
  constructor: (cb) ->
    super(cb)
    # watchPosition関数の戻り値
    @watchPositionId = null
    # this退避
    PositionWatchThis = this


  # 位置情報の監視を開始する
  startWatchPosition: ->
    if @watchPositionId? == false && @enabled
      geolocationOptions =
        enableHighAccuracy: true
        timeout: 60000
        maximumAge: 0
      @watchPositionId = navigator.geolocation.watchPosition(
        this.onGeolocationSuccess,
        this.onGeolocationError,
        this.geolocationOptions)

  # 位置情報の監視を止める
  stopWatchPosition: ->
    if @watchPositionId?
      navigator.geolocation.clearWatch(@watchPositionId)
      @watchPositionId = null

  # 位置情報を更新した時のイベント
  onGeolocationSuccess: (obj) ->
    self = PositionWatchThis
    date = new Date()
    self.pos.startTime = date.getTime()
    self.pos.coords = obj.coords
    if self.pos.coords.accuracy < self.pos.minAccuracy
      self.pos.minAccuracy = self.pos.coords.accuracy
    # 一定秒数後に更新
    if self.pos.accuracyTimeoutReserved == false
      self.pos.accuracyTimeoutReserved = true
      # 現在時刻取得
      date = new Date()
      currentTime = date.getTime()
      time = self.pos.startTime + 2000 - currentTime
      if time >= 1
        setTimeout(->
            self.pos.accuracyTimeout = true
            self.cb.update(self.pos)
          time)
      else
        self.pos.accuracyTimeout = true
    # 表示更新
    self.cb.update(self.pos)

  # 位置情報取得にエラーがあった時のイベント
  onGeolocationError: (obj) ->
    self = PositionWatchThis
    code = obj.code
    self.cb.onError(code)
    # if code == 0
    #   data.message = '原因不明のエラー'
    # else if code == 1
    #   data.message = '許可されなかった'
    # else if code == 2
    #   data.message = '取得できなかった'
    # else if code == 3
    #   data.message = '時間がかかりすぎた'

module.exports = PositionWatch
