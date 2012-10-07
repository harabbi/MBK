class ApplicationController < ActionController::Base
  require 'spreadsheet'

  protect_from_forgery
  def home
    @all_products = Product.first
    @product_search = ProductSearch.new
  end

  def search
    if request.method == "POST"
      if params[:product_search]
        unless params[:search][:search_id].empty?
          @product_search = ProductSearch.find(params[:search][:search_id])
        else
          @product_search = ProductSearch.new(params[:product_search])
          unless params[:new_search_name].blank?
            @product_search.search_name = params[:new_search_name]
            @product_search.save!
          end
        end
        @products = @product_search.search_results
      end
    else
      render 'bad_page'
    end
  end

  def download
    if params[:search_id]
      @product_search = ProductSearch.find(params[:search_id])
    else
      @product_search = ProductSearch.new(params[:product_search])
    end
    send_data @product_search.search_results.to_xls(:columns => Product.xls_attributes,
                                                    :headers => Product.xls_attributes.collect{|attr| attr.gsub("v_", "").camelize}),
              :filename => "products.xls"
  end

  def upload
    uploaded_io = params[:file]
    filename = Rails.root.join('public', 'uploads', uploaded_io.original_filename)
    File.open(filename, 'w') do |file|
      file.write(uploaded_io.read.force_encoding("UTF-8"))
    end
    sheet = Spreadsheet.open(filename).worksheet(0)

    column_headers = []
    sheet.column_count.times do |col|
      column_headers.push sheet.cell(0, col)
    end

    products = []
    (1...sheet.row_count).each do |row|
      product = []
      column_headers.each_with_index do |col_name, col_index|
        product.push sheet.cell(row, col_index)
      end
      products.push product
    end

    render :text => products.collect{|product| product.join(',') + "<BR><BR>"}
  end
end
