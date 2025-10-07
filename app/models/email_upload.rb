class EmailUpload
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :file
  validates :file, presence: true
  validate :file_format

  private

  def file_format
    return unless file.present?
    
    unless file.original_filename&.downcase&.end_with?('.eml')
      errors.add(:file, 'must be a .eml file')
    end
  end
end
