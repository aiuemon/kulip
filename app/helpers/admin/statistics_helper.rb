module Admin
  module StatisticsHelper
    def chart_labels(date_range)
      date_range.map { |d| d.strftime("%m/%d") }
    end

    def chart_data(daily_hash, date_range)
      date_range.map { |date| daily_hash[date.to_s] || 0 }
    end

    def format_duration_short(seconds)
      return "0秒" if seconds.nil? || seconds == 0

      hours = seconds / 3600
      minutes = (seconds % 3600) / 60
      secs = seconds % 60

      parts = []
      parts << "#{hours}時間" if hours > 0
      parts << "#{minutes}分" if minutes > 0
      parts << "#{secs}秒" if secs > 0 || parts.empty?

      parts.join
    end
  end
end
