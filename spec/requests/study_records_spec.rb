require 'rails_helper'

RSpec.describe "StudyRecords", type: :request do
  let(:user) { create(:user) }

  describe 'GET #new' do
    context 'ログインしている場合' do
      before do
        sign_in user
        get new_study_record_path
      end

      it 'newアクションにリクエストすると正常にレスポンスが返ってくる' do
      end
      it 'newアクションにリクエストすると学習時間登録フォームが表示される' do
      end
      it 'newアクションにリクエストすると学習開始時間の入力欄が表示される' do
      end
      it 'newアクションにリクエストすると学習終了時刻の入力欄が表示される' do
      end
      it 'newアクションにリクエストすると学習メモの入力欄が表示される' do
      end
    end

    context 'ログインしていない場合' do
      it 'newアクションにリクエストするとログイン画面へリダイレクトされる' do
      end
    end
  end
end
