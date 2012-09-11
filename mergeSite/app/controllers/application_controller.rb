class ApplicationController < ActionController::Base
  protect_from_forgery
  def home
    @page = params[:page].to_i || 1
    @all_products = Product.all.slice((100*(@page-1))...(100*@page))
    @all_customers = Customer.all.slice((100*(@page-1))...(100*@page))
  end
end
