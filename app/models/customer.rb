class Customer < ApplicationRecord
  has_many :email_logs, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :product_code, presence: true
  validates :source, presence: true

  scope :by_source, ->(source) { where(source: source) }
  scope :recent, -> { order(created_at: :desc) }

  def self.from_email_data(email_data)
    create!(
      name: email_data[:name],
      email: email_data[:email],
      phone: email_data[:phone],
      product_code: email_data[:product_code],
      source: email_data[:source]
    )
  end
end
