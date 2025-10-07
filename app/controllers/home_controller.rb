class HomeController < ApplicationController
  def index
    @recent_customers = Customer.recent.limit(5)
    @recent_logs = EmailLog.recent.limit(5)
    @stats = {
      total_customers: Customer.count,
      successful_emails: EmailLog.successful.count,
      failed_emails: EmailLog.failed.count,
      processing_emails: EmailLog.processing.count
    }
  end
end
