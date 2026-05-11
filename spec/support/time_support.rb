module TimeSupport
  def build_end_time_from(record)
    hour, minute = record.end_clock.split(":").map(&:to_i)

    Time.zone.local(
      record.start_time.to_date.year,
      record.start_time.to_date.month,
      record.start_time.to_date.day,
      hour,
      minute
    )
  end

  def build_next_day_end_time_from(record)
    end_time = build_end_time_from(record)

    if end_time < record.start_time
      end_time + 1.day
    else
      end_time
    end
  end

  def build_end_clock_from(record)
    return record.end_time&.strftime("%H:%M") || ''
  end
end
