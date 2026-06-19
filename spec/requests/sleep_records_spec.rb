require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }
  let(:other_sleep_record) { create(:sleep_record, user: other_user) }

  def build_expected_start_time_local_value(record)
    record.start_time.localtime.strftime("%Y-%m-%dT%H:%M:%S")
  end

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
        html = Nokogiri::HTML(response.body)

        expect(html.at_css('h1').text).to include("睡眠時間登録")
        expect(html.at_css('form')).to be_present
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
            sleep_record: attributes_for(:sleep_record, user: user)
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
            sleep_record: attributes_for(:sleep_record, user: user, start_time: nil)
          }
        end

        it 'createアクションにリクエストしてもSleepRecordの数は増えない' do
          expect {
            post sleep_records_path, params: invalid_params
          }.not_to change(SleepRecord, :count)
        end
        it 'createアクションにリクエストするとnewテンプレートが再表示される' do
          post sleep_records_path, params: invalid_params

          html = Nokogiri::HTML(response.body)
          expect(html.at_css('h1').text).to include("睡眠時間登録")
          expect(html.at_css('form')).to be_present
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
            sleep_record: attributes_for(:sleep_record, user: user)
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
        expect(response).to have_http_status(:ok)
      end
      it 'editアクションにリクエストすると睡眠時間編集フォームが表示される' do
        html = Nokogiri::HTML(response.body)
        expect(html.at_css('h1').text).to include("睡眠時間編集")
      end
      it 'editアクションにリクエストすると登録済みの就寝日時が表示される' do
        html = Nokogiri::HTML(response.body)
        start_time_value = build_expected_start_time_local_value(sleep_record)
        expect(html.at_css('input[name="sleep_record[start_time]"]')['value']).to eq(start_time_value)
      end
      it 'editアクションにリクエストすると登録済みの起床時刻が表示される' do
        html = Nokogiri::HTML(response.body)
        end_clock_value = build_end_clock_from(sleep_record)
        expect(html.at_css('input[name="sleep_record[end_clock]"]')['value']).to eq(end_clock_value)
      end
      it '他ユーザーの睡眠記録のeditアクションにリクエストするとアクセスできない' do
        get edit_sleep_record_path(other_sleep_record)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'ログインしていない場合' do
      it 'editアクションにリクエストするとログインページにリダイレクトされる' do
        get edit_sleep_record_path(sleep_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'ログインしている場合' do
      before do
        sign_in user
      end

      context '更新できる値の場合' do

        let(:valid_params) do
          {
            sleep_record: attributes_for(:sleep_record, user: user)
        }
        end

        it 'updateアクションにリクエストすると睡眠記録が更新される' do
          patch sleep_record_path(sleep_record), params: valid_params
          expect(sleep_record.reload.start_time).to eq(valid_params[:sleep_record][:start_time])
        end
        it 'updateアクションにリクエストするとトップページにリダイレクトされる' do
          patch sleep_record_path(sleep_record), params: valid_params
          expect(response).to redirect_to(root_path)
        end
        it 'updateアクションにリクエストすると睡眠時間を更新しましたというメッセージが表示される' do
          patch sleep_record_path(sleep_record), params: valid_params
          follow_redirect!
          expect(response.body).to include("睡眠時間を更新しました")
        end
      end

      context '更新できない値の場合' do

          let(:invalid_params) do
            {
              sleep_record: attributes_for(:sleep_record, user: user, start_time: nil)
            }
          end

        it 'updateアクションにリクエストしても睡眠記録は更新されない' do
          original_start_time = sleep_record.start_time
          patch sleep_record_path(sleep_record), params: invalid_params
          expect(sleep_record.reload.start_time).to eq(original_start_time)
        end
        it 'updateアクションにリクエストするとeditテンプレートが再表示される' do
          patch sleep_record_path(sleep_record), params: invalid_params
          html = Nokogiri::HTML(response.body)
          expect(html.at_css('h1').text).to include("睡眠時間編集")
          expect(html.at_css('form')).to be_present
        end
        it 'updateアクションにリクエストするとunprocessable_contentのステータスコードが返ってくる' do
          patch sleep_record_path(sleep_record), params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context '他ユーザーの睡眠記録の場合' do
          let(:valid_params) do
            {
              sleep_record: attributes_for(:sleep_record, user: other_user)
            }
          end
        it 'updateアクションにリクエストしても睡眠記録は更新されない' do
          original_start_time = other_sleep_record.start_time
          patch sleep_record_path(other_sleep_record)
          expect(other_sleep_record.reload.start_time).to eq(original_start_time)
        end
        it 'updateアクションにリクエストするとアクセスできない' do
          patch sleep_record_path(other_sleep_record), params: valid_params
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログインしていない場合' do
      let(:valid_params) do
        {
          sleep_record: attributes_for(:sleep_record, user: user)
        }
      end
      it 'updateアクションにリクエストするとログイン画面へリダイレクトされる' do
        patch sleep_record_path(sleep_record), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログインしている場合' do
      before do
        sign_in user
        sleep_record
      end

      it 'destroyアクションにリクエストすると自分のSleepRecordの数が1減る' do
        expect {
          delete sleep_record_path(sleep_record)
        }.to change(SleepRecord, :count).by(-1)
      end

      it 'destroyアクションにリクエストするとトップページへリダイレクトされる' do
        delete sleep_record_path(sleep_record)
        expect(response).to redirect_to(root_path)
      end

      it 'destroyアクションにリクエストすると睡眠時間を削除しましたというメッセージが表示される' do
        delete sleep_record_path(sleep_record)
        follow_redirect!
        expect(response.body).to include("睡眠時間を削除しました")
      end

      it '他ユーザーの睡眠記録は削除できない' do
        other_sleep_record
        expect{
          delete sleep_record_path(other_sleep_record)
        }.not_to change(SleepRecord, :count)
      end
    end

    context 'ログインしていない場合' do
      before do
        sleep_record
      end

      it 'destroyアクションにリクエストしてもSleepRecordの数は減らない' do
        expect{
          delete sleep_record_path(sleep_record)
      }.to change(SleepRecord, :count).by(0)
      end

      it 'destroyアクションにリクエストするとログイン画面へリダイレクトされる' do
        delete sleep_record_path(sleep_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
