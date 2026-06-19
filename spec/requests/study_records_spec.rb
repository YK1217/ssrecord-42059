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
        it 'createアクションにリクエストしてもStudyRecordの数は増えない' do
        end
        it 'createアクションにリクエストするとnewテンプレートが再表示される' do
        end
        it 'createアクションにリクエストするとunprocessable_contentのステータスが返る' do
        end
      end
    end

    context 'ログインしていない場合' do
      it 'createアクションにリクエストしてもStudyRecordの数は増えない' do
      end

      it 'createアクションにリクエストするとログイン画面へリダイレクトされる' do
      end
    end
  end
end
