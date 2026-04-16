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
        @user.name = Faker::Alphanumeric.alphanumeric(number: 11)
        @user.valid?
        expect(@user.errors.full_messages).to include "ユーザー名は10文字以内で入力してください"
      end
      it 'emailが空では登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include "メールアドレスを入力してください"
      end
      it '重複したemailが存在する場合は登録できない' do
        @user.save
        another_user = FactoryBot.build(:user)
        another_user.email = @user.email
        another_user.valid?
        expect(another_user.errors.full_messages).to include "メールアドレスはすでに使用されています"
      end
      it 'emailは@を含まなければ登録できない' do
        @user.email.delete!("@")
        @user.valid?
        expect(@user.errors.full_messages).to include "メールアドレスは不正な値です"
      end
      it 'passwordが空では登録できない' do
        @user.password = ''
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードを入力してください"
      end
      it 'passwordが7文字以下では登録できない' do
        @user.password = Faker::Internet.password(min_length: 2, max_length: 7)
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードは8文字以上で入力してください"
      end
      it 'passwordが129文字以上では登録できない' do
        @user.password = Faker::Internet.password(min_length: 129, max_length: 140)
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードは128文字以内で入力してください"
      end
      it 'passwordが半角でなければ登録できない' do
        @user.password = "ｐａｓｓｗｏｒｄ１２３"
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードは半角英数字のみ使用でき、英字と数字をそれぞれ1文字以上含めてください"
      end
      it 'passwordが半角数字のみでは登録できない' do
        @user.password = "12345678"
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードは半角英数字のみ使用でき、英字と数字をそれぞれ1文字以上含めてください"
      end
      it 'passwordが半角英字のみでは登録できない' do
        @user.password = "password"
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワードは半角英数字のみ使用でき、英字と数字をそれぞれ1文字以上含めてください"
      end
      it 'passwordとpassword_confirmationが一致しない場合は登録できない' do
        @user.password_confirmation = "e8" + Faker::Internet.password(min_length: 6)
        @user.valid?
        expect(@user.errors.full_messages).to include "パスワード（確認用）とパスワードの入力が一致しません"
      end
    end
  end
end
