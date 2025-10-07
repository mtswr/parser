class EmailLog < ApplicationRecord
  belongs_to :customer, optional: true

  validates :filename, presence: true
  validates :status, presence: true, inclusion: { in: %w[success failed processing] }
  validates :source, presence: true

  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "failed") }
  scope :processing, -> { where(status: "processing") }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_source, ->(source) { where(source: source) }

  def success?
    status == "success"
  end

  def failed?
    status == "failed"
  end

  def processing?
    status == "processing"
  end

  def self.log_success(filename, source, extracted_data, customer_id = nil)
    create!(
      filename: filename,
      source: source,
      status: "success",
      extracted_data: extracted_data.to_json,
      customer_id: customer_id,
      error_message: nil
    )
  end

  def self.log_failure(filename, source, error_message)
    create!(
      filename: filename,
      source: source,
      status: "failed",
      extracted_data: nil,
      customer_id: nil,
      error_message: error_message
    )
  end

  def self.log_processing(filename, source)
    create!(
      filename: filename,
      source: source,
      status: "processing",
      extracted_data: nil,
      customer_id: nil,
      error_message: nil
    )
  end
end
