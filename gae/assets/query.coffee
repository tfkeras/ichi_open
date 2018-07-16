class Query
  @get: ->
    # クエリストパーシング
    params = {}
    kvs = window.location.search.substring(1).split('&')
    for kv in kvs
      array = kv.split('=')
      params[array[0]] = array[1]
    return params

#公開モジュールにする
module.exports = Query
