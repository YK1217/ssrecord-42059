require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "GET #new" do
    context 'ログインしている場合' do
      before do
        sign_in user
        get new_sleep_record_path
      end

      it 'newアクションにリクエストすると正常にレスポンスが返ってくる' do
      end
      it 'newアクションにリクエストすると睡眠時間登録フォームが表示される' do
      end
      it 'newアクションにリクエストすると就寝時間の入力欄が表示される' do
      end
      it 'newアクションにリクエストすると起床時刻の入力欄が表示される' do
      end
    end
    context 'ログインしていない場合' do
      before do
        get new_sleep_record_path
      end

      it 'newアクションにリクエストするとログインページにリダイレクトされる' do
      end
    end
  end
end
