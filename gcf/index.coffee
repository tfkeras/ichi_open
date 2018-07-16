initAPI = require('./api')
express = require('express')

app = null
# Cloud function用エントリーポイント
if true
  exports.weather = (req, res) ->
    if app == null
      app = express()
      initAPI(app,"")
    app(req, res)
else
  app = express()
  initAPI(app,"")
  app.listen 3000, () ->
    console.log('Example app listening on port 3000!');
