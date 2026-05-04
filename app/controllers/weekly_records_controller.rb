class WeeklyRecordsController < ApplicationController
  def index
    @week_options = build_week_options

    @week_start =
      if params[:week_start].present?
        Date.parse(params[:week_start])
      else
        latest_record_week_start
      end

    if @week_start.nil?
      @week_dates = []
      @study_records_by_date = {}
      @sleep_records_by_date = {}
      return
    end

    @week_start = @week_start.beginning_of_week(:monday)
    @week_end = @week_start + 6.days
    @week_dates = (@week_start..@week_end).to_a

    study_records = current_user.study_records
                                .where(study_date: @week_dates)

    sleep_records = current_user.sleep_records
                                .where(sleep_date: @week_dates)

    @study_records_by_date = study_records.group_by(&:study_date)
    @sleep_records_by_date = sleep_records.group_by(&:sleep_date)

    completed_study_records = study_records.where.not(end_time: nil, study_time: nil)
    completed_sleep_records = sleep_records.where.not(end_time: nil, sleep_time: nil)

    @total_study_time = completed_study_records.sum(:study_time)
    @total_sleep_time = completed_sleep_records.sum(:sleep_time)

    @past_or_today_dates = @week_dates.select { |date| date <= Date.current }

    @average_study_time = calculate_average_study_time
    @average_sleep_time = calculate_average_sleep_time

    @recorded_dates = build_recorded_dates
    @recorded_days_count = @recorded_dates.count

    @has_incomplete_records = has_incomplete_records?
    @has_missing_past_dates = has_missing_past_dates?
  end

  private

  def build_week_options
    dates = current_user.study_records.pluck(:study_date) +
            current_user.sleep_records.pluck(:sleep_date)

    dates.compact.map { |date| date.beginning_of_week(:monday) }.uniq.sort.reverse
  end

  def latest_record_week_start
    latest_study_date = current_user.study_records.maximum(:study_date)
    latest_sleep_date = current_user.sleep_records.maximum(:sleep_date)

    latest_date = [latest_study_date, latest_sleep_date].compact.max
    latest_date&.beginning_of_week(:monday)
  end

  def calculate_average_study_time
    return nil if @past_or_today_dates.empty?

    @total_study_time / @past_or_today_dates.count
  end

  def calculate_average_sleep_time
    completed_sleep_dates =
      @sleep_records_by_date.select do |_date, records|
        records.any? { |record| record.sleep_time.present? && record.end_time.present? }
      end.keys

    target_dates = completed_sleep_dates.select { |date| date <= Date.current }

    return nil if target_dates.empty?

    @total_sleep_time / target_dates.count
  end

  def build_recorded_dates
    study_dates = @study_records_by_date.keys
    sleep_dates = @sleep_records_by_date.keys

    (study_dates + sleep_dates).uniq
  end

  def has_incomplete_records?
    incomplete_study =
      @study_records_by_date.values.flatten.any? do |record|
        record.end_time.blank? || record.study_time.blank?
      end

    incomplete_sleep =
      @sleep_records_by_date.values.flatten.any? do |record|
        record.end_time.blank? || record.sleep_time.blank?
      end

    incomplete_study || incomplete_sleep
  end

  def has_missing_past_dates?
    @past_or_today_dates.any? do |date|
      @study_records_by_date[date].blank? && @sleep_records_by_date[date].blank?
    end
  end
end
