class EmailParserService
  class ParseError < StandardError; end

  def initialize(email_content, filename)
    @email_content = email_content
    @filename = filename
  end

  def parse
    begin
      email = Mail.read_from_string(@email_content)
      source = extract_source(email)
      extracted_data = extract_customer_data(email, source)
      
      validate_extracted_data(extracted_data)
      extracted_data.merge(source: source)
    rescue => e
      raise ParseError, "Failed to parse email #{@filename}: #{e.message}"
    end
  end

  private

  def extract_source(email)
    from_address = email.from&.first
    return 'Unknown Source' unless from_address

    case from_address
    when /fornecedora/i
      'Fornecedor A'
    when /parceirob/i
      'Parceiro B'
    else
      'Unknown Source'
    end
  end

  def extract_customer_data(email, source)
    body = email.body&.decoded || ''
    
    case source
    when 'Fornecedor A'
      extract_fornecedor_a_data(body)
    when 'Parceiro B'
      extract_parceiro_b_data(body)
    else
      extract_generic_data(body)
    end
  end

  def extract_fornecedor_a_data(body)
    {
      name: extract_field(body, /nome[:\s]*do[:\s]*cliente[:\s]*([^\n\r]+)/i) ||
            extract_field(body, /nome[:\s]*([^\n\r]+)/i),
      email: extract_field(body, /e-mail[:\s]*([^\n\r]+)/i),
      phone: extract_field(body, /telefone[:\s]*([^\n\r]+)/i),
      product_code: extract_product_code(body)
    }
  end

  def extract_parceiro_b_data(body)
    {
      name: extract_field(body, /nome[:\s]*completo[:\s]*([^\n\r]+)/i) ||
            extract_field(body, /cliente[:\s]*([^\n\r]+)/i) ||
            extract_field(body, /nome[:\s]*([^\n\r]+)/i),
      email: extract_field(body, /e-mail[:\s]*de[:\s]*contato[:\s]*([^\n\r]+)/i) ||
             extract_field(body, /email[:\s]*([^\n\r]+)/i) ||
             extract_field(body, /e-mail[:\s]*([^\n\r]+)/i),
      phone: extract_field(body, /telefone[:\s]*([^\n\r]+)/i),
      product_code: extract_product_code(body)
    }
  end

  def extract_generic_data(body)
    {
      name: extract_field(body, /nome[:\s]*([^\n\r]+)/i),
      email: extract_field(body, /e-mail[:\s]*([^\n\r]+)/i),
      phone: extract_field(body, /telefone[:\s]*([^\n\r]+)/i),
      product_code: extract_product_code(body)
    }
  end

  def extract_product_code(body)
    patterns = [
      /produto[:\s]*de[:\s]*código[:\s]*([A-Z]{3}\d{3})/i,
      /código[:\s]*([A-Z]{3}\d{3})/i,
      /produto[:\s]*([A-Z]{3}\d{3})/i,
      /interesse[:\s]*no[:\s]*produto[:\s]*([A-Z]{3}\d{3})/i,
      /solicitação[:\s]*de[:\s]*cotação[:\s]*-\s*produto[:\s]*([A-Z]{3}\d{3})/i,
      /pedido[:\s]*de[:\s]*orçamento[:\s]*-\s*produto[:\s]*([A-Z]{3}\d{3})/i,
      /produto[:\s]*de[:\s]*interesse[:\s]*([A-Z]+-\d+)/i,
      /produto[:\s]*([A-Z]+-\d+)/i,
      /código[:\s]*do[:\s]*produto[:\s]*([A-Z]+-\d+)/i,
      /interesse[:\s]*no[:\s]*([A-Z]+-\d+)/i,
      /([A-Z]+-\d+)/i
    ]
    
    patterns.each do |pattern|
      match = body.match(pattern)
      return match[1] if match
    end
    
    nil
  end

  def extract_field(text, pattern)
    match = text.match(pattern)
    return nil unless match

    value = match[1]&.strip
    return nil if value.blank?

    cleaned_value = value.gsub(/[^\w\s@.-àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ()]/, '').strip
    
    if pattern.to_s.include?('nome')
      cleaned_value = cleaned_value.gsub(/^(do cliente|cliente|nome)\s*/i, '').strip
    end
    
    cleaned_value
  end

  def validate_extracted_data(data)
    required_fields = [:name, :email, :phone, :product_code]
    missing_fields = required_fields.select { |field| data[field].blank? }
    
    if missing_fields.any?
      raise ParseError, "Missing required fields: #{missing_fields.join(', ')}"
    end

    unless data[:email] =~ URI::MailTo::EMAIL_REGEXP
      raise ParseError, "Invalid email format: #{data[:email]}"
    end
  end
end
