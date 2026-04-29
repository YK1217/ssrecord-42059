class SleepRecord < ApplicationRecord
  belongs_to :user

  attr_accessor :end_clock

  before_validation :set_sleep_date
  before_validation :set_end_time
  before_validation :set_sleep_time

  validates :sleep_time, presence: true

  validates :sleep_date, uniqueness: {
    scope: :user_id,
    message: "の睡眠記録はすでに登録されています"
  }

  validates :sleep_time, numericality: {greater_than_or_equal_to: 30, less_than_or_equal_to: 14 * 60, message: "は30分以上14時間以下になるよう入力してください"}, allow_nil: true

  validate :start_time_must_not_be_future
  validate :end_time_must_not_be_future

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

  def end_time_must_not_be_future
    return if end_time.blank?

    if end_time > Time.current
      errors.add(:end_time, "は現在より未来の日時を登録できません")
    end
  end
end
