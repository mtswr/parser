require 'rails_helper'

RSpec.describe EmailParserService do
  let(:email_content) { File.read(Rails.root.join('spec/emails/email1.eml')) }
  let(:filename) { 'email1.eml' }
  let(:service) { described_class.new(email_content, filename) }

  describe '#parse' do
    context 'with valid email content' do
      it 'parses the email successfully' do
        result = service.parse

        expect(result).to include(
          name: 'João da Silva',
          email: 'joao.silva@example.com',
          phone: '(11) 912345678',
          product_code: 'ABC123',
          source: 'Fornecedor A'
        )
      end
    end

    context 'with invalid email content' do
      let(:email_content) { 'invalid email content' }

      it 'raises a ParseError' do
        expect { service.parse }.to raise_error(EmailParserService::ParseError)
      end
    end

    context 'with missing required fields' do
      let(:email_content) do
        <<~EMAIL
          From: loja@fornecedorA.com
          To: vendas@suaempresa.com
          Subject: Test Email

          This email is missing required customer information.
        EMAIL
      end

      it 'raises a ParseError' do
        expect { service.parse }.to raise_error(EmailParserService::ParseError, /Missing required fields/)
      end
    end

    context 'with invalid email format' do
      let(:email_content) do
        <<~EMAIL
          From: loja@fornecedorA.com
          To: vendas@suaempresa.com
          Subject: Test Email

          Nome do cliente: João da Silva
          E-mail: invalid-email
          Telefone: (11) 91234-5678
          Produto de código: ABC123
        EMAIL
      end

      it 'raises a ParseError' do
        expect { service.parse }.to raise_error(EmailParserService::ParseError, /Invalid email format/)
      end
    end
  end

  describe 'source detection' do
    context 'with Fornecedor A email' do
      let(:email_content) do
        <<~EMAIL
          From: loja@fornecedorA.com
          To: vendas@suaempresa.com
          Subject: Test

          Nome do cliente: João da Silva
          E-mail: joao@example.com
          Telefone: (11) 99999-9999
          Produto de código: ABC123
        EMAIL
      end

      it 'detects the source as Fornecedor A' do
        result = service.parse
        expect(result[:source]).to eq('Fornecedor A')
      end
    end

    context 'with Parceiro B email' do
      let(:email_content) do
        <<~EMAIL
          From: contato@parceiroB.com
          To: vendas@suaempresa.com
          Subject: Test

          Nome: Maria Silva
          E-mail: maria@example.com
          Telefone: (21) 99999-9999
          Produto: XYZ789
        EMAIL
      end

      it 'detects the source as Parceiro B' do
        result = service.parse
        expect(result[:source]).to eq('Parceiro B')
      end
    end

    context 'with unknown source' do
      let(:email_content) do
        <<~EMAIL
          From: unknown@example.com
          To: vendas@suaempresa.com
          Subject: Test

          Nome do cliente: João da Silva
          E-mail: joao@example.com
          Telefone: (11) 99999-9999
          Produto de código: ABC123
        EMAIL
      end

      it 'detects the source as Unknown Source' do
        result = service.parse
        expect(result[:source]).to eq('Unknown Source')
      end
    end
  end
end
