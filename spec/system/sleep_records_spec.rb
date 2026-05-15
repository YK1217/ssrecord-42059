require 'rails_helper'

RSpec.describe "睡眠時間登録", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @sleep_record = FactoryBot.build(:sleep_record,user: @user)
  end

  context '睡眠時間が登録できる時' do
    it 'ログインしたユーザーは登録できる' do
      # ログインする
      sign_in(@user)
      # 睡眠時間登録ページへのボタンがあることを確認する
      expect(page).to have_content('睡眠時間登録')
      # 睡眠時間登録ページへ移動する
      visit new_sleep_record_path
      # フォームに情報を入力する
      fill_in '就寝日時', with: @sleep_record.start_time
      fill_in '起床時刻', with: Time.zone.parse(@sleep_record.end_clock)
      # 送信するとトップページに遷移し、SleepRecordモデルのカウントが1上がることを確認する
      expect{
        click_button '登録する'
        expect(page).to have_current_path(root_path)
      }.to change { SleepRecord.count }.by(1)
      # トップページには先ほど登録した睡眠時間記録の日付が表示されているカードが存在することを確認する
      sleep_date_text = I18n.l((@sleep_record.start_time - 5.hour).to_date,format: :long)
      expect(page).to have_selector(".card-header",text: sleep_date_text)
      # 日付が表示されているカード内に先ほど登録した睡眠時間記録の内容が表示されていることを確認する
      end_time = build_end_time_from(@sleep_record)
      sleep_time_text = build_time_difference_from(@sleep_record)

      within(".card", text: sleep_date_text) do
        expect(page).to have_content('睡眠時間')
        expect(page).to have_content(I18n.l(@sleep_record.start_time,format: :time))
        expect(page).to have_content(I18n.l(end_time, format: :time))
        expect(page).to have_content sleep_time_text
      end
    end
  end
  context '睡眠時間が登録できない時' do
    it 'ログインしていないユーザーは登録できない' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移する事を確認する
      expect(page).to have_current_path(new_user_session_path)
      # 睡眠時間登録ページが表示されていない事を確認する
      expect(page).to have_no_content('睡眠時間登録')
    end
  end
end
