require 'rails_helper'

RSpec.describe StudyRecord, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  before do
    @study_record = FactoryBot.build(:study_record)
  end

  describe '学習記録新規登録' do
    context '新規登録できるとき' do
      it 'start_timeとend_clock、study_memoが存在すれば登録できる' do
        expect(@study_record).to be_valid
      end
      it 'end_clockが未入力でも登録できる' do
        @study_record.end_clock = ''
        expect(@study_record).to be_valid
      end
      it 'study_memoが未入力でも登録できる' do
        @study_record.study_memo = ''
        expect(@study_record).to be_valid
      end
    end
    context '新規登録できないとき' do
      it 'start_timeが未入力では登録できない' do
        @study_record.start_time = nil
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習開始日時を入力してください"
      end
      it 'start_timeが未来の日時であれば登録できない' do
        tomorrow_date = Time.zone.tomorrow
        @study_record.end_clock = ''
        @study_record.start_time = @study_record.start_time.change(year: tomorrow_date.year, month: tomorrow_date.month, day: tomorrow_date.day)
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習開始日時は現在より未来の日時を登録できません"
      end
      it 'start_timeが9:00〜17:00の範囲でなければ登録できない' do
        @study_record.start_time = @study_record.start_time.change(hour: 8, min: 30)
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習開始日時は9:00〜17:00の範囲で入力してください"
      end
      it 'end_clockに入力した時刻がstart_timeより前だと登録できない' do
        @study_record.start_time = @study_record.start_time.change(hour: 10, min: 30)
        @study_record.end_clock = '9:30'
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習終了時刻は学習開始日時より後の時刻を入力してください"
      end
      it 'start_timeが過去でもend_timeが未来になる場合は登録できない' do
        today_date = Time.current.to_date
        test_time = Time.zone.local(today_date.year, today_date.month, today_date.day, 12, 30)
        @study_record.start_time = Time.zone.local(today_date.year, today_date.month, today_date.day, 10, 30)
        @study_record.end_clock = '15:00'
        # 時刻を今日の12:30に設定
        travel_to test_time do
          @study_record.valid?
          expect(@study_record.errors.full_messages).to include "学習終了時刻は現在より未来の日時を登録できません"
        end
      end
      it 'end_clockが9:00〜17:00の範囲でなければ登録できない' do
        @study_record.end_clock = '17:30'
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習終了時刻は9:00〜17:00の範囲で入力してください"
      end
      it '学習時間が1時間以上8時間以下でなければ登録できない' do
        @study_record.start_time = @study_record.start_time.change(hour: 9, min: 30)
        @study_record.end_clock = '9:55'
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "学習時間は1時間以上8時間以下になるよう入力してください"
      end
      it '既に同一user同一日付の学習記録が登録されている場合は登録できない' do
        same_user = @study_record.user
        same_date = @study_record.start_time.to_date
        @study_record.save
        another_study_record = FactoryBot.build(:study_record, user: same_user)
        another_study_record.start_time = another_study_record.start_time.change(year: same_date.year, month: same_date.month, day: same_date.day)
        another_study_record.valid?
        expect(another_study_record.errors.full_messages).to include "学習日の学習記録はすでに登録されています"
      end
      it 'userが紐づいてなければ登録できない' do
        @study_record.user = nil
        @study_record.valid?
        expect(@study_record.errors.full_messages).to include "Userを入力してください"
      end
    end
  end
end
