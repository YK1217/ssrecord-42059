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
        expect(response).to have_http_status(:ok)
      end
      it 'newアクションにリクエストすると学習時間登録フォームが表示される' do
        html = Nokogiri::HTML(response.body)

        expect(html.at_css('h1').text).to include("学習時間登録")
        expect(html.at_css('form')).to be_present
      end
      it 'newアクションにリクエストすると学習開始日時の入力欄が表示される' do
        expect(response.body).to include("学習開始日時")
      end
      it 'newアクションにリクエストすると学習終了時刻の入力欄が表示される' do
        expect(response.body).to include("学習終了時刻")
      end
      it 'newアクションにリクエストすると学習メモの入力欄が表示される' do
        expect(response.body).to include("学習内容")
      end
    end

    context 'ログインしていない場合' do
      it 'newアクションにリクエストするとログイン画面へリダイレクトされる' do
      end
    end
  end
end
