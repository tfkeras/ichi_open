# 位置情報取得の親クラス
class PositionBase
  constructor: (cb) ->
    # コールバックを登録
    # コールバックにはupdate(pos)とonError(code)がある
    @cb = cb
    # 位置情報
    @pos =
      # 開始時刻
      startTime: 0
      # 位置情報
      coords: null
      # 精度タイムアウトフラグ
      accuracyTimeoutReserved: false
      # 精度最小値
      minAccuracy: Number.MAX_VALUE
      # 一定時間経過したら、精度は無視する
      accuracyTimeout: false

    # 有効無効フラグ
    @enabled = false
    # フォアグランドフラグ
    @foreground = true
  # ブラウザのフォアグランド
  setForeground: (flag) ->
    @foreground = flag
    this.update()

  # 位置情報の有効無効
  setEnabled: (flag) ->
    @enabled = flag
    this.update()

  # 動作中か確認する
  isRunning: () ->
    return @enabled && @foreground

  # 更新の要求
  requestUpdate: () ->
    @cb.update(@pos)

  # 位置情報取得のON/OFFを切り替える
  update: ()->
    if this.isRunning()
      this.startWatchPosition()
    else
      this.stopWatchPosition()

module.exports = PositionBase
