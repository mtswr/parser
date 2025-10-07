require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      customer = build(:customer)
      expect(customer).to be_valid
    end

    it "is invalid without a name" do
      customer = build(:customer, name: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      customer = build(:customer, email: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("can't be blank")
    end

    it "is invalid with an invalid email format" do
      customer = build(:customer, email: "invalid-email")
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("is invalid")
    end

    it "is invalid without a phone" do
      customer = build(:customer, phone: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:phone]).to include("can't be blank")
    end

    it "is invalid without a product_code" do
      customer = build(:customer, product_code: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:product_code]).to include("can't be blank")
    end

    it "is invalid without a source" do
      customer = build(:customer, source: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:source]).to include("can't be blank")
    end
  end

  describe "scopes" do
    let!(:customer1) { create(:customer, source: "Fornecedor A", created_at: 1.hour.ago) }
    let!(:customer2) { create(:customer, source: "Parceiro B", created_at: 30.minutes.ago) }

    describe ".by_source" do
      it "returns customers filtered by source" do
        expect(Customer.by_source("Fornecedor A")).to include(customer1)
        expect(Customer.by_source("Fornecedor A")).not_to include(customer2)
      end
    end

    describe ".recent" do
      it "returns customers ordered by created_at desc" do
        test_customers = Customer.where(id: [ customer1.id, customer2.id ]).recent
        expect(test_customers.first).to eq(customer2)
        expect(test_customers.last).to eq(customer1)
      end
    end
  end

  describe ".from_email_data" do
    let(:email_data) do
      {
        name: "João Silva",
        email: "joao@example.com",
        phone: "(11) 99999-9999",
        product_code: "ABC123",
        source: "Fornecedor A"
      }
    end

    it "creates a customer with the provided data" do
      expect {
        Customer.from_email_data(email_data)
      }.to change(Customer, :count).by(1)

      customer = Customer.last
      expect(customer.name).to eq("João Silva")
      expect(customer.email).to eq("joao@example.com")
      expect(customer.phone).to eq("(11) 99999-9999")
      expect(customer.product_code).to eq("ABC123")
      expect(customer.source).to eq("Fornecedor A")
    end
  end
end
