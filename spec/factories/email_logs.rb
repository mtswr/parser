FactoryBot.define do
  factory :email_log do
    filename { "#{Faker::File.file_name(dir: "", name: "email", ext: "eml")}" }
    source { [ "Fornecedor A", "Parceiro B" ].sample }
    status { "success" }
    extracted_data { { name: "Test User", email: "test@example.com" }.to_json }
    customer_id { nil }
    error_message { nil }

    trait :success do
      status { "success" }
      extracted_data { { name: "Test User", email: "test@example.com" }.to_json }
      customer_id { 1 }
    end

    trait :failed do
      status { "failed" }
      extracted_data { nil }
      customer_id { nil }
      error_message { "Parse error occurred" }
    end

    trait :processing do
      status { "processing" }
      extracted_data { nil }
      customer_id { nil }
      error_message { nil }
    end
  end
end
