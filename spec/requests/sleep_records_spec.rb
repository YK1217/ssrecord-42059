require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { create(:user) }

  describe "GET #new" do
    context 'ログインしている場合' do
      before do
        sign_in user
        get new_sleep_record_path
      end

      it 'newアクションにリクエストすると正常にレスポンスが返ってくる' do
        expect(response.status).to eq(200)
      end
      it 'newアクションにリクエストすると睡眠時間登録フォームが表示される' do
        expect(response.body).to include("睡眠時間登録")
        expect(response.body).to include("<form")
      end
      it 'newアクションにリクエストすると就寝日時の入力欄が表示される' do
        expect(response.body).to include("就寝日時")
      end
      it 'newアクションにリクエストすると起床時刻の入力欄が表示される' do
        expect(response.body).to include("起床時刻")
      end
    end
    context 'ログインしていない場合' do
      before do
        get new_sleep_record_path
      end

      it 'newアクションにリクエストするとログインページにリダイレクトされる' do
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'ログインしている場合' do
      before do
        sign_in user
      end

      context '保存できる値の場合' do
        let(:valid_params) do
          {
            sleep_record: attributes_for(:sleep_record, user_id: user.id)
          }
        end

        it 'createアクションにリクエストするとSleepRecordの数が1増える' do
          expect {
            post sleep_records_path, params: valid_params
          }.to change(SleepRecord, :count).by(1)
        end
        it 'createアクションにリクエストするとトップページにリダイレクトされる' do
          post sleep_records_path, params: valid_params
          expect(response).to redirect_to(root_path)
        end
        it 'createアクションにリクエストすると睡眠時間を登録しましたというメッセージが表示される' do
          post sleep_records_path, params: valid_params
          follow_redirect!
          expect(response.body).to include("睡眠時間を登録しました")
        end
        it '作成された睡眠記録はログイン中のユーザーに紐づく' do
          post sleep_records_path, params: valid_params
          expect(SleepRecord.last.user_id).to eq(user.id)
        end
      end

      context '保存できない値の場合' do
        let(:invalid_params) do
          {
            sleep_record: attributes_for(:sleep_record, user_id: user.id, start_time: nil)
          }
        end

        it 'createアクションにリクエストしてもSleepRecordの数は増えない' do

        end
        it 'createアクションにリクエストするとnewテンプレートが再表示される' do

        end
        it 'createアクションにリクエストするとunprocessable_contentのステータスコードが返ってくる' do
        end
      end
    end
    context 'ログインしていない場合' do
      it 'createアクションにリクエストしてもSleepRecordの数は増えない' do

      end
      it 'createアクションにリクエストするとログインページにリダイレクトされる' do
      end
    end
  end
end
