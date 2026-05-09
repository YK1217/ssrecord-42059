require 'rails_helper'

RSpec.describe "学習時間登録", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @study_record = FactoryBot.build(:study_record,user: @user)
  end

  context '学習時間が登録できる時' do
    it 'ログインしたユーザーは登録できる' do
      # ログインする
      visit root_path
      expect(page).to have_current_path(new_user_session_path)
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      click_button 'ログイン'
      expect(page).to have_current_path(root_path)
      # 学習時間登録ページへのボタンがあることを確認する
      expect(page).to have_content('学習時間登録')
      # 学習時間登録ページへ移動する
      visit new_study_record_path
      # フォームに情報を入力する
      fill_in '学習開始日時', with: @study_record.start_time
      fill_in '学習終了時刻', with: @study_record.end_clock
      fill_in '学習内容', with: @study_record.study_memo
      # 送信するとトップページに遷移し、StudyRecordモデルのカウントが1上がることを確認する
      expect{
        click_button '登録する'
        expect(page).to have_current_path(root_path)
      }.to change { StudyRecord.count }.by(1)
      # トップページには先ほど登録した学習時間記録の日時が表示されているカードが存在することを確認する
      study_date = I18n.l(@study_record.start_time.to_date,format: :long)
      expect(page).to have_selector(".card-header",text: study_date)

      # 日時が表示されているカード内に先ほど登録した学習時間記録の内容が表示されていることを確認する
      within(".card", text: study_date) do
        expect(page).to have_content('学習時間')
        expect(page).to have_content I18n.l(@study_record.start_time,format: :time)
        expect(page).to have_content(@study_record.end_clock)
        expect(page).to have_content(@study_record.study_memo)
      end
    end
  end
  context '学習時間が登録できない時' do
    it 'ログインしていないユーザーは登録できない' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移する事を確認する
      expect(page).to have_current_path(new_user_session_path)
      # 学習時間登録ページへのボタンが表示されていない事を確認する
      expect(page).to have_no_content('学習時間登録')
    end
  end
end
