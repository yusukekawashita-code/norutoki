module ApplicationHelper
  def format_minutes_until_departure(minutes)
    return if minutes.nil?

    hours, remaining_minutes = minutes.divmod(60)

    if hours.positive? && remaining_minutes.positive?
      "あと#{hours}時間#{remaining_minutes}分"
    elsif hours.positive?
      "あと#{hours}時間"
    else
      "あと#{remaining_minutes}分"
    end
  end

  def format_service_date(date)
    return if date.nil?

    weekdays = %w[日 月 火 水 木 金 土]
    "#{date.month}月#{date.day}日（#{weekdays[date.wday]}）"
  end
end
