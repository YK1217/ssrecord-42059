require 'rails_helper'

RSpec.describe "ユーザー新規登録", type: :system do
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
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'ユーザー名', with: @user.name
      fill_in 'メールアドレス', with: @user.email
      fill_in 'パスワード', with: @user.password
      fill_in 'パスワード（確認）', with: @user.password_confirmation
      # 登録ボタンを押すとトップページに移動し、Userモデルのカウントが1上がることを確認する
      expect{
        click_button '新規登録'
        expect(page).to have_current_path(root_path)
      }.to change { User.count }.by(1)
      # ヘッダーにユーザー名とログアウトボタンが表示される
      expect(page).to have_content(@user.name)
      expect(page).to have_content('ログアウト')
    end
  end
  context 'ユーザー新規登録ができない時' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      # トップページに移動する
      visit root_path
      # 自動的にログインページへ遷移する
      expect(page).to have_current_path(new_user_session_path)
      # ログインページにサインアップページへ遷移するボタンがある
      expect(page).to have_content('新規登録')
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'ユーザー名', with: ''
      fill_in 'メールアドレス', with: ''
      fill_in 'パスワード', with: ''
      fill_in 'パスワード（確認）', with: ''
      # 登録ボタンを押すとエラーが表示され、Userモデルのカウントが上がらない
      expect{
        click_button '新規登録'
        expect(page).to have_selector(".alert-danger",text: '入力内容を確認してください')
    }.not_to change { User.count }
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
      expect(page).to have_content(@user.name)
      expect(page).to have_content('ログアウト')
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
      expect(page).to have_selector(".alert-danger",text: 'メールアドレスまたはパスワードが違います。')
      # ログインページへ戻されることを確認する
      expect(page).to have_current_path(new_user_session_path)
    end
  end

end
