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
    @errors = []
    uploaded_io = params[:file]
    filename = Rails.root.join('public', 'uploads', uploaded_io.original_filename)
    File.open(filename, 'w') do |file|
      file.write(uploaded_io.read.force_encoding("UTF-8"))
    end
    sheet = Spreadsheet.open(filename).worksheet(0)

    column_headers = {}
    sheet.column_count.times do |col|
      column_headers[ sheet.cell(0, col).to_sym ] = ""
    end

    products = {}
    (1...sheet.row_count).each do |row|
      product = column_headers.clone
      column_headers.keys.each_with_index do |col_name, col_index|
        product[ col_name.to_sym ] = sheet.cell(row, col_index)
      end

      product_code = product.delete(:Productcode).gsub('"', '').to_sym 
      if products[ product_code ].blank?
        products[ product_code ] = product
      else
        @errors.push "The file you uploaded has a duplicate Productcode for #{product_code}. Go back an upload a valid file."
      end
    end

    text = "Parsed the following changes:<BR>"
    products.each do |product_code, product|
      product_obj = ( Product.find_by_v_productcode(product_code.to_s) || Product.new(:v_productcode => product_code) )
      product.each do |attr_key, attr_value|
        attr_key = ("v_" + attr_key.to_s.downcase).to_sym
        attr_value.gsub!('\\','') if attr_value.is_a?(String)
        product_obj[attr_key] = attr_value
      end
      if product_obj.new_record?
        text << "Created #{product_code}"
        product_obj.mbk_import_new = true
      else
        text << "Updated #{product_code}"
        product_obj.mbk_import_update = true
      end
      @errors.push("#{product_code} did not save properly") unless product_obj.save
    end 

    render :text => (@errors.empty? ? text : @errors.join("<BR>"))
  end
end
