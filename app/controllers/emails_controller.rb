class EmailsController < ApplicationController
  def new
    @email = EmailUpload.new
  end

  def create
    @email = EmailUpload.new(email_params)
    if @email.valid?
      temp_file_path = store_uploaded_file(@email.file)
      EmailProcessingJob.perform_later(temp_file_path, @email.file.original_filename)
      redirect_to root_path, notice: "Email uploaded successfully and is being processed in the background."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def email_params
    params.require(:email_upload).permit(:file)
  end

  def store_uploaded_file(uploaded_file)
    temp_file = Tempfile.new([ "email_", ".eml" ])
    content = uploaded_file.read
    begin
      if content.encoding == Encoding::ASCII_8BIT
        begin
          content = content.force_encoding("UTF-8")
          content.encode!("UTF-8")
        rescue Encoding::InvalidByteSequenceError
          begin
            content = content.force_encoding("ISO-8859-1")
            content = content.encode("UTF-8")
          rescue Encoding::InvalidByteSequenceError
            content = content.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
          end
        end
      else
        content = content.encode("UTF-8", invalid: :replace, undef: :replace)
      end
    rescue => e
      Rails.logger.warn "Encoding error: #{e.message}"
      content = content.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
    end
    temp_file.write(content)
    temp_file.close
    temp_file.path
  end
end
