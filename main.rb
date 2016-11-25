#
# ゲームプログラムメイン部分
#

# ゲーム作りが楽になるライブラリ！
require_relative 'game.rb'
require_relative 'Board.rb'
require_relative 'Mino.rb'
require_relative 'Tetromino.rb'
require_relative 'Stage_Data.rb'


#
# ここから下でゲームの設定
#

# ゲーム画面の大きさ
WINDOW_WIDTH  = 800
WINDOW_HEIGHT = 600

# デバッグモード
DEBUG = false

#
# ここから下がゲーム本体
#

# ゲーム
class Game

  # 初期化
  def initialize
    # 画面のサイズを設定
    Window.width = WINDOW_WIDTH
    Window.height = WINDOW_HEIGHT

    # フォントの準備
    Font.install('./Font/IPAexfont00301/ipaexg.ttf')
    @font = Font.new(20, 'IPAexゴシック', { :weight=>false, :italic => false })

    # シーンの準備
    @scene = :title
    @params = nil

    @selectable = {
      :Tutorial => true
    }
    if File.exist?("selectable")
      @selectable = Psych.load_file("selectable") 
    end

    @sound_ba = Sound.new("sound/backsound.wav")
    @sound_bu = Sound.new("sound/button.wav")
    @sound_cl = Sound.new("sound/clear.wav")
    @sound_no = Sound.new("sound/clickno.wav")
    @sound_ok = Sound.new("sound/clickok.wav")
    @sound_ov = Sound.new("sound/gameover.wav")

  end

  # 実行
  def run
    while methods.include?(@scene) do
      (@scene, @params) = send(@scene, *@params)
    end
  end

  # タイトル
  def title()
    start_bmp = Image.load("image/start.bmp")
    ret = scene do
      Window.draw(0,0,start_bmp)
      #Window.draw_font( 50, 100, "タイトル画面" ,@font, {:color=> [255,0,0] })
      #Window.draw_font( 50, 200, "スペースキーで盤面編集画面へ" ,@font, {:color=> [255,0,0] })
      #Window.draw_font( 50, 250, "クリックでゲーム画面へ" ,@font, {:color=> [255,0,0] })
      #if Input.key_push?(K_SPACE) # K_A -> Aキーを指定
      #  log "スペースキーが押された"
      #  break :SPACE
      #end
      if Input.mouse_push?(M_LBUTTON)
        log "マウスがクリックされた"
        @sound_bu.play
        break :CLICK
      end
    end

    #if ret == :SPACE
    #  log "スペースキーが押されたので編集画面へ"
    #  return :stage_edit
    if ret == :CLICK
      log "マウスがクリックされたのでゲーム本編へ"
      a = (1..20).each.map { |n| "stage#{n}.yaml" }
      return :stage_select
     
    else
      log "想定外なので再度タイトルへ"
      return :title
    end
  end
  
  #ステージ選択画面
  def stage_select() 
    select1 = Image.load("image/select1.bmp")
    key = Image.load("image/key.png")

    btn_tutorial = Rectangle.new(53, 130, 476, 77)
    btn_Easy = Rectangle.new(62, 221, 251, 71)
    btn_Normal = Rectangle.new(65, 301, 361, 76)
    btn_Hard = Rectangle.new(66, 399, 261, 73)
    btn_Edit = Rectangle.new(456, 408, 168, 66)

    ret = scene do

      Window.draw(0,0,select1)

      
      if @selectable[:Easy] != true
        left = btn_Easy.left + btn_Easy.width  / 2 - key.width  / 2
        top  = btn_Easy.top  + btn_Easy.height / 2 - key.height / 2
        Window.draw(left,top,key)
      end
      if @selectable[:Normal] != true
        left = btn_Normal.left + btn_Normal.width  / 2 - key.width  / 2
        top  = btn_Normal.top  + btn_Normal.height / 2 - key.height / 2
        Window.draw(left,top,key)
      end
      if @selectable[:Hard] != true
        left = btn_Hard.left + btn_Hard.width  / 2 - key.width  / 2
        top  = btn_Hard.top  + btn_Hard.height / 2 - key.height / 2
        Window.draw(left,top,key)
      end
      #Window.draw_font( 50, 100, "タイトル画面" ,@font, {:color=> [255,0,0] })
      #Window.draw_font( 50, 200, "スペースキーで盤面編集画面へ" ,@font, {:color=> [255,0,0] })
      #Window.draw_font( 50, 250, "クリックでゲーム画面へ" ,@font, {:color=> [255,0,0] })
      #if Input.key_push?(K_SPACE) # K_A -> Aキーを指定
      #  log "スペースキーが押された"
      #  break :SPACE
      #end
      if Input.mouse_push?(M_LBUTTON)
        log "マウスがクリックされた"

