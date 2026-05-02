class SleepRecord < ApplicationRecord
  belongs_to :user

  attr_accessor :end_clock

  before_validation :set_sleep_date
  before_validation :set_end_time
  before_validation :set_sleep_time

  validates :start_time, presence: true

  validates :sleep_date, uniqueness: {
    scope: :user_id,
    message: "の睡眠記録はすでに登録されています"
  }

  validates :sleep_time, numericality: {greater_than_or_equal_to: 30, less_than_or_equal_to: 14 * 60, message: "は30分以上14時間以下になるよう入力してください"}, allow_nil: true

  validate :start_time_must_not_be_future
  validate :start_time_must_not_overlap_with_study_records
  validate :end_time_must_not_be_future
  validate :sleep_time_must_not_overlap_with_study_records
  validate :end_clock_cannot_be_blank_when_end_time_already_exists, on: :update

  def set_end_clock_from_end_time
    return if end_time.blank?

    self.end_clock = end_time.strftime("%H:%M")
  end

  private

  def set_sleep_date
    return if start_time.blank?

    self.sleep_date = (start_time.in_time_zone - 5.hour).to_date
  end

  def set_end_time
    return if start_time.blank?
    return if end_clock.blank?

    hour, minute = end_clock.split(":").map(&:to_i)

    self.end_time = Time.zone.local(
      start_time.to_date.year,
      start_time.to_date.month,
      start_time.to_date.day,
      hour,
      minute
    )

    if end_time < start_time
      self.end_time += 1.day
    end
  end

  def set_sleep_time
    return if start_time.blank?
    return if end_time.blank?

    self.sleep_time = ((end_time - start_time) / 60).to_i
  end

  def start_time_must_not_be_future
    return if start_time.blank?

    if start_time > Time.current
      errors.add(:start_time, "は現在より未来の日時を登録できません")
    end
  end

  def start_time_must_not_overlap_with_study_records
    return if start_time.blank?

    study_records = set_candidate_study_records

    if study_records.present?
      study_records.each do |study_record|
        if study_record.start_time < start_time && start_time < study_record.end_time && !errors.added?(:base, "学習時間と重複しています")
        errors.add(:base, "学習時間と重複しています")
        end
      end
    end
  end


  def end_time_must_not_be_future
    return if end_time.blank?

    if end_time > Time.current
      errors.add(:end_time, "は現在より未来の日時を登録できません")
    end
  end

  def sleep_time_must_not_overlap_with_study_records
    return if start_time.blank?
    return if end_time.blank?

    study_records = set_candidate_study_records

    if study_records.present? && study_records.any? {|study_record| time_overlap?(study_record)} && !errors.added?(:base, "学習時間と重複しています")
      errors.add(:base, "学習時間と重複しています")
    end
  end

  def set_candidate_study_records
    return StudyRecord.none if user.nil?

    from = start_time - 1.day
    to = start_time + 1.day

    candidate_study_records = StudyRecord.where(user_id:user_id, start_time:from...to).where.not(end_time: nil)

    return candidate_study_records
  end

  def time_overlap?(other_record)
    start_time < other_record.end_time && other_record.start_time < end_time
  end

  def end_clock_cannot_be_blank_when_end_time_already_exists
    return if end_time_in_database.blank?
    return if end_clock.present?

    self.end_clock = end_time_in_database.strftime("%H:%M")
    errors.add(:end_time, "は登録済みの起床時刻がある場合、空欄にできません")
  end

end
