#JD木
class KDTree

  constructor: (node) ->
    @node = node

  nn: (point) ->
    return @_nn(@node,point)

  _nn: (node,point) ->
    #暫定最近傍
    nn1 = null
    d1 = Infinity
    direction = false
    if node == null
      #末端
      return null
    else if @node_direction(node,point)
      #所属エリアは右
      nn1 = @_nn(node.right,point)
      direction = true
    else
      #所属エリアは左
      nn1 = @_nn(node.left,point)
      direction = false

    # 距離を確認
    if nn1 != null
      d1 = @distance(point,nn1)

    # 自分自身との距離
    nn2 = node.point
    d2 = @distance(nn2,point)
    # 反対側の最短
    nn3 = null
    d3 = Infinity
    # となりの領域チェック必要判定
    if @node_in_neighbor(node,point,d1)
      #となりにあるので、となりの最短を検索する
      if direction
        # 左の最短
        nn3 = @_nn(node.left,point)
      else
        # 右の最短
        nn3 = @_nn(node.right,point)
      d3 = @distance(point,nn3)

    # 自分、右、左から一番近い点を選ぶ
    if d1 < d2 && d1 < d3
      return nn1
    else if d2 < d1 && d2 < d3
      return nn2
    else
      return nn3

  #2点間の距離の二条を求める
  distance: (p1,p2) ->
    if p1 != null && p2 != null
      return Math.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2)
    else
      return Infinity

  #軸を取得
  node_axis: (node) ->
    return node.depth % 2

  #軸に対応する値を取得
  node_value: (node) ->
    if @node_axis(node) == 0
      return node.point.x
    else
      return node.point.y

  node_direction: (node,point) ->
    if @node_axis(node) == 0
      return @node_value(node) < point.x
    else
      return @node_value(node) < point.y

  #pointからdistanceの距離に隣の領域が含まれているかを判定
  node_in_neighbor: (node,point,distance) ->
    if distance == null
      return false
    if @node_direction(node,point)
      #左を見る
      if @node_axis(node) == 0
        return point.x - distance < @node_value(node)
      else
        return point.y - distance < @node_value(node)
      end
    else
      #右を見る
      if @node_axis(node) == 0
        return point.x + distance > @node_value(node)
      else
        return point.y + distance > @node_value(node)

#公開モジュールにする
module.exports = KDTree
