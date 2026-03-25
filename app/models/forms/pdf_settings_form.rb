# frozen_string_literal: true

module Forms
  class PdfSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :max_pages, :integer

    validates :max_pages,
      numericality: { greater_than: 0, less_than_or_equal_to: 100, message: "は1〜100の範囲で指定してください" },
      allow_blank: true

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.pdf_max_pages = max_pages.presence || Setting::DEFAULT_PDF_MAX_PAGES
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :pdf_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "PdfSettings")
    end

    private

    def load_from_settings
      self.max_pages = Setting.pdf_max_pages
    end
  end
end
