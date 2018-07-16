# APIのURL
if true
  if true
    URL = "https://us-central1-ichiwearjp.cloudfunctions.net/weather"
  else
    URL = "https://us-central1-glhf-155020.cloudfunctions.net/weather"
else
  URL = "/weather"

# 天気表示担当
class Weather

  constructor: (weather) ->
    @data = weather
    @id = null

  # 都市情報から天気を更新
  update: (city) ->
    @id = city.id
    Vue.http.get("#{URL}/#{@id}",{timeout:30000}).then((response) =>
        data = response.data
        if @id == data.id
          @data.temp = data.currentTemp
          @data.list = [this.convertIdToName(data.currentTime,data.current,data.sunrise,data.sunset),
            this.convertIdToName(data.next0Time,data.next0,data.sunrise,data.sunset)]
      ,(error) =>
        @data.temp = null
        @data.list = ["error"]
      )

  # 天気IDからアイコン名に変換
  convertIdToName: (time,id,sunrise,sunset) ->
    if 200 <= id && id <= 599
      return "rain"
    else if 600 <= id && id <= 699
      return "snow"
    else if 800 <= id && id <= 802
      if sunrise <= time && time <= sunset
        return "sunny"
      else
        return "moon"
    else if 803 <= id && id <= 804
      return "cloud"
    else
      return "other"

  # 現在時刻を取得する
  getTime: () ->
    date = new Date()
    nt = Math.floor(date.getTime() / 1000)
    return nt

#公開モジュールにする
module.exports = Weather
