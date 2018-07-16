PositionBase = require("./position_base")

# ベースクラスを作成する
# 退避用this
PositionCurrentThis = null

# Geolocation.getCurrentPosition() メソッドを用いた位置情報
class PositionCurrent extends PositionBase
  # コンストラクタ
  constructor: (cb) ->
    super(cb)
    # this退避
    PositionCurrentThis = this
    # タイムアウトID
    @timeoutId = null


  # 位置情報の監視を開始する
  startWatchPosition: ->
    this.getCurrentPosition()

  # 位置情報の監視を止める
  stopWatchPosition: ->
    if @timeoutId?
      clearTimeout(@timeoutId)
      @timeoutId = null


  getCurrentPosition: ->
    options =
      enableHighAccuracy: true
      timeout: 60000
      maximumAge: 0
    @timeoutId = null
    navigator.geolocation.getCurrentPosition(
      this.onGeolocationSuccess,
      this.onGeolocationError,
      options)


  # 位置情報を更新した時のイベント
  onGeolocationSuccess: (obj) ->
    self = PositionCurrentThis
    if self.isRunning()
      date = new Date()
      self.pos.minAccuracy  =  obj.coords.accuracy
      self.pos.startTime = date.getTime()
      self.pos.coords = obj.coords
      self.pos.accuracyTimeout = true
      self.cb.update(self.pos)
      # 10秒に1回取る
      interval = 10000
      if self.timeoutId?
        clearTimeout(self.timeoutId)
        self.timeoutId = null
      self.timeoutId = setTimeout(
          () ->
            self.getCurrentPosition()
          interval
        )


  # 位置情報取得にエラーがあった時のイベント
  onGeolocationError: (obj) ->
    self = PositionCurrentThis
    code = obj.code
    self.cb.onError(code)

module.exports = PositionCurrent
