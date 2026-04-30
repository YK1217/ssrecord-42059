require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  before do
    @sleep_record = FactoryBot.build(:sleep_record)
  end

  describe '睡眠記録新規登録' do
    context '新規登録できるとき' do
      it 'start_timeとend_clockが存在すれば登録できる' do
        expect(@sleep_record).to be_valid
      end
      it 'end_clockが未入力でも登録できる' do
        @sleep_record.end_clock = ''
        expect(@sleep_record).to be_valid
      end
    end
    context '新規登録できないとき' do
      it 'start_timeが未入力では登録できない' do
        @sleep_record.start_time = nil
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "就寝日時を入力してください"
      end
      it 'start_timeが未来の日時であれば登録できない' do
        tomorrow_date = Date.tomorrow
        @sleep_record.end_clock = ''
        @sleep_record.start_time = @sleep_record.start_time.change(year: tomorrow_date.year, month: tomorrow_date.month, day: tomorrow_date.day)
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "就寝日時は現在より未来の日時を登録できません"
      end
      it 'start_timeが既に同一userで登録されている学習記録の時間に含まれている場合は登録できない' do
        same_user = FactoryBot.create(:user)
        @sleep_record = FactoryBot.build(:sleep_record, user: same_user)
        same_date = @sleep_record.start_time.to_date
        study_record = FactoryBot.build(:study_record, user: same_user)
        study_record.start_time = Time.zone.local(same_date.year, same_date.month, same_date.day, 9,0)
        study_record.end_clock = '15:00'
        study_record.save!
        @sleep_record.start_time = @sleep_record.start_time.change(hour: 10, min: 30)
        @sleep_record.end_clock = ''
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "学習時間と重複しています"
      end
      it 'start_timeが過去でもend_timeが未来になる場合は登録できない' do
        today_date = Time.zone.today
        test_time = Time.zone.local(today_date.year, today_date.month, today_date.day, 7, 30)
        @sleep_record.start_time = Time.zone.local(today_date.year, today_date.month, today_date.day, 2, 30)
        @sleep_record.end_clock = '10:30'
        # 時刻を今日の7:30に設定
        travel_to test_time do
          @sleep_record.valid?
          expect(@sleep_record.errors.full_messages).to include "起床時刻は現在より未来の日時を登録できません"
        end
      end
      it '睡眠時間が30分以上14時間以下でなければ登録できない' do
        @sleep_record.start_time = @sleep_record.start_time.change(hour: 0, min: 30)
        @sleep_record.end_clock = '15:00'
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "睡眠時間は30分以上14時間以下になるよう入力してください"
      end
      it '既に同一user同一日付の睡眠記録が登録されている場合は登録できない' do
        same_user = FactoryBot.create(:user)
        @sleep_record = FactoryBot.build(:sleep_record, user: same_user)
        same_date = (@sleep_record.start_time - 5.hour).to_date
        @sleep_record.save!
        another_sleep_record = FactoryBot.build(:sleep_record, user: same_user)
        another_sleep_record.start_time = Time.zone.local(same_date.year, same_date.month, same_date.day, 13,0)
        another_sleep_record.end_clock = '15:00'
        another_sleep_record.valid?
        expect(another_sleep_record.errors.full_messages).to include "睡眠日の睡眠記録はすでに登録されています"
      end
      it '既に同一userで時間の重複する学習記録が登録されている場合は登録できない' do
        same_user = FactoryBot.create(:user)
        @sleep_record = FactoryBot.build(:sleep_record, user: same_user)
        same_date = @sleep_record.start_time.to_date
        study_record = FactoryBot.build(:study_record, user: same_user)
        study_record.start_time = Time.zone.local(same_date.year, same_date.month, same_date.day, 9,30)
        study_record.end_clock = '15:00'
        study_record.save!
        @sleep_record.start_time = @sleep_record.start_time.change(hour: 1, min: 0)
        @sleep_record.end_clock = '10:00'
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "学習時間と重複しています"
      end
      it 'userが紐づいてなければ登録できない' do
        @sleep_record.user = nil
        @sleep_record.valid?
        expect(@sleep_record.errors.full_messages).to include "Userを入力してください"
      end
    end
  end
end
