require 'rails_helper'

RSpec.describe "睡眠時間登録", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @sleep_record = FactoryBot.build(:sleep_record,user: @user)
  end

  context '睡眠時間が登録できる時' do
    it 'ログインしたユーザーは登録できる' do
  end
  context '睡眠時間が登録できない時' do
    it 'ログインしていないユーザーは登録できない' do
  end
end
