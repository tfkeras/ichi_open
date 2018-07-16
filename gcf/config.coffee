
if false
  # リリース
  config =
    PROJECT_ID : 'ichiwearjp'
    CREDENTIAL: require('./release_keyfile.json')
else
  #デバッグ
  config =
    PROJECT_ID : 'glhf-155020'
    CREDENTIAL : require('./debug_keyfile.json')

module.exports = config
