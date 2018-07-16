# 外部クラス読み込み
Query = require('./query')
Page = require('./page')
KDTree = require('./kdtree')
PositionWatch = require("./position_watch")
PositionCurrent = require("./position_current")

# バージョン取得
version = parseInt($('#version').text())
# 新宿駅
SAMPLE_ID = 1130208
# KD木
tree = null
# ページ更新担当
page = new Page()
# クエリパラメータ取得
params = Query.get()
# 駅IDを取得
stationId = parseInt($('#station_id').text())
if(stationId == 0)
  stationId = null
if stationId?
  # KD木をダウンロード後、駅情報を表示
else
  # 読み込み中を表示
  page.showLoading(true)
# nearestフラグがあったら、URLをリセット
if params['nearest']
  history.replaceState('','','/');

# 位置情報担当
cb =
  update: (pos)->
    # 位置が更新
    page.updateAccuracy(pos.coords.accuracy)
    updateStation(pos)
    page.addLog({latitude: pos.coords.latitude,longitude: pos.coords.longitude,accuracy: pos.coords.accuracy})

  onError: (code) ->
    # 位置情報取得にエラー
    if stationId?
    else
      # サンプルとして新宿駅を表示
      page.download(SAMPLE_ID)
    page.showLocationError(code)
    page.addLog({error: code})
# 位置取得担当オブジェクト作成
if params.wcp == '1'
  position = new PositionCurrent(cb)
else
  position = new PositionWatch(cb)
# 自動更新のON/OFFで駅情報更新
$('#auto_update').click(->
  position.requestUpdate()
  )
# ページ表示状態が更新
document.addEventListener("visibilitychange",
  () ->
    if document.hidden
      # バックグランド
      page.addLog({foreground: 0})
      page.setForeground(false)
      position.setForeground(false)
    else
      # フォアグランド
      page.addLog({foreground: 1})
      page.setForeground(true)
      position.setForeground(true)
  ,false)


# 1) 位置情報のKD木をダウンロード
downloadTree = ->
  Vue.http.get("/static/tree.json?v=#{version}",{timeout:30000}).then((response) ->
      tree = new KDTree(response.data)
      if stationId?
        # idに該当する駅を表示
        page.download(stationId)
        # 自動更新は解除
        page.setAutoUpdate(false)
        position.setEnabled(true)
      else
        # 近い駅を表示する
        position.setEnabled(true)
    ,(error) ->
      # ネットワークエラーを表示
      page.showNetworkError(true)
    )

#位置情報の更新または一定時間経過で呼び出す
updateStation = (pos) ->
  if pos.minAccuracy < 100 || pos.accuracyTimeout
    # 近くの駅を探す
    # ダウンロードする
    point = {y: pos.coords.latitude, x: pos.coords.longitude}
    place = tree.nn(point)
    if stationId?
      # 2回目以降表示
      if stationId != place.id
        if page.isAutoUpdate()
          # 自動更新ON
          page.download(place.id)
          page.showUpdated(false)
          # 自動更新による更新の場合は、URLを書き換える
          history.replaceState('','','/');
          stationId = place.id
        else
          # 自動更新OFF
          page.showUpdated(true)
    else
      # 初回表示
      page.download(place.id)
      stationId = place.id
    page.updateNearest(place.id)

# 最初はKD木のダウンロードから
downloadTree()
