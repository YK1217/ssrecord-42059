require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'ユーザー新規登録' do
    context '新規登録できるとき' do
      it 'nameとemail、password、password_confirmationが存在すれば登録できる' do
        expect(@user).to be_valid
      end
    end
    context '新規登録できないとき' do
      it 'nameが空では登録できない' do
        @user.name = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "ユーザー名を入力してください"
      end
      it 'nameが11文字以上では登録できない' do

      end
      it 'emailが空では登録できない' do

      end
      it '重複したemailが存在する場合は登録できない' do

      end
      it 'emailは@を含まなければ登録できない' do

      end
      it 'passwordが空では登録できない' do

      end
      it 'passwordが7文字以下では登録できない' do

      end
      it 'passwordが129文字以上では登録できない' do

      end
      it 'passwordが半角でなければ登録できない' do

      end
      it 'passwordが半角数字のみでは登録できない' do

      end
      it 'passwordが半角英字のみでは登録できない' do

      end
      it 'passwordとpassword_confirmationが一致しない場合は登録できない' do

      end
    end
  end
end
