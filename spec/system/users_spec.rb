require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    @user = FactoryBot(:user)
  end

  context 'ユーザー新規登録ができる時' do
    it '正しい情報を入力すればユーザー新規登録ができてトップページに遷移する' do

    end
  end
  context 'ユーザー新規登録ができない時' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do

    end
  end
end
