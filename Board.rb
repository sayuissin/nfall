
# 盤面
class Board
    attr_reader :width, :height, :message, :minos
  
  @@image = {}
  @@image[:Star] = Image.load("image/star.bmp")
  @@image[:Block1] = Image.load("image/piece1.bmp")
  @@image[:Block2] = Image.load("image/piece2.bmp")
  @@image[:Block3] = Image.load("image/piece3.bmp")
  @@image[:Block4] = Image.load("image/piece4.bmp")
  @@image[:Block5] = Image.load("image/piece5.bmp")
  @@image[:Block6] = Image.load("image/piece6.bmp")
  @@image[:Block7] = Image.load("image/piece7.bmp")
  @@image[:Jama] = Image.load("image/JamaBlock.bmp")


  # 初期化
  def initialize(cell_size, width, height)
    @cell_size = cell_size
    @width = width
    @height = height
    @board = Array.new(@width * @height, :Empty)
    @message = DEFAULT_MESSAGE
    @shine = DEFAULT_SHINE
    @minos = DEFAULT_MINOS
  end

  # 盤面データをファイルに保存する
  def save_file(path)
    open(path.chomp, 'w') do |file|
      Psych.dump(self, file)
    end
  end

  DEFAULT_CELL_SIZE = 32
  DEFAULT_WIDTH = 16
  DEFAULT_HEIGHT = 16
  DEFAULT_MESSAGE = ""
  DEFAULT_SHINE = []
  DEFAULT_MINOS = [-1]
  
  def check!
      @cell_size = DEFAULT_CELL_SIZE if @cell_size == nil
      @width = DEFAULT_WIDTH if @width == nil
      @height = DEFAULT_HEIGHT if @height == nil
      @message = DEFAULT_MESSAGE if @message == nil
      @shine = DEFAULT_SHINE if @shine == nil
      @minos = DEFAULT_MINOS if @minos == nil or @minos.empty?



    @board = Array.new(@width * @height, :Empty) if @board == nil
  end

  # 盤面データをファイルから読み込む
  def self.load_file(path)
    data = Psych.load_file(path.chomp)
    data.check! if data != nil
    return data
  end

  # 盤面データをクリアする
  def clear!
    @board = Array.new(@width * @height, :Empty)
  end

  # 盤面の大きさを変える
  def resize!(w,h)
    # 4x4より小さくさせない
    if (w < 4) || (h < 4)
      return
    end

    # 新しい盤面データを入れる配列を作る
    new_board = Array.new(w * h, :Empty)

    # 新しい盤面に古い盤面のデータをコピー
    h.times do |y|
      w.times do |x|
        new_board[x + y * w] = get(x,y)
      end
    end

    # 盤面を更新する
    @width = w
    @height = h
    @board = new_board

  end

  # マス目座標(cx,cy)が盤面内かどうか判定
  def hit?(cx,cy)
    return (0...@width).include?(cx) && (0...@height).include?(cy)
  end

  # ブロックkindをマス目(cx,cy)に配置
  def set!(cx,cy,kind)
    if hit?(cx,cy)
      @board[cx + cy*@width] = kind
    end
  end

  # マス目(cx,cy)のブロックを取得
  def get(cx,cy)
    if hit?(cx,cy) == false
      return :Empty
    end
    return @board[cx + cy*@width]
  end

  # ステージクリアかどうか判定
  def complete?
    return @board.include?(:Star) == false
  end

  # minosに入っているミノのうち一つでも置けるミノが存在する場合はゲームオーバーにならない
  def gameover?(checknum, minos)
    if checknum > minos.length 
      return false
    end
    minos.take(checknum).each do |mino|
      @height.times do |y|
        @width.times do |x|
          4.times do
            if placeable?(x, y, mino)
              return false
            end 
          end
        end
      end
    end
    return true
  end

  # 画面上の座標(x,y) からマス目座標(cx,cy)を求める
  def to_cell_pos(x, y)
    return [x / @cell_size, y / @cell_size]
  end

  # 画面上の座標(x,y)に星ブロックを描く
  def draw_star_cell(x,y)
    Window.draw(x,y,@@image[:Star])
  end

  # 画面上の座標(x,y)に配置済みのブロックを描く
  def draw_block_cell(x,y, kind)
    Window.draw(x,y,@@image[kind])
  end

  # 画面上の座標(x,y)に邪魔ブロックを描く
  def draw_jama_block_cell(x,y)
    Window.draw(x,y,@@image[:Jama])
  end

  # 画面上の座標(x,y)に仮配置のブロックを描く
  def draw_tmpblock_cell(x,y)
    Window.draw_box_fill(x,y,x+@cell_size,y+@cell_size, [0,0,255])
  end

  # 画面上の座標(x,y)に指示ブロックを描く
  def draw_shineblock_cell(x,y)
    Window.draw_box_fill(x,y,x+@cell_size,y+@cell_size, [14,196,173])
  end

  # 画面上の座標(x,y)にマス目の枠を描く
  def draw_cell_border(x,y)
    Window.draw_box(x,y,x+@cell_size,y+@cell_size, [167,176,200])
  end

  # 画面上でマス目(cx,cy)の位置に種類 block_kind のブロックを描く
  def draw_block(left, top, cx, cy, block_kind)
    # マス目の左上座標を計算
    l = left + cx * @cell_size
    t = top + cy * @cell_size

    # マス目にブロックを描く
    case block_kind
      when :Empty
        # 何も描かない
      when :Star
        draw_star_cell(l,t)
      when :Block1, :Block2, :Block3, :Block4, :Block5, :Block6, :Block7
        draw_block_cell(l,t,block_kind)
      when :JamaBlock
        draw_jama_block_cell(l,t)
      when :Temp
        draw_tmpblock_cell(l,t)
      when :Shine
        draw_shineblock_cell(l,t)
    end

    # マス目の枠を描く
    draw_cell_border(l,t)
  end

  # 画面上の座標(left,top)を左上として盤面を描く
  # minoは現在のミノ、cx,cyはカーソルのあるマス目座標を入れる
  def draw(left, top, mino, cursor_x, cursor_y)
    @height.times do |y|
      @width.times do |x|

        # ブロックを指示するマスを描く
        if @shine.include?([x,y]) == true
          #光らせるブロックの位置
          draw_block(left, top, x, y, :Shine)          
        end


        # ミノが与えられていたらカーソルの位置を元にミノのブロックを描く
        if mino != nil
          if mino.get(x-cursor_x,y-cursor_y) != :Empty
            draw_block(left, top, x, y, :Temp)
          end
        end

        # マス目に配置されてるブロックの描画
        draw_block(left, top, x, y, get(x,y))


      end
    end
  end

  # マス目(cx,cy)にミノを置くことができるか判定
  def placeable?(cx, cy, mino)
    # (cx,cy)にミノの左上がくるので画面外か判定
    if hit?(cx,cy) == false
      return false
    end

    # ミノが画面内に収まっているか判定
    if (cx + mino.width > @width) || (cy + mino.height > @height)
      return false
    end

    # ミノを構成しているブロックと盤面に置いてあるブロックが干渉するか判定
    mino.height.times do |y|
      mino.width.times do |x|
        if mino.get(x,y) != :Empty && get(cx+x, cy+y) != :Empty
          # 干渉するので置けない
          return false
        end
      end
    end

    # 盤面にミノを置くことができる
    return true
  end

  # マス目(cx,cy)にミノを配置する
  def set_mino!(cx, cy, mino)
    mino.height.times do |y|
      mino.width.times do |x|
        if mino.get(x,y) != :Empty
          set!((cx+x), (cy+y), mino.get(x,y))
        end
      end
    end
  end

  # ブロックが揃った行と列を探して含まれるブロックを消す
  def check_and_erace!
    # ブロックが揃った列を消す候補に入れる
    erace_col = []
    @height.times do |y|
      full = true
      @width.times do |x|
        if get(x,y) == :Empty
          full = false
          break
        end
      end
      if full then
        erace_col << y
      end
    end

    # ブロックが揃った行を消す候補に入れる
    erace_row = []
    @width.times do |x|
      full = true
      @height.times do |y|
        if get(x,y) == :Empty
          full = false
          break
        end
      end
      if full then
        erace_row << x
      end
    end

    # 消す行と列が確定したので邪魔ブロック以外を消す
    erace_row.each do |x|
      @height.times do |y|
        if get(x,y) != :JamaBlock
          set!(x,y,:Empty)
        end
      end
    end
    erace_col.each do |y|
      @width.times do |x|
        if get(x,y) != :JamaBlock
          set!(x,y,:Empty)
        end
      end
    end

  end


  def draw_next_area(x,y,next_mino)
   
    next_mino.take(2).each_with_index do |mino, index|
      sy = y + @cell_size * (index * 5)
      sx = x
      4.times do |yy|
        4.times do |xx|
          index = yy * 4 + xx
          if mino[index] != :Empty
            draw_block_cell(sx+xx*@cell_size,sy+yy*@cell_size,mino[index])
          end
        end
      end
    end
  end
