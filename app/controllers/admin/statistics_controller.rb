module Admin
  class StatisticsController < BaseController
    def show
      @date_range = 30.days.ago.to_date..Date.current
      @daily_users = daily_active_users
      @daily_images = daily_uploaded_images
      @daily_ocr_duration = daily_ocr_total_duration
      @summary = build_summary
    end

    private

    def daily_active_users
      Image.where(created_at: date_range_query)
           .group("DATE(created_at)")
           .distinct
           .count(:user_id)
    end

    def daily_uploaded_images
      Image.where(created_at: date_range_query)
           .group("DATE(created_at)")
           .count
    end

    def daily_ocr_total_duration
      Image.where(ocr_completed_at: date_range_query)
           .where.not(ocr_duration: nil)
           .group("DATE(ocr_completed_at)")
           .sum(:ocr_duration)
    end

    def date_range_query
      @date_range.first.beginning_of_day..@date_range.last.end_of_day
    end

    def build_summary
      images = Image.where(created_at: date_range_query)
      {
        unique_users: images.distinct.count(:user_id),
        total_images: images.count,
        total_ocr_duration: Image.where(ocr_completed_at: date_range_query)
                                 .where.not(ocr_duration: nil)
                                 .sum(:ocr_duration)
      }
    end
  end
end
