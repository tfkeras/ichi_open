sprintf = require("sprintf")

# 時計
class Watch
  constructor: (data) ->
    # バインディングデータ
    @data = data
    @foreground = true
    @timeoutID = null
    this.update()

  setForeground: (flag) ->
    @foreground = flag
    this.update()

  onClick: () ->
    @data.mode += 1
    if @data.mode >= 3
      @data.mode = 0
    this.update()

  update: ->
    if @timeoutID?
      clearTimeout(@timeoutID)
      @timeoutID = null
    if @foreground
      this.render()

  # 描画する
  render: ->
    date = new Date()
    if @data.mode == 1
      text = sprintf("%d:%02d",date.getHours(),date.getMinutes())
    else if @data.mode == 2
      text = sprintf("%d:%02d:%02d",date.getHours(),date.getMinutes(),date.getSeconds())
    else
      text = ""
    @data.text = text
    clearTimeout(@timeoutID)
    @timeout = null
    if @data.mode >= 1
      delay = date.getTime() - Math.floor((date.getTime() / 1000)) * 1000
      @timeoutID = setTimeout(
        () =>
          this.render()
        1000
      )

module.exports = Watch
