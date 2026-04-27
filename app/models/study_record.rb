class StudyRecord < ApplicationRecord
  belongs_to :user

  attr_accessor :end_clock

  before_validation :set_study_date
  before_validation :set_end_time
  before_validation :set_study_time

  validates :start_time, presence: true  validates :study_date, uniqueness: {
    scope: :user_id,
    message: "の学習記録はすでに登録されています"
  }



  validate :start_time_must_not_be_future
  validate :start_time_must_be_within_study_hours
  validate :end_time_must_be_after_start_time
  validate :end_time_must_not_be_future
  validate :end_time_must_be_within_study_hours

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
end
