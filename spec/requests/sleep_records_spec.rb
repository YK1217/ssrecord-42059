require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }
  let(:other_sleep_record) { create(:sleep_record, user: other_user) }

  describe "GET #new" do
    context 'ログインしている場合' do
      before do
        sign_in user
        get new_sleep_record_path
      end

      it 'newアクションにリクエストすると正常にレスポンスが返ってくる' do
        # expect(response.status).to eq(200)
        expect(response).to have_http_status(:ok)
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
        # expect(response.status).to eq(302)
        expect(response).to have_http_status(:found)
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
          expect {
            post sleep_records_path, params: invalid_params
          }.not_to change(SleepRecord, :count)
        end
        it 'createアクションにリクエストするとnewテンプレートが再表示される' do
          post sleep_records_path, params: invalid_params
          expect(response.body).to include("睡眠時間登録")
          expect(response.body).to include("<form")
        end
        it 'createアクションにリクエストするとunprocessable_contentのステータスコードが返ってくる' do
          post sleep_records_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
    context 'ログインしていない場合' do
        let(:valid_params) do
          {
            sleep_record: attributes_for(:sleep_record, user_id: user.id)
          }
        end
      it 'createアクションにリクエストしてもSleepRecordの数は増えない' do
        expect {
          post sleep_records_path, params: valid_params
        }.not_to change(SleepRecord, :count)
      end
      it 'createアクションにリクエストするとログインページにリダイレクトされる' do
        post sleep_records_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  describe 'GET #edit' do
    context 'ログインしている場合' do
      before do
        sign_in user
        get edit_sleep_record_path(sleep_record)
      end

      it '自分の睡眠記録のeditアクションにリクエストすると正常にレスポンスが返ってくる' do

      end
      it 'editアクションにリクエストすると睡眠時間編集フォームが表示される' do

      end
      it 'editアクションにリクエストすると登録済みの就寝日時が表示される' do
      end
      it 'editアクションにリクエストすると登録済みの起床時刻が表示される' do
      end
      it '他ユーザーの睡眠記録のeditアクションにリクエストするとアクセスできない' do
      end
    end

    context 'ログインしていない場合' do
      it 'editアクションにリクエストするとログインページにリダイレクトされる' do
      end
    end
  end
end
