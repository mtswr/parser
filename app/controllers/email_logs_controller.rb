class EmailLogsController < ApplicationController
  def index
    @email_logs = EmailLog.recent
    @email_logs = @email_logs.by_source(params[:source]) if params[:source].present?
    @email_logs = @email_logs.where(status: params[:status]) if params[:status].present?
    # @email_logs = @email_logs.page(params[:page]).per(20) # Remove pagination for now
    
    @sources = EmailLog.distinct.pluck(:source)
    @statuses = %w[success failed processing]
    
    @stats = {
      total: EmailLog.count,
      successful: EmailLog.successful.count,
      failed: EmailLog.failed.count,
      processing: EmailLog.processing.count
    }
  end

  def show
    @email_log = EmailLog.find(params[:id])
  end
end
