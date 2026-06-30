require 'rails_helper'

def concentration_level_label(level)
  level.to_i.zero? ? '評価なし' : level.to_s
end

RSpec.describe '学習時間登録', type: :system do
  before do
    @user = FactoryBot.create(:user)
    @study_record = FactoryBot.build(:study_record, user: @user, concentration_level: 3)
  end

  context '学習時間が登録できる時' do
    it 'ログインしたユーザーは登録できる' do
      # ログインする
      sign_in(@user)
      # 学習時間登録ページへのボタンがあることを確認する
      expect(page).to have_text('学習時間登録')
      # 学習時間登録ページへ移動する
      visit new_study_record_path
      # フォームに情報を入力する
      fill_in '学習開始日時', with: @study_record.start_time
      fill_in '学習終了時刻', with: Time.zone.parse(@study_record.end_clock)
      fill_in '学習内容', with: @study_record.study_memo
      within('[data-testid="concentration-level-field"]') do
        choose concentration_level_label(@study_record.concentration_level)
      end
      # 送信するとトップページに遷移し、StudyRecordモデルのカウントが1上がることを確認する
      expect  do
        click_button '登録する'
        expect(page).to have_current_path(root_path)
      end.to change { StudyRecord.count }.by(1)
      # トップページには先ほど登録した学習時間記録の日付が表示されているカードが存在することを確認する
      study_date_text = I18n.l(@study_record.start_time.to_date, format: :long)
      expect(page).to have_css('.card-header', text: study_date_text)

      # 日付が表示されているカード内に先ほど登録した学習時間記録の内容が表示されていることを確認する

      end_time = build_end_time_from(@study_record)
      study_time_text = build_time_difference_from(@study_record)

      within('.card', text: study_date_text) do
        expect(page).to have_text('学習時間')
        expect(page).to have_text(I18n.l(@study_record.start_time, format: :time))
        expect(page).to have_text(I18n.l(end_time, format: :time))
        expect(page).to have_text study_time_text
        expect(page).to have_text concentration_level_label(@study_record.concentration_level)
        expect(page).to have_text(@study_record.study_memo)
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
      expect(page).to have_no_text('学習時間登録')
    end
  end
end

RSpec.describe '学習時間編集' do
  before do
    @user = FactoryBot.create(:user)
    @study_record = FactoryBot.create(:study_record, user: @user, concentration_level: 3)
  end

  context '学習時間が編集できる時' do
    it '学習時間を登録したユーザーは編集できる' do
      # 学習時間を登録したユーザーでログインする
      sign_in(@user)
      # トップページには登録済みの学習時間記録の日付が表示されているカードが存在することを確認する
      study_date_text = I18n.l(@study_record.start_time.to_date, format: :long)
      expect(page).to have_css('.card-header', text: study_date_text)
      # 日付が表示されているカード内に学習時間記録の編集ページへのリンクがあることを確認する
      within('.card', text: study_date_text) do
        expect(page).to have_link('編集', href: edit_study_record_path(@study_record.id))
      end
      # 編集ページへ遷移する
      visit edit_study_record_path(@study_record.id)
      # 既に投稿済みの内容がフォームに入っていることを確認する
      end_clock = build_end_clock_from(@study_record)
      start_time_value = build_expected_start_time_value(@study_record)

      expect(page).to have_field('学習開始日時', with: start_time_value)
      expect(page).to have_field('学習終了時刻', with: end_clock)
      expect(page).to have_field('学習内容', with: @study_record.study_memo)
      within('[data-testid="concentration-level-field"]') do
        expect(page).to have_checked_field(concentration_level_label(@study_record.concentration_level))
      end
      # 投稿内容を編集する
      new_study_date = @study_record.start_time.to_date - 1.day
      new_start_time = Time.zone.local(new_study_date.year, new_study_date.month, new_study_date.day, 9, 0)
      new_end_clock = Time.zone.parse('15:00')
      new_end_time = Time.zone.local(new_study_date.year, new_study_date.month, new_study_date.day, 15, 0)
      new_study_time_text = '6時間0分'
      new_concentration_level_text = '4'
      new_study_memo = 'テストメモ'

      fill_in '学習開始日時', with: new_start_time
      fill_in '学習終了時刻', with: new_end_clock
      fill_in '学習内容', with: new_study_memo, fill_options: { clear: :backspace }
      within('[data-testid="concentration-level-field"]') do
        choose new_concentration_level_text
      end
      # 送信するとトップページに遷移し、StudyRecordモデルのカウントが変化しないことを確認する
      expect  do
        click_button '更新する'
        expect(page).to have_current_path(root_path)
      end.not_to(change { StudyRecord.count })
      # トップページには先ほど編集した学習時間記録の日時が表示されているカードが存在することを確認する
      study_date_text = I18n.l(new_study_date, format: :long)
      expect(page).to have_css('.card-header', text: study_date_text)
      # 日付が表示されているカード内に先ほど編集した学習時間記録の内容が表示されていることを確認する
      within('.card', text: study_date_text) do
        expect(page).to have_text('学習時間')
        expect(page).to have_text(I18n.l(new_start_time, format: :time))
        expect(page).to have_text(I18n.l(new_end_time, format: :time))
        expect(page).to have_text new_study_time_text
        expect(page).to have_text(new_concentration_level_text)
        expect(page).to have_text new_study_memo
      end
    end
  end

  context '学習時間が編集できない時' do
    it '学習終了時間登録済みの学習時間記録を未完了に編集する事はできない' do
      # 学習時間を登録したユーザーでログインする
      sign_in(@user)
      # トップページには登録済みの学習時間記録の日付が表示されているカードが存在することを確認する
      study_date_text = I18n.l(@study_record.start_time.to_date, format: :long)
      expect(page).to have_css('.card-header', text: study_date_text)
      # 日付が表示されているカード内に学習時間記録の編集ページへのリンクがあることを確認する
      within('.card', text: study_date_text) do
        expect(page).to have_link('編集', href: edit_study_record_path(@study_record.id))
      end
      # 編集ページへ遷移する
      visit edit_study_record_path(@study_record.id)
      # 既に登録済みの内容がフォームに入っていることを確認する
      end_clock = build_end_clock_from(@study_record)
      start_time_value = build_expected_start_time_value(@study_record)

      expect(page).to have_field('学習開始日時', with: start_time_value)
      expect(page).to have_field('学習終了時刻', with: end_clock)
      expect(page).to have_field('学習内容', with: @study_record.study_memo)
      within('[data-testid="concentration-level-field"]') do
        expect(page).to have_checked_field(concentration_level_label(@study_record.concentration_level))
      end
      binding.pry
      # 学習終了時刻を削除する
      fill_in '学習終了時刻', with: ''
      # 送信するとエラーが表示され、StudyRecordモデルのカウントが変化しないことを確認する
      expect  do
        click_button '更新する'
        expect(page).to have_css('.alert-danger', text: '入力内容を確認してください')
      end.not_to(change { StudyRecord.count })
      # 学習時間編集画面に戻される事を確認する
      expect(page).to have_current_path(edit_study_record_path(@study_record.id))
    end

    it 'ログインしていないユーザーは編集できない' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移する事を確認する
      expect(page).to have_current_path(new_user_session_path)
      # 学習時間記録が表示されていない事を確認する
      expect(page).to have_no_text('学習時間')
      expect(page).to have_no_link('編集', href: edit_study_record_path(@study_record.id))
    end

    it '学習時間を登録したユーザー以外のユーザーでは編集できない' do
      # 学習時間を登録したユーザーとは別のユーザーを用意する
      another_user = FactoryBot.create(:user)
      # 別のユーザーでログインする
      sign_in(another_user)
      # 学習時間記録が表示されていない事を確認する
      study_date_text = I18n.l(@study_record.start_time.to_date, format: :long)
      expect(page).to have_no_selector('.card-header', text: study_date_text)
      expect(page).to have_no_link('編集', href: edit_study_record_path(@study_record.id))
    end
  end
