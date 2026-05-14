require 'rails_helper'

RSpec.describe "睡眠時間登録", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @sleep_record = FactoryBot.build(:sleep_record,user: @user)
  end

  context '睡眠時間が登録できる時' do
    it 'ログインしたユーザーは登録できる' do
      # ログインする
      # 睡眠時間登録ページへのボタンがあることを確認する
      # 睡眠時間登録ページへ移動する
      # フォームに情報を入力する
      # 送信するとトップページに遷移し、SleepRecordモデルのカウントが1上がることを確認する
      # トップページには先ほど登録した睡眠時間記録の日付が表示されているカードが存在することを確認する
      # 日付が表示されているカード内に先ほど登録した睡眠時間記録の内容が表示されていることを確認する
    end
  end
  context '睡眠時間が登録できない時' do
    it 'ログインしていないユーザーは登録できない' do
      # トップページに移動する
      # 自動的にログインページに遷移する事を確認する
      # 睡眠時間登録ページが表示されていない事を確認する
    end
  end
end
