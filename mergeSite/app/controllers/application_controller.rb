class ApplicationController < ActionController::Base
  protect_from_forgery
  def home
    @all_products = Product.first
    @product_search = ProductSearch.new
  end

  def search
    if params[:product_search]
      @product_search = ProductSearch.new(params[:product_search])
      unless params[:new_search_name].blank?
        @product_search.save
      end
      @products = @product_search.search_results
    end
  end

  def download
    if params[:search_id]
      @product_search = ProductSearch.find(params[:search_id])
    else
      @product_search = ProductSearch.new(params[:product_search])
    end
    render :xls => @product_search.search_results,
                   :columns => Product.attribute_names,
                   :headers => Product.attribute_names.collect{|attr| attr.gsub("v_", "").camelize}
  end
end
