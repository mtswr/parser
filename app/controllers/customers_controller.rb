class CustomersController < ApplicationController
  def index
    @customers = Customer.recent
    @customers = @customers.by_source(params[:source]) if params[:source].present?
    # @customers = @customers.page(params[:page]).per(20) # Remove pagination for now
    
    @sources = Customer.distinct.pluck(:source)
  end

  def show
    @customer = Customer.find(params[:id])
  end
end
