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
      # トップページには先ほど登録した睡眠時間記録の日付(0:00～5:00の場合は前日)が表示されているカードが存在することを確認する
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

RSpec.describe '睡眠時間編集' do
  before do
    @user = FactoryBot.create(:user)
    @sleep_record = FactoryBot.create(:sleep_record,user: @user)
  end

  context '睡眠時間が編集できる時' do
    it '睡眠時間を登録したユーザーは編集できる' do
      # 睡眠時間を登録したユーザーでログインする
      sign_in(@user)
      # トップページには登録済みの学習時間記録の日付(0:00～5:00の場合は前日)が表示されているカードが存在することを確認する
      sleep_date_text = I18n.l((@sleep_record.start_time - 5.hour).to_date,format: :long)
      expect(page).to have_selector(".card-header",text: sleep_date_text)
      # 日付が表示されているカード内に睡眠時間記録の編集ページへのリンクがあることを確認する
      within(".card", text: sleep_date_text) do
        expect(page).to have_link('編集',href: edit_sleep_record_path(@sleep_record.id))
      end
      # 編集ページへ遷移する
      visit edit_sleep_record_path(@sleep_record.id)
      # 既に投稿済みの内容がフォームに入っていることを確認する
      end_clock = build_end_clock_from(@sleep_record)
      start_time_value = build_expected_start_time_value(@sleep_record)

      expect(page).to have_field('就寝日時',with: start_time_value)
      expect(page).to have_field('起床時刻',with: end_clock)
      # 投稿内容を編集する
      new_sleep_date = (@sleep_record.start_time - 5.hour).to_date - 1.day
      new_start_time = Time.zone.local(new_sleep_date.year, new_sleep_date.month, new_sleep_date.day, 23, 0)
      new_end_clock = Time.zone.parse("08:00")
      new_end_date = new_sleep_date + 1.day
      new_end_time = Time.zone.local(new_end_date.year, new_end_date.month, new_end_date.day, 8, 0)
      new_sleep_time_text = "9時間0分"

      fill_in '就寝日時', with: new_start_time
      fill_in '起床時刻', with: new_end_clock
      # 送信するとトップページに遷移し、SleepRecordモデルのカウントが変化しないことを確認する
      expect{
        click_button '更新する'
        expect(page).to have_current_path(root_path)
      }.to change { SleepRecord.count }.by(0)
      # トップページには先ほど編集した睡眠時間記録の日時が表示されているカードが存在することを確認する
      sleep_date_text = I18n.l(new_sleep_date,format: :long)
      expect(page).to have_selector(".card-header",text: sleep_date_text)
      # 日付が表示されているカード内に先ほど編集した睡眠時間記録の内容が表示されていることを確認する
      within(".card", text: sleep_date_text) do
        expect(page).to have_content('睡眠時間')
        expect(page).to have_content(I18n.l(new_start_time,format: :time))
        expect(page).to have_content(I18n.l(new_end_time, format: :time))
        expect(page).to have_content new_sleep_time_text
      end
    end
  end
  context '睡眠時間が編集できない時' do
    it '起床時間登録済みの睡眠記録を未完了に編集する事はできない' do
      # 睡眠時間を登録したユーザーでログインする
      # トップページには登録済みの睡眠時間記録の日付(0:00～5:00の場合は前日)が表示されているカードが存在することを確認する
      # 日付が表示されているカード内に睡眠時間記録の編集ページへのリンクがあることを確認する
      # 編集ページへ遷移する
      # 既に登録済みの内容がフォームに入っていることを確認する
      # 起床時刻を削除する
      # 送信するとエラーが表示され、SleepRecordモデルのカウントが変化しないことを確認する
      # 睡眠時間編集画面に戻される事を確認する
    end
    it 'ログインしていないユーザーは編集できない' do
      # トップページに移動する
      # 自動的にログインページに遷移する事を確認する
      # 睡眠時間記録が表示されていない事を確認する
    end
    it '睡眠時間を登録したユーザー以外のユーザーでは編集できない' do
      # 睡眠時間を登録したユーザーとは別のユーザーを用意する
      # 別のユーザーでログインする
      # 睡眠時間記録が表示されていない事を確認する
    end
  end
end
