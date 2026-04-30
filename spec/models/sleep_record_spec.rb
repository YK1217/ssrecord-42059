require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  before do
    @sleep_record = FactoryBot.build(:sleep_record)
  end

  describe '睡眠記録新規登録' do
    context '新規登録できるとき' do
      it 'start_timeとend_clockが存在すれば登録できる' do
        # expect(@sleep_record).to be_valid
      end
      it 'end_clockが未入力でも登録できる' do
        # @sleep_record.end_clock = ''
        # expect(@sleep_record).to be_valid
      end
    end
    context '新規登録できないとき' do
      it 'start_timeが未入力では登録できない' do
      end
      it 'start_timeが未来の日時であれば登録できない' do
      end
      it 'start_timeが既に同一userで登録されている学習記録の時間に含まれている場合は登録できない' do

      end
      it 'start_timeが過去でもend_timeが未来になる場合は登録できない' do
      end
      it '睡眠時間が30分以上14時間以下でなければ登録できない' do
      end
      it '既に同一user同一日付の睡眠記録が登録されている場合は登録できない' do
      end
      it '既に同一userで時間の重複する学習記録が登録されている場合は登録できない' do

      end
      it 'userが紐づいてなければ登録できない' do
      end
    end
  end
end
