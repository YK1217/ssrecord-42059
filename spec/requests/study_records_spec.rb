require 'rails_helper'

RSpec.describe "StudyRecords", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:study_record) { create(:study_record, user: user) }
  let(:other_study_record) { create(:study_record, user: other_user) }

  def build_expected_start_time_local_value(record)
    record.start_time.localtime.strftime("%Y-%m-%dT%H:%M:%S")
  end

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
      before do
        get new_study_record_path
      end

      it 'newアクションにリクエストするとログイン画面へリダイレクトされる' do
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
            study_record: attributes_for(:study_record, user: user)
          }
        end

        it 'createアクションにリクエストするとStudyRecordの数が1増える' do
          expect {
            post study_records_path, params: valid_params
          }.to change(StudyRecord, :count).by(1)
        end
        it 'createアクションにリクエストするとトップページへリダイレクトされる' do
          post study_records_path, params: valid_params
          expect(response).to redirect_to(root_path)
        end
        it 'createアクションにリクエストすると学習時間を登録しましたというメッセージが表示される' do
          post study_records_path, params: valid_params
          follow_redirect!
          expect(response.body).to include("学習時間を登録しました")
        end
        it '作成された学習記録はログイン中のユーザーに紐づく' do
          post study_records_path, params: valid_params
          expect(StudyRecord.last.user_id).to eq(user.id)
        end
        it '作成された学習記録に学習メモが保存される' do
          post study_records_path, params: valid_params
          expect(StudyRecord.last.study_memo).to eq(valid_params[:study_record][:study_memo])
        end
      end

      context '保存できない値の場合' do
        let(:invalid_params) do
          {
            study_record: attributes_for(:study_record, user: user, start_time: nil)
          }
        end

        it 'createアクションにリクエストしてもStudyRecordの数は増えない' do
          expect {
            post study_records_path, params: invalid_params
          }.not_to change(StudyRecord, :count)
        end
        it 'createアクションにリクエストするとnewテンプレートが再表示される' do
          post study_records_path, params: invalid_params

          html = Nokogiri::HTML(response.body)
          expect(html.at_css('h1').text).to include("学習時間登録")
          expect(html.at_css('form')).to be_present
        end
        it 'createアクションにリクエストするとunprocessable_contentのステータスが返る' do
          post study_records_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context 'ログインしていない場合' do
      let(:valid_params) do
        {
          study_record: attributes_for(:study_record, user: user)
        }
      end
      it 'createアクションにリクエストしてもStudyRecordの数は増えない' do
        expect {
          post study_records_path, params: valid_params
        }.not_to change(StudyRecord, :count)
      end

      it 'createアクションにリクエストするとログイン画面へリダイレクトされる' do
        post study_records_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'ログインしている場合'do
      before do
        sign_in user
        get edit_study_record_path(study_record)
      end

      it '自分の学習記録のeditアクションにリクエストすると正常にレスポンスが返ってくる' do
        expect(response).to have_http_status(:ok)
      end
      it 'editアクションにリクエストすると学習時間編集フォームが表示される' do
        html = Nokogiri::HTML(response.body)
        expect(html.at_css('h1').text).to include("学習時間編集")
        expect(html.at_css('form')).to be_present
      end
      it 'editアクションにリクエストすると登録済みの学習開始時間が表示される' do
        html = Nokogiri::HTML(response.body)
        start_time_value = build_expected_start_time_local_value(study_record)
        expect(html.at_css('input[name="study_record[start_time]"]')['value']).to eq(start_time_value)
      end
      it 'editアクションにリクエストすると登録済みの学習終了時刻が表示される' do
        html = Nokogiri::HTML(response.body)
        end_clock_value = build_end_clock_from(study_record)
        expect(html.at_css('input[name="study_record[end_clock]"]')['value']).to eq(end_clock_value)
      end
      it 'editアクションにリクエストすると登録済みの学習メモが表示される' do
        html = Nokogiri::HTML(response.body)
        display_text = html.at_css('textarea[name="study_record[study_memo]"]').text.strip
        expect(display_text).to eq(study_record.study_memo)
      end
      it '他ユーザーの学習記録のeditアクションにリクエストするとアクセスできない' do
        get edit_study_record_path(other_study_record)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'ログインしていない場合' do
      it 'editアクションにリクエストするとログインページにリダイレクトされる' do
        get edit_study_record_path(study_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    context 'ログインしている場合' do
      before do
        sign_in user
        study_record
      end

      context '更新できる値の場合' do

        let(:valid_params) do
          {
            study_record: attributes_for(:study_record, user: user)
          }
        end

        it 'updateアクションにリクエストすると学習記録の内容が更新される' do
          patch study_record_path(study_record), params: valid_params
          expect(study_record.reload.start_time).to eq(valid_params[:study_record][:start_time])
        end
        it 'updateアクションにリクエストすると学習メモが更新される' do
          patch study_record_path(study_record), params: valid_params
          expect(study_record.reload.study_memo).to eq(valid_params[:study_record][:study_memo])
        end
        it 'updateアクションにリクエストするとトップページへリダイレクトされる' do
          patch study_record_path(study_record), params: valid_params
          expect(response).to redirect_to(root_path)
        end
        it 'updateアクションにリクエストすると学習時間を更新しましたというメッセージが表示される' do
          patch study_record_path(study_record), params: valid_params
          follow_redirect!
          expect(response.body).to include("学習時間を更新しました")
        end
      end

      context '更新できない値の場合' do

        let(:invalid_params) do
          {
            study_record: attributes_for(:study_record, user: user, start_time: nil)
          }
        end

        it 'updateアクションにリクエストしても学習記録の内容は更新されない' do
          original_start_time = study_record.start_time
          patch study_record_path(study_record), params: invalid_params
          expect(study_record.reload.start_time).to eq(original_start_time)
        end
        it 'updateアクションにリクエストするとeditテンプレートが再表示される' do
          patch study_record_path(study_record), params: invalid_params
          html = Nokogiri::HTML(response.body)
          expect(html.at_css('h1').text).to include("学習時間編集")
          expect(html.at_css('form')).to be_present
        end
        it 'updateアクションにリクエストするとunprocessable_contentのステータスが返る' do
          patch study_record_path(study_record), params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context '他ユーザーの学習記録の場合' do

        before do
          other_study_record
        end

        let(:valid_params) do
          {
            study_record: attributes_for(:study_record, user: other_user)
          }
        end

        it 'updateアクションにリクエストしても学習記録は更新されない' do
          original_start_time = other_study_record.start_time
          patch study_record_path(other_study_record), params: valid_params
          expect(other_study_record.reload.start_time).to eq(original_start_time)
        end
        it 'updateアクションにリクエストするとアクセスできない' do
          patch study_record_path(other_study_record), params: valid_params
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'ログインしていない場合' do

      let(:valid_params) do
        {
          study_record: attributes_for(:study_record, user: user)
        }
      end

      it 'updateアクションにリクエストしても学習記録は更新されない' do
        original_start_time = study_record.start_time
        patch study_record_path(study_record), params: valid_params
        expect(study_record.reload.start_time).to eq(original_start_time)
      end
      it 'updateアクションにリクエストするとログイン画面へリダイレクトされる' do
        patch study_record_path(study_record), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログインしている場合' do
      before do
        sign_in user
        study_record
      end

      it 'destroyアクションにリクエストすると自分のStudyRecordの数が1減る' do
        expect {
          delete study_record_path(study_record)
        }.to change(StudyRecord, :count).by(-1)
      end
      it 'destroyアクションにリクエストするとトップページへリダイレクトされる' do
        delete study_record_path(study_record)
        expect(response).to redirect_to(root_path)
      end
      it 'destroyアクションにリクエストすると学習時間を削除しましたというメッセージが表示される' do
        delete study_record_path(study_record)
        follow_redirect!
        expect(response.body).to include("学習時間を削除しました")
      end
      it '他ユーザーの学習記録は削除できない' do
        other_study_record
        expect{
          delete study_record_path(other_study_record)
        }.not_to change(StudyRecord, :count)
      end
    end

    context 'ログインしていない場合' do
      before do
        study_record
      end

      it 'destroyアクションにリクエストしてもStudyRecordの数は減らない' do
        expect{
          delete study_record_path(study_record)
        }.not_to change(StudyRecord, :count)
      end

      it 'destroyアクションにリクエストするとログイン画面へリダイレクトされる' do
        delete study_record_path(study_record)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
