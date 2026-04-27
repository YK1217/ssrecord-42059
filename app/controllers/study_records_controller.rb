class StudyRecordsController < ApplicationController
  before_action :authenticate_user!

  def new
    @study_record = StudyRecord.new
  end

  def create
    @study_record = current_user.study_records.new(study_record_params)

    if @study_record.save
      redirect_to user_path, notice: "学習時間を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def study_record_params
    params.require(:study_record).permit(:start_time, :end_clock, :study_memo)
  end
end