end

RSpec.describe '学習時間削除' do
  before do
    @user = FactoryBot.create(:user)
    @study_record = FactoryBot.create(:study_record, user: @user)
  end

  context '学習時間が削除できる時' do
    it '学習時間を登録したユーザーは削除できる' do
      # 学習時間を登録したユーザーでログインする
      sign_in(@user)
      # トップページには登録済みの学習時間記録の日付が表示されているカードが存在することを確認する
      study_date_text = I18n.l(@study_record.start_time.to_date, format: :long)

      expect(page).to have_css('.card-header', text: study_date_text)
      # 日付が表示されているカード内に学習時間記録の開始時間が表示され、同じ行に削除ボタンがあることを確認する
      start_time_text = I18n.l(@study_record.start_time, format: :time)

      within('.card', text: study_date_text) do
        expect(page).to have_text(start_time_text)

        within('tr', text: start_time_text) do
          expect(page).to have_text('学習時間')
          expect(page).to have_link('削除', href: study_record_path(@study_record.id))
        end
      end

      # 削除ボタンをクリックし、確認ダイアログでOKをクリックするとトップページに遷移し、学習時間記録が1減ることを確認する
      expect do
        accept_confirm 'この学習記録を削除しますか？' do
          find_link('削除', href: study_record_path(@study_record.id)).click
        end
        expect(page).to have_current_path(root_path)
        expect(page).to have_css('.alert-success', text: '学習時間を削除しました')
      end.to change { StudyRecord.count }.by(-1)
      # トップページには削除した学習時間記録の日付が表示されているカードが存在しないことを確認する
      expect(page).to have_no_selector('.card-header', text: study_date_text)
    end
  end

  context '学習時間が削除できない時' do
    it 'ログインしていないユーザーは削除できない' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移することを確認する
      expect(page).to have_current_path(new_user_session_path)
      # 学習時間の削除ボタンが表示されていないことを確認する
      expect(page).to have_no_link('削除', href: study_record_path(@study_record.id))
    end

    it '学習時間を登録したユーザー以外のユーザーでは削除できない' do
      # 学習時間を登録したユーザーとは別のユーザーを用意する
      another_user = FactoryBot.create(:user)
      # 別のユーザーでログインする
      sign_in(another_user)
      # 学習時間の削除ボタンが表示されていないことを確認する
      expect(page).to have_no_link('削除', href: study_record_path(@study_record.id))
    end
  end
end
