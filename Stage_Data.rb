class Stage_Data
  attr_reader :tutorial, :easy, :normal, :hard

  def initialize		
    @tutorial = (1..5).each.map { |n| "stage#{n}.yaml" }
    @easy     = (6..10).each.map { |n| "stage#{n}.yaml" }
    @normal   = (11..15).each.map { |n| "stage#{n}.yaml" }
    @hard     = (16..20).each.map { |n| "stage#{n}.yaml" }
  end

  # ステージ設定データをファイルに保存する
  def save_file(path)
    open(path.chomp, 'w') do |file|
      Psych.dump(self, file)
    end
  end

  # ステージ設定データをファイルから読み込む
  def self.load_file(path)
    data = Psych.load_file(path.chomp)
    return data
  end
end
 stagedata = Stage_Data.new
  stagedata.save_file("stagedata.yaml") 
