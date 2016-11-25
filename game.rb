#require 'dxruby'
require 'nanogl'
require_relative 'dxruby_on_nanogl'
require 'Psych'

# ログ表示用のメソッド
def log(*args)
  if DEBUG
    puts *args
  end
end

# シーンを実行するメソッド
def scene(&block)
  Window.loop(true) do
    if Input.requested_close?
      log "ウィンドウを閉じたのでプログラムを終了"
      exit
    end
    block.tap &block
  end
end

# ２点の距離
def distance(x1,y1,x2,y2)
  return ((x2-x1)**2 + (y2-y1)**2)**0.5
end

# 矩形
class Rectangle
  attr_reader :left, :top, :width, :height

  def initialize(l,t,w,h)
    @left = l
    @top = t
    @width = w
    @height = h
  end

  def right
    return @left+@width
  end

  def bottom
    return @top+@height
  end

  def hit?(x,y)
    return (@left..right).include?(x) && (@top..bottom).include?(y)
  end

  def overlap?(rect)
    return self.left <= rect.right && rect.left <= self.right && self.top <= rect.bottom && rect.top <= self.bottom
  end
end

# 円
class Circle
  attr_reader :r, :x, :y

  def initialize(r,x,y)
    @r = r
    @x = x
    @y = y
  end

  def hit?(x,y)
    return distance(x,y,@x,@y) < @r
  end

  def overlap?(circle)
    return distance(circle.x,circle.y,@x,@y) < circle.r + @r
  end
end

class GameBase

  # 初期化
  def initialize()
    # 画面のサイズを設定
    Window.width = WINDOW_WIDTH
    Window.height = WINDOW_HEIGHT

  end

  # 実行
  def run(scene, *params)
    while methods.include?(scene) do
      (scene, params) = send(scene, *params)
    end
  end

end
