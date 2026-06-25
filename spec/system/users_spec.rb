require 'rails_helper'

RSpec.describe 'ユーザー新規登録', type: :system do
  before do
    @user = FactoryBot.build(:user)
  end

  context 'ユーザー新規登録ができる時' do
    it '正しい情報を入力すればユーザー新規登録ができてトップページに遷移する' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページへ遷移する
      expect(page).to have_current_path(new_user_session_path)
      # ログインページにサインアップページへ遷移するボタンがある
      expect(page).to have_text('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'ユーザー名', with: @user.name
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      fill_in 'パスワード（確認）', with: @user.password_confirmation
      # 登録ボタンを押すとトップページに移動し、Userモデルのカウントが1上がることを確認する
      expect  do
        click_button '新規登録'
        expect(page).to have_current_path(root_path)
      end.to change { User.count }.by(1)
      # ヘッダーにユーザー名とログアウトボタンが表示される
      within('.navbar') do
        expect(page).to have_text(@user.name)
        expect(page).to have_button('ログアウト')
      end
    end
  end

  context 'ユーザー新規登録ができない時' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページへ遷移する
      expect(page).to have_current_path(new_user_session_path)
      # ログインページにサインアップページへ遷移するボタンがある
      expect(page).to have_text('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'ユーザー名', with: ''
      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: ''
      fill_in 'パスワード（確認）', with: ''
      # 登録ボタンを押すとエラーが表示され、Userモデルのカウントが上がらない
      expect  do
        click_button '新規登録'
        expect(page).to have_css('.alert-danger', text: '入力内容を確認してください')
      end.not_to(change { User.count })
      # 新規登録ページへ戻される
      expect(page).to have_current_path(new_user_registration_path)
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'ログインができる時' do
    it '保存されているユーザーの情報と合致すればログインができる' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移する
      expect(page).to have_current_path(new_user_session_path)
      # 正しいユーザー情報を入力する
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      # ログインボタンを押す
      click_button 'ログイン'
      # トップページに遷移することを確認する
      expect(page).to have_current_path(root_path)
      # ヘッダーにユーザー名とログアウトボタンが表示される
      within('.navbar') do
        expect(page).to have_text(@user.name)
        expect(page).to have_button('ログアウト')
      end
    end
  end

  context 'ログインできない時' do
    it '保存されているユーザーの情報と合致しなければログインできない' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページに遷移する
      expect(page).to have_current_path(new_user_session_path)
      # 正しくないユーザー情報を入力する
      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: ''
      # ログインボタンを押す
      click_button 'ログイン'
      # エラーメッセージが表示されることを確認する
      expect(page).to have_css('.alert-danger', text: 'メールアドレスまたはパスワードが違います。')
      # ログインページへ戻されることを確認する
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end

RSpec.describe 'ログイン中のユーザー情報の編集', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  context 'ユーザー情報の編集ができる時' do
    it '正しい情報を入力すればユーザー情報を編集することができる' do
      # ログインする
      sign_in(@user)
      # ヘッダーにマイページへのリンクがあることを確認する
      within('.navbar') do
        expect(page).to have_link('マイページ', href: user_path)
      end
      # マイページへ移動する
      visit user_path
      # ユーザー情報編集ボタンがあることを確認する
      expect(page).to have_link('ユーザー情報編集', href: edit_user_registration_path)
      # 編集ページへ遷移する
      visit edit_user_registration_path
      # ログイン中のユーザー情報の内容がフォームに入っていることを確認する
      expect(page).to have_field('ユーザー名', with: @user.name)
      expect(page).to have_field('メールアドレス', with: @user.email)
      expect(page).to have_field('パスワード', with: nil)
      expect(page).to have_field('パスワード（確認）', with: nil)
      # ユーザー情報を編集する
      fill_in 'ユーザー名', with: 'testuser'
      fill_in 'メールアドレス', with: 'test@example.com'
      fill_in 'パスワード', with: 'newpassword123'
      fill_in 'パスワード（確認）', with: 'newpassword123'
      # 更新前のパスワードを入力する
      fill_in '現在のパスワード', with: @user.password
      # 送信するとマイページに遷移し、Userモデルのカウントが変化しないことを確認する
      expect  do
        click_button '更新'
        expect(page).to have_current_path(user_path)
      end.not_to(change { User.count })
      # マイページには先ほど編集したユーザー情報が表示されていることを確認する
      within('.card-body') do
        expect(page).to have_text('testuser')
        expect(page).to have_text('test@example.com')
      end
    end
  end
  context 'ユーザー情報の編集ができない時' do
    it '誤った情報を入力すればユーザー情報を編集することができない' do
      # ログインする
      sign_in(@user)
      # ヘッダーにマイページへのリンクがあることを確認する
      # マイページへ移動する
      # ユーザー情報編集ボタンがあることを確認する
      # 編集ページへ遷移する
      # ログイン中のユーザー情報の内容がフォームに入っていることを確認する
      # ユーザー情報を編集する
      # 更新前のパスワードを入力する
      # 送信するとエラーが表示され、Userモデルのカウントが変化しないことを確認する
      # ユーザー情報編集画面に戻されることを確認する
    end
  end
end
