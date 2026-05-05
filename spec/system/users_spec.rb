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
      # トップページに移動する事を確認する
      # expect(page).to have_current_path(root_path)
      # ヘッダーにログアウトボタンが表示される
      expect(page).to have_content('ログアウト')
    end
  end
  context 'ユーザー新規登録ができない時' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      # トップページに移動する
      # 自動的にログインページへ遷移する
      # ログインページにサインアップページへ遷移するボタンがある
      # 新規登録ページへ移動する
      # ユーザー情報を入力する
      # 登録ボタンを押してもUserモデルのカウントが上がらない
      # 新規登録ページへ戻される
    end
  end
end
