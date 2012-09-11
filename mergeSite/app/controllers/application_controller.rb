class ApplicationController < ActionController::Base
  protect_from_forgery
  def home
    @page = (params[:page] || 1).to_i
    @all_products = Product.all.slice((100*(@page-1))...(100*@page))
    @all_customers = Customer.all.slice((100*(@page-1))...(100*@page))

    respond_to do |format|
      format.html
      format.xls do
        render :xls => @all_products, 
                       :columns => Product.attribute_names, 
                       :headers => Product.attribute_names.collect{|attr| attr.camelize}
      end
    end
  end
end