end

# ミノ
class Mino 
  # 現在の形状
  attr_reader :width, :height

  # 初期化
  def initialize(size, shape)
    @size = size
    @shape = shape
    fit!
  end

  # 構成するブロックを取得
  def get(x,y)
    if (0...@size).include?(x) && (0...@size).include?(y) then
      return @shape[x + @size * y]
    end
    return :Empty
  end

  # ブロックを右に回転
  # 右回転 [x,y] -> [@size-1-y, x]
  def rotate_right!()
    ans = @shape.dup
    @size.times do |y|
      @size.times do |x|
        xx = @size-1-y
        yy = x
        ans[xx+@size*yy] = @shape[x+@size*y]
      end
    end
    @shape = ans
    fit!
  end

  # ブロックを左に回転
  # 左回転 [x,y] -> [y, @size-1-x]
  def rotate_left!()
    ans = @shape.dup
    @size.times do |y|
      @size.times do |x|
        xx = y
        yy = @size-1-x
        ans[xx+@size*yy] = @shape[x+@size*y]
      end
    end
    @shape = ans
    fit!
  end

  # 左上にフィットさせて現在の幅と高さを算出
  def fit!()
    # ミノの左右端を探す
    left_edge = @size-1
    right_edge = 0
    @size.times do |y|
      @size.times do |x|
        if @shape[x+@size*y] != :Empty then
          left_edge = [left_edge, x].min
          right_edge = [right_edge, x].max
        end
      end
    end
    
    # ミノの上下端を探す
    top_edge = @size-1
    bottom_edge = 0
    @size.times do |x|
      @size.times do |y|
        if @shape[x+@size*y] != :Empty then
          top_edge = [top_edge, y].min
          bottom_edge = [bottom_edge, y].max
        end
      end
    end
    
    # 左にずらす
    ans1 = Array.new(@size*@size, :Empty)
    @size.times do |y|
      (left_edge...@size).each do |x|
        ans1[(x-left_edge) + @size*y] = @shape[x + @size*y]
      end
    end
    
    # 上にずらす
    ans2 = Array.new(@size*@size, :Empty)
    @size.times do |x|
      (top_edge...@size).each do |y|
        ans2[x + @size*(y-top_edge)] = ans1[x + @size*y]
      end
    end

    # 更新
    @shape = ans2
    @width  = right_edge-left_edge+1
    @height = bottom_edge-top_edge+1
  end
end
