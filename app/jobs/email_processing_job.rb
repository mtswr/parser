class EmailProcessingJob < ApplicationJob
  queue_as :default

  def perform(email_file_path, filename)
    begin
      unless File.exist?(email_file_path)
        raise "Email file not found: #{email_file_path}"
      end

      email_content = File.read(email_file_path)
      Rails.logger.info "Processing email #{filename}, content length: #{email_content.length}"
      Rails.logger.info "First 200 chars: #{email_content[0..200]}"

      parser = EmailParserService.new(email_content, filename)
      extracted_data = parser.parse

      email_log = EmailLog.log_processing(filename, extracted_data[:source])
      customer = Customer.from_email_data(extracted_data)

      email_log.update!(
        status: "success",
        extracted_data: extracted_data.to_json,
        customer_id: customer.id,
        error_message: nil
      )

      Rails.logger.info "Successfully processed email #{filename} and created customer #{customer.id}"

    rescue EmailParserService::ParseError => e
      email_log = EmailLog.log_processing(filename, "Unknown Source")
      email_log.update!(
        status: "failed",
        error_message: e.message
      )

      Rails.logger.error "Failed to parse email #{filename}: #{e.message}"

    rescue => e
      email_log = EmailLog.log_processing(filename, "Unknown Source")
      email_log.update!(
        status: "failed",
        error_message: "Unexpected error: #{e.message}"
      )

      Rails.logger.error "Unexpected error processing email #{filename}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    ensure
      File.delete(email_file_path) if File.exist?(email_file_path)
    end
  end
end
