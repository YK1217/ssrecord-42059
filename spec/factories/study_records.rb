FactoryBot.define do
  factory :study_record do
    association :user

    transient do
      base_date { rand(10.days.ago.to_date..1.day.ago.to_date) }
    end

    # start_time: 9:00 + 0〜180分（=9:00〜12:00）
    start_time do
      base = Time.zone.local(base_date.year, base_date.month, base_date.day, 9, 0)
      base + rand(0..3 * 60).minutes
    end

    # end_clock: 9:00 + 360〜480分（=15:00〜17:00）
    end_clock do
      minutes = rand(6 * 60..8 * 60)
      hour = 9 + minutes / 60
      minute = minutes % 60

      format("%02d:%02d", hour, minute)
    end

    study_memo { Faker::Lorem.sentence }
  end
end
