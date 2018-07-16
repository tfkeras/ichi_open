# デプロイコマンド
# gcloud beta functions deploy weather --stage-bucket functions_glhf-155020 --trigger-http --project glhf-155020
# gcloud beta functions deploy weather --stage-bucket functions_ichiwearjp --trigger-http --project ichiwearjp
# お天気APIのエントリー隔離
express = require('express')
# セキュリティ対策ミドルウェア
helmet = require('helmet')
# 入力バリデーション
expressValidator = require('express-validator')
# 天気取得担当
weather = require('./weather')
# お天気API隔離
initAPI = (app,path)->
  app.use(expressValidator())
  app.use(helmet())
  # CORS対応
  app.use((req, res, next) ->
    # Origin Headerが所定の物のみ有効
    origin = req.get('Origin')
    if(origin == undefined || origin ==  'https://ichiwear.jp' ||  origin == 'https://ichiwearjp.appspot.com')
      res.set('Access-Control-Allow-Origin', origin)
      res.set('Cache-Control','public, max-age=600')
      next()
    else
      res.status(400).send("invalid param")
  )
  # お天気API
  app.get "#{path}/", (req,res) ->
    res.send("It works.")
  app.get "#{path}/:id", (req, res) ->
    #パラメータ確認
    req.checkParams('id', 'Invalid id').notEmpty().isInt()
    req.getValidationResult().then (result) ->
      if result.isEmpty()
        # 正常入力
        id = parseInt(req.params.id)
        # 天気取得
        weather.get(id)
          .then (result) ->
            res.json(result)
          .catch (result) ->
            res.status(result.code).send("API error")
      else
        res.status(400).send("invalid param")

module.exports = initAPI
