class SleepRecordsController < ApplicationController
  # before_action :authenticate_user!

  def new
    @sleep_record = SleepRecord.new
  end

  def create
    @sleep_record = current_user.sleep_records.new(sleep_record_params)

    if @sleep_record.save
      redirect_to root_path, notice: "睡眠時間を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def sleep_record_params
    params.require(:sleep_record).permit(:start_time, :end_clock)
  end
end
