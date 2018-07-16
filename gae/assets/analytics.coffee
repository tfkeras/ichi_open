
class Analytics
  # 状態更新時に呼ばれる
  status: (name,value) ->
    action = name
    if value == true
      action += '1'
    else if value == false
      action += '0'
    else if typeof(value) == 'number'
      action += value
    ga('send','event','Default',action)

#公開モジュールにする
module.exports = Analytics
