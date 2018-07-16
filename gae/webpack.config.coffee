#webpackはjavascriptを出力するツールなので、テキストを抽出するプラグインを使う
ExtractTextPlugin = require('extract-text-webpack-plugin')
UglifyJSPlugin = require('uglifyjs-webpack-plugin')

module.exports =
  # 入力ファイル
  entry:
    'style': './assets/style.sass'
    'guide': './assets/guide.sass'
    'main': './assets/main.coffee'
  # 出力ファイル(CSSのそれは使わない)
  output:
    path: __dirname
    filename: 'static/[name].js'
  resolve:
    extensions: ['.js', '.coffee']
  module:
    # SASS、SCSSの設定
    rules: [
      {
        test: /\.sass|\.scss$/
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader'
          use: ['css-loader?url=false&minimize=true', 'sass-loader']
        })
      },
      {
        test: /\.coffee$/
        use: [{
          loader: 'coffee-loader'
          options:
            transpile:
              presets: ['env']
        }]
      }
    ]
  # プラグインの設定
  plugins: [new UglifyJSPlugin(),
    new ExtractTextPlugin('./static/[name].css')
  ]
