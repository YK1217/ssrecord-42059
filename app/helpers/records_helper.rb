module RecordsHelper

  # 記録時間表示用
  def format_record_time(minutes)
    return incomplete_badge if minutes.blank?

    hours = minutes / 60
    remain_minutes = minutes % 60

    if hours > 0
      "#{hours}時間#{remain_minutes}分"
    else
      "#{remain_minutes}分"
    end
  end

  # 終了時刻表示用
  def format_end_time(end_time)
    return incomplete_badge if end_time.blank?

    l(end_time, format: :time)
  end

  def incomplete_badge
    content_tag(:span, "未完了", class: "badge bg-warning text-dark")
  end

  def unregistered_badge
    content_tag(:span, "未登録", class: "badge bg-secondary")
  end

  def exists_badge
    content_tag(:span, "あり", class: "badge bg-danger")
  end

  def none_badge
    content_tag(:span, "なし", class: "badge bg-success")
  end
end
