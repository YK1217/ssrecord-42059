module DailyRecordsHelper
  def format_concentration_level(level)
    return '評価なし' if level.to_i.zero?

    level
  end
end
