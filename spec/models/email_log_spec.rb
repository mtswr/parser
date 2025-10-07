require "rails_helper"

RSpec.describe EmailLog, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      email_log = build(:email_log)
      expect(email_log).to be_valid
    end

    it "is invalid without a filename" do
      email_log = build(:email_log, filename: nil)
      expect(email_log).not_to be_valid
      expect(email_log.errors[:filename]).to include("can't be blank")
    end

    it "is invalid without a status" do
      email_log = build(:email_log, status: nil)
      expect(email_log).not_to be_valid
      expect(email_log.errors[:status]).to include("can't be blank")
    end

    it "is invalid with an invalid status" do
      email_log = build(:email_log, status: "invalid_status")
      expect(email_log).not_to be_valid
      expect(email_log.errors[:status]).to include("is not included in the list")
    end

    it "is invalid without a source" do
      email_log = build(:email_log, source: nil)
      expect(email_log).not_to be_valid
      expect(email_log.errors[:source]).to include("can't be blank")
    end
  end

  describe "scopes" do
    let!(:success_log) { create(:email_log, status: "success") }
    let!(:failed_log) { create(:email_log, status: "failed") }
    let!(:processing_log) { create(:email_log, status: "processing") }

    describe ".successful" do
      it "returns only successful logs" do
        expect(EmailLog.successful).to include(success_log)
        expect(EmailLog.successful).not_to include(failed_log, processing_log)
      end
    end

    describe ".failed" do
      it "returns only failed logs" do
        expect(EmailLog.failed).to include(failed_log)
        expect(EmailLog.failed).not_to include(success_log, processing_log)
      end
    end

    describe ".processing" do
      it "returns only processing logs" do
        expect(EmailLog.processing).to include(processing_log)
        expect(EmailLog.processing).not_to include(success_log, failed_log)
      end
    end
  end

  describe "status methods" do
    let(:success_log) { build(:email_log, status: "success") }
    let(:failed_log) { build(:email_log, status: "failed") }
    let(:processing_log) { build(:email_log, status: "processing") }

    describe "#success?" do
      it "returns true for success status" do
        expect(success_log.success?).to be true
        expect(failed_log.success?).to be false
        expect(processing_log.success?).to be false
      end
    end

    describe "#failed?" do
      it "returns true for failed status" do
        expect(failed_log.failed?).to be true
        expect(success_log.failed?).to be false
        expect(processing_log.failed?).to be false
      end
    end

    describe "#processing?" do
      it "returns true for processing status" do
        expect(processing_log.processing?).to be true
        expect(success_log.processing?).to be false
        expect(failed_log.processing?).to be false
      end
    end
  end

  describe "class methods" do
    describe ".log_success" do
      let(:extracted_data) { { name: "João", email: "joao@example.com" } }

      it "creates a success log" do
        expect {
          EmailLog.log_success("test.eml", "Fornecedor A", extracted_data, 1)
        }.to change(EmailLog, :count).by(1)

        log = EmailLog.last
        expect(log.filename).to eq("test.eml")
        expect(log.source).to eq("Fornecedor A")
        expect(log.status).to eq("success")
        expect(log.extracted_data).to eq(extracted_data.to_json)
        expect(log.customer_id).to eq(1)
        expect(log.error_message).to be_nil
      end
    end

    describe ".log_failure" do
      it "creates a failure log" do
        expect {
          EmailLog.log_failure("test.eml", "Fornecedor A", "Parse error")
        }.to change(EmailLog, :count).by(1)

        log = EmailLog.last
        expect(log.filename).to eq("test.eml")
        expect(log.source).to eq("Fornecedor A")
        expect(log.status).to eq("failed")
        expect(log.error_message).to eq("Parse error")
        expect(log.extracted_data).to be_nil
        expect(log.customer_id).to be_nil
      end
    end

    describe ".log_processing" do
      it "creates a processing log" do
        expect {
          EmailLog.log_processing("test.eml", "Fornecedor A")
        }.to change(EmailLog, :count).by(1)

        log = EmailLog.last
        expect(log.filename).to eq("test.eml")
        expect(log.source).to eq("Fornecedor A")
        expect(log.status).to eq("processing")
        expect(log.extracted_data).to be_nil
        expect(log.customer_id).to be_nil
        expect(log.error_message).to be_nil
      end
    end
  end
end
