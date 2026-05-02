class StudyRecord < ApplicationRecord
  belongs_to :user

  attr_accessor :end_clock

  before_validation :set_study_date
  before_validation :set_end_time
  before_validation :set_study_time

  validates :start_time, presence: true

  validates :study_date, uniqueness: {
    scope: :user_id,
    message: "の学習記録はすでに登録されています"
  }

  validates :study_time, numericality: {greater_than_or_equal_to: 60, less_than_or_equal_to: 8 * 60, message: "は1時間以上8時間以下になるよう入力してください"}, allow_nil: true

  validate :start_time_must_not_be_future
  validate :start_time_must_be_within_study_hours
  validate :start_time_must_not_overlap_with_sleep_records
  validate :end_time_must_be_after_start_time
  validate :end_time_must_not_be_future
  validate :end_time_must_be_within_study_hours
  validate :study_time_must_not_overlap_with_sleep_records

  private

  def set_study_date
    return if start_time.blank?

    self.study_date = start_time.to_date
  end

  def set_end_time
    return if start_time.blank?
    return if end_clock.blank?

    hour, minute = end_clock.split(":").map(&:to_i)

    self.end_time = Time.zone.local(
      study_date.year,
      study_date.month,
      study_date.day,
      hour,
      minute
    )
  end

  def set_study_time
    return if start_time.blank?
    return if end_time.blank?
    return if end_time <= start_time

    self.study_time = ((end_time - start_time) / 60).to_i
  end

  def start_time_must_not_be_future
    return if start_time.blank?

    if start_time > Time.current
      errors.add(:start_time, "は現在より未来の日時を登録できません")
    end
  end

  def start_time_must_be_within_study_hours
    return if start_time.blank?

    unless within_study_hours?(start_time)
      errors.add(:start_time, "は9:00〜17:00の範囲で入力してください")
    end
  end

  def start_time_must_not_overlap_with_sleep_records
    return if start_time.blank?

    sleep_records = set_candidate_sleep_records

    if sleep_records.present?
      sleep_records.each do |sleep_record|
        if sleep_record.start_time < start_time && start_time < sleep_record.end_time && !errors.added?(:base, "睡眠時間と重複しています")
        errors.add(:base, "睡眠時間と重複しています")
        end
      end
    end
  end

  def end_time_must_be_after_start_time
    return if start_time.blank?
    return if end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "は学習開始日時より後の時刻を入力してください")
    end
  end

  def end_time_must_not_be_future
    return if end_time.blank?

    if end_time > Time.current
      errors.add(:end_time, "は現在より未来の日時を登録できません")
    end
  end

  def end_time_must_be_within_study_hours
    return if end_time.blank?

    unless within_study_hours?(end_time)
      errors.add(:end_time, "は9:00〜17:00の範囲で入力してください")
    end
  end

  def within_study_hours?(time)
    minutes = time.hour * 60 + time.min
    minutes.between?(9 * 60, 17 * 60)
  end

  def study_time_must_not_overlap_with_sleep_records
    return if start_time.blank?
    return if end_time.blank?

    sleep_records = set_candidate_sleep_records

    if sleep_records.present? && sleep_records.any? {|sleep_record| time_overlap?(sleep_record)} && !errors.added?(:base, "睡眠時間と重複しています")
      errors.add(:base, "睡眠時間と重複しています")
    end
  end

  def set_candidate_sleep_records
    return SleepRecord.none if user.nil?

    from = start_time - 1.day
    to = start_time + 1.day

    candidate_sleep_records = SleepRecord.where(user_id:user_id, start_time:from...to).where.not(end_time: nil)

    return candidate_sleep_records
  end

  def time_overlap?(other_record)
    start_time < other_record.end_time && other_record.start_time < end_time
  end

  def set_end_clock_from_end_time
    return if end_time.blank?

    self.end_clock = end_time.strftime("%H:%M")
  end
end