# チュートリアルをクリックした？
        if btn_tutorial.hit?(Input.mouse_pos_x, Input.mouse_pos_y) && @selectable[:Tutorial] == true
          @sound_bu.play
          break :Tutorial
        end

# 初級をクリックした？
        if btn_Easy.hit?(Input.mouse_pos_x, Input.mouse_pos_y) && @selectable[:Easy] == true
          @sound_bu.play
          break :Easy
        end
# 中級をクリックした？
        if btn_Normal.hit?(Input.mouse_pos_x, Input.mouse_pos_y) && @selectable[:Normal] == true
          @sound_bu.play
          break :Normal
        end
# 上級をクリックした？
        if btn_Hard.hit?(Input.mouse_pos_x, Input.mouse_pos_y) && @selectable[:Hard] == true
          @sound_bu.play
          break :Hard
        end
# エディットをクリックした？
        if btn_Edit.hit?(Input.mouse_pos_x, Input.mouse_pos_y)
          @sound_bu.play
          break :stage_edit
        end
# それ以外はなにもしない

      end
    end

    if ret == :stage_edit
      log "マウスが押されたので編集画面へ"
      return :stage_edit
    end
    stagedata = Stage_Data.load_file("stagedata.yaml")
    if ret == :Tutorial
      log "マウスがクリックされたのでTutorialへ"
      a = stagedata.tutorial
      return :stage_main, [a, :Easy]
    elsif ret == :Easy
      log "マウスがクリックされたのでEasyへ"
      a = stagedata.easy
      return :stage_main, [a, :Normal]
    elsif ret == :Normal
      log "マウスがクリックされたのでNormalへ"
      a = stagedata.normal
      return :stage_main, [a, :Hard]
    elsif ret == :Hard
      log "マウスがクリックされたのでHardへ"
      a = stagedata.hard
      return :stage_main, [a,:Hardest]
    else
      log "想定外なので再度タイトルへ"
      return :title
    end
  end


  # ステージセレクト
  def stage_select_old
    #file = ComDlg32::GetOpenFileName("読み込み先ファイルを指定", "YAML (*.yaml)\0*.yaml\0\0")
    file = Window.open_filename([["YAML (*.yaml)","*.yaml"]],"読み込み先ファイルを指定")
    if file != ""
      return :stage_main, [file]
    else
      return :title
    end
  end

  # ゲーム本編
  def stage_main(stage_files, unlock_next)

    # パスできる数
    pass_max = 3

    # 盤面を読み込む
    mainscreen = Image.load("image/mainscreen.bmp")
    board = Board.load_file(stage_files.first)

    #@sound_ba.play

    # ミノを作る
    #nextmino = Tetromino.sample(3)
    #mino = Mino.new(4,nextmino.shift)
    nextmino = board.minos.map do |x| 
      if x == -1
        Tetromino.sample
      else
        Tetromino[x]
      end
    end
    while nextmino.length < 3 do
      nextmino += board.minos.map do |x| 
        if x == -1
          Tetromino.sample
        else
          Tetromino[x]
        end
      end
    end
    mino = Mino.new(4,nextmino.shift)
    
    #パスボタンの位置
    btn_pass = Rectangle.new(612, 475, 109, 105)
    #パスのカウントを０へ
    passcount = 0
    #バツの位置
    btn_batu = Rectangle.new(8, 12, 32, 30)

    # パズルシーンを表示
    ret = scene do
      Window.draw(0,0,mainscreen)
      Window.draw_font( 30, 395, board.message ,@font, {:color=> [255,0,0] })

      #Window.draw_font( 0, 0, "左クリック:ブロック配置 | 右クリック:ブロック回転 | ESC:タイトルへ" ,@font, {:color=> [255,0,0] })

      # マウスカーソルの位置に対応する盤面上の位置を求めておく
      cx, cy = board.to_cell_pos(Input.mouse_pos_x - 100,Input.mouse_pos_y - 100)

      # 盤面を描く
      board.draw(100, 100, mino, cx, cy)
      board.draw_next_area(640, 55,nextmino)

      # カーソルのあるマス目が盤面上か判定
      if board.hit?(cx, cy)

        # 左クリックされた？
        if Input.mouse_push?(M_LBUTTON) then

          # 盤面にミノが置けるか判定
          if board.placeable?(cx, cy, mino)

            # 置けるので置く
            board.set_mino!(cx, cy, mino)
            @sound_bu.play

            # 消えるラインのチェックを行って消す
            board.check_and_erace!

            # クリア条件を満たしてたらクリアにする
            if board.complete?
              break :StageClear
            end

            # ゲームオーバー条件を満たしてたらゲームオーバーにする
            need_mino_cnt = pass_max - passcount +1
            current_minos = ([mino]+nextmino.map{|x| Mino.new(4,x)}.to_a())
            if board.gameover?(need_mino_cnt, current_minos)
              break :GameOver
            end

            # ミノを更新する
            while nextmino.length < 3 do
              nextmino += board.minos.map do |x| 
                if x == -1
                  Tetromino.sample
                else
                  Tetromino[x]
                end
              end
            end
            mino = Mino.new(4,nextmino.shift)

          end

        elsif Input.mouse_push?(M_RBUTTON)
          # 右クリックでブロックを回転
          mino.rotate_right!
        end
      end
      
      if Input.mouse_push?(M_LBUTTON)
        log "マウスがクリックされた"

        # パスをクリックした？
        if btn_pass.hit?(Input.mouse_pos_x, Input.mouse_pos_y)
          # ミノを更新する
          if (passcount < pass_max)
            while nextmino.length < 3 do
              nextmino += board.minos.map do |x| 
                if x == -1
                  Tetromino.sample
                else
                  Tetromino[x]
                end
              end
            end
            mino = Mino.new(4,nextmino.shift)

            passcount += 1

            # ゲームオーバー条件を満たしてたらゲームオーバーにする
            need_mino_cnt = pass_max - passcount +1
            current_minos = ([mino]+nextmino.map{|x| Mino.new(4,x)}.to_a())
            if board.gameover?(need_mino_cnt, current_minos)
              break :GameOver
            end

          else
            break :GameOver
          end
        end
      end

      # エスケープキーでタイトルに戻る
     if Input.mouse_push?(M_LBUTTON)
      if btn_batu.hit?(Input.mouse_pos_x, Input.mouse_pos_y)
        log "ばつが押されたのでタイトルに戻る"
        break :Exit
     end
      end

    end

    # シーン結果で分岐
    if ret == :StageClear
      log "クリア"
      stage_files.shift
      return :stage_complete, [stage_files, unlock_next]
    elsif ret == :GameOver
      log "ゲームオーバー"
      return :stage_fail, [stage_files, unlock_next]
    elsif ret == :Exit
      log "タイトルへ"
      return :title
    end
  end

  # クリア
  def stage_complete(stage_files, unlock_next)
    clear_bmp = Image.load("image/clear.bmp")
    #@sound_ba.stop
    @sound_cl.play
    scene do
      Window.draw(0,0,clear_bmp)
      #Window.draw_font( 50, 200, "ステージクリア!!" ,@font, {:color=> [255,0,0] })
      if Input.mouse_push?(M_LBUTTON)
        break
      end
    end

    if stage_files.any?
      return :stage_main, [stage_files,unlock_next]
    else
      @selectable[unlock_next] = true
      open("selectable", 'w') do |file|
        Psych.dump(@selectable, file)
      end
      return :title
    end
  end

  # 失敗
  def stage_fail(stage_files, unlock_next)
    gameover_bmp = Image.load("image/gameover.bmp")
    btn_retry = Rectangle.new(131, 390, 225, 56)
    btn_ending = Rectangle.new(450, 391, 214, 59)
    #@sound_ba.stop
    @sound_ov.play
    ret = scene do
      Window.draw(0,0,gameover_bmp)
      #Window.draw_font( 50, 200, "ステージ失敗！" ,@font, {:color=> [255,0,0] })
      # もう一度をクリックした？
      if Input.mouse_push?(M_LBUTTON)
        if btn_retry.hit?(Input.mouse_pos_x, Input.mouse_pos_y) 
          break :StageRetry
        end
      end
      # 終了するをクリックした？
      if Input.mouse_push?(M_LBUTTON)
        if btn_ending.hit?(Input.mouse_pos_x, Input.mouse_pos_y) 
        break :Exit
        end
      end
    end

    # シーン結果で分岐
    if ret == :StageRetry
      log "再挑戦"
      return :stage_main, [stage_files, unlock_next]
    elsif ret == :Exit
      log "タイトルへ"
      return :title
    end
  end

  # ステージ編集画面
  def stage_edit()
    # 盤面を作る
    board = Board.new(32,8,8)

    mainscreen2 = Image.load("image/mainscreen5.png")

    # 選択ブロックの表を作っておく
    blocks = [:Empty, :Block1, :JamaBlock, :Star]
    blocknames = ["空ブロック", "ブロック", "邪魔ブロック", "星ブロック"]
    selected_block = 0

    # 編集シーンを表示
    ret = scene do
      Window.draw(0,0,mainscreen2)

      Window.draw_font( 20, 400, "F1:保存 | F2:読み込み | F12:全消去 | ESC:タイトルへ" ,@font, {:color=> [0,0,0] })
      Window.draw_font( 20, 430, "F5:盤面の幅-1 | F6:盤面の幅+1 | F7:盤面の高さ-1 | F8:盤面の高さ+1" ,@font, {:color=> [0,0,0] })
      Window.draw_font( 20, 460, "左クリック:ブロック配置 | 右クリック:配置ブロック変更 (選択=#{blocknames[selected_block]})" ,@font, {:color=> [0,0,0] })

      # マウスカーソルの位置に対応する盤面上の位置を求めておく
      cx, cy = board.to_cell_pos(Input.mouse_pos_x - 100,Input.mouse_pos_y - 100)

      # 盤面を描く
      board.draw(100, 100, nil, cx, cy)

      # カーソルのあるマス目が盤面上か判定
      if board.hit?(cx, cy)

        # ボード上に仮ブロックを描く
        board.draw_block(100, 100, cx, cy, :Temp)

        # 左クリックされた？
        if Input.mouse_push?(M_LBUTTON)

          # 盤面上か判定
          if board.hit?(cx, cy)
            # 盤面上なのでブロックを置く
            board.set!(cx, cy, blocks[selected_block])
          end

        elsif Input.mouse_push?(M_RBUTTON)
          # 右クリックでブロックを変更
          selected_block = (selected_block + 1) % blocks.length
        end
      end

      if Input.key_push?(K_F1)
        log "F1が押されたので保存"

        #file = ComDlg32::GetSaveFileName("保存先ファイルを指定", "YAML (*.yaml)\0*.yaml\0\0")
        file = Window.save_filename([["YAML (*.yaml)","*.yaml"]],"保存先ファイルを指定")
        if file != ""
          board.save_file(file)
          #User32::MessageBox(0, "盤面データを保存しました。", "確認", User32::MB_OK)
        end
      end
      if Input.key_push?(K_F2)
        log "F2が押されたので読み込み"

        #file = ComDlg32::GetOpenFileName("読み込み先ファイルを指定", "YAML (*.yaml)\0*.yaml\0\0")
        file = Window.open_filename([["YAML (*.yaml)","*.yaml"]],"読み込み先ファイルを指定")
        if file != ""
          board = Board.load_file(file)
          #User32::MessageBox(0, "盤面データを読み込みました。", "確認", User32::MB_OK)
        end
      end

      if Input.key_push?(K_F5)
        log "F5が押されたので盤面の横幅を-1する"
        board.resize!(board.width-1, board.height)
      end
      if Input.key_push?(K_F6)
        log "F6が押されたので盤面の横幅を+1する"
        board.resize!(board.width+1, board.height)
      end
      if Input.key_push?(K_F7)
        log "F7が押されたので盤面の縦幅を-1する"
        board.resize!(board.width, board.height-1)
      end
      if Input.key_push?(K_F8)
        log "F8が押されたので盤面の縦幅を+1する"
        board.resize!(board.width, board.height+1)
      end

      if Input.key_push?(K_F12)
        log "F12が押されたのでデータ消去"
        board.clear!
      end

      # エスケープキーでタイトルに戻る
      if Input.key_push?(K_ESCAPE)
        log "エスケープキーが押されたのでタイトルに戻る"
        break :Exit
      end
    end

    return :title
  end
end

# ゲーム開始
Game.new().run()
