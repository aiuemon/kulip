module ApplicationHelper
  include Pagy::NumericHelpers

  def sort_link(title, column, current_sort, current_dir)
    is_current = current_sort == column.to_s
    new_dir = is_current && current_dir == "asc" ? "desc" : "asc"
    arrow = is_current ? (current_dir == "asc" ? " ▲" : " ▼") : ""

    link_to "#{title}#{arrow}", request.params.merge(sort: column, dir: new_dir)
  end

  def format_duration(seconds)
    return "-" if seconds.nil? || seconds == 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    secs = seconds % 60

    if hours > 0
      format("%d時間%02d分%02d秒", hours, minutes, secs)
    elsif minutes > 0
      format("%d分%02d秒", minutes, secs)
    else
      format("%d秒", secs)
    end
  end
end
