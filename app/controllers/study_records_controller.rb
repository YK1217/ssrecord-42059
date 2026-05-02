class StudyRecordsController < ApplicationController
  # before_action :authenticate_user!

  def new
    @study_record = StudyRecord.new
  end

  def create
    @study_record = current_user.study_records.new(study_record_params)

    if @study_record.save
      redirect_to root_path, notice: "学習時間を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    study_record = current_user.study_records.find(params[:id])
    study_record.destroy
    redirect_to root_path, notice: "学習時間を削除しました"
  end

  def edit
    @study_record = current_user.study_records.find(params[:id])
    @study_record.set_end_clock_from_end_time
  end

  def update
    study_record = current_user.study_records.find(params[:id])

    if study_record.update(study_record_params)
      redirect_to root_path, notice: "学習時間を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def study_record_params
    params.require(:study_record).permit(:start_time, :end_clock, :study_memo)
  end
end
