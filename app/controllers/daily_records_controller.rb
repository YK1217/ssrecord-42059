class DailyRecordsController < ApplicationController
  PER_PAGE = 10

  def index
    @page = params[:page].to_i
    @page = 1 if @page < 1

    sleep_dates = current_user.sleep_records.pluck(:sleep_date)
    study_dates = current_user.study_records.pluck(:study_date)

    all_dates = (sleep_dates + study_dates).compact.uniq.sort.reverse

    @total_pages = (all_dates.size.to_f / PER_PAGE).ceil
    @dates = all_dates.slice((@page - 1) * PER_PAGE, PER_PAGE) || []

    @sleep_records_by_date = current_user.sleep_records.where(sleep_date: @dates).order(:start_time).group_by(&:sleep_date)

    @study_records_by_date = current_user.study_records.where(study_date: @dates).order(:start_time).group_by(&:study_date)
  end
end
