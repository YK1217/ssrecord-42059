FactoryBot.define do
  factory :sleep_record do
    association :user

    transient do
      base_date { rand(11.days.ago.to_date..2.day.ago.to_date) }
    end

    # start_time: 22:00 + 0～240分(=22:00～2:00)
    start_time do
      base = Time.zone.local(base_date.year, base_date.month, base_date.day, 22, 0)
      base + rand(0..4 * 60).minutes
    end

    # end_clock: 22:00 + 480分～600分(=6:00～8:00)
    end_clock do
      minutes = rand(8 * 60..10 * 60)
      hour = (22 + minutes / 60) % 24
      minute = minutes % 60

      format("%02d:%02d", hour, minute)
    end
  end
end
