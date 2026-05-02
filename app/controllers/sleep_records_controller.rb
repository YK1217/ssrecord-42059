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

  def destroy
    sleep_record = current_user.sleep_records.find(params[:id])
    sleep_record.destroy
    redirect_to root_path, notice: "睡眠時間を削除しました"
  end

  def edit
    @sleep_record = current_user.sleep_records.find(params[:id])
    @study_record.set_end_clock_from_end_time
  end

  def update
    sleep_record = current_user.sleep_records.find(params[:id])

    if sleep_record.update(sleep_record_params)
      redirect_to root_path, notice: "睡眠時間を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def sleep_record_params
    params.require(:sleep_record).permit(:start_time, :end_clock)
  end
end
