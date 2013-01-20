class ApplicationController < ActionController::Base
  require 'spreadsheet'

  protect_from_forgery
  def home
    if params[:search_id]
      @product_search = ProductSearch.find_by_id(params[:search_id]) || ProductSearch.new
      render :partial => 'search_form'
    else
      @product_search = ProductSearch.new
    end
  end

  def search
    if request.method == "POST"
      if params[:product_search]
        unless params[:product_search][:id].empty?
          @product_search = ProductSearch.find(params[:product_search][:id])
        else
          @product_search = ProductSearch.new(params[:product_search])
          unless params[:product_search][:search_name].blank?
            @product_search.search_name = params[:product_search][:search_name]
            @product_search.save!
          end
        end
        @products = @product_search.search_results
      end
    else
      render 'bad_page'
    end
  end

  def destroy
    ProductSearch.find(params[:id]).destroy
    redirect_to root_path
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

    text = ""
    new_products = [] 
    updated_products = [] 
    products.each do |product_code, product|

      product_obj = ( Product.find_by_v_productcode(product_code.to_s) || Product.new(:v_productcode => product_code) )

      product.each do |attr_key, attr_value|
        # Change the attr_key from search object to product object format
        attr_key = ("v_" + attr_key.to_s.downcase).to_sym

        # Get rid of backslashes and quotes
        if attr_value.is_a?(String)
          attr_value.gsub!('\\','')
          attr_value.gsub!('\"','')
          attr_value.gsub!('\'','')
        end

        # Validate the price format if a price attr
        if Product.price_attributes.include?(attr_key.to_s)
          if attr_value.is_a? Float
            attr_value = nil if attr_value == 0
          else
            @errors.push "#{product_code}'s #{attr_key} is not formatted correctly."
            next
          end
        end

        # Update the value if it's different
        product_obj[attr_key] = attr_value unless product_obj[attr_key] == attr_value
      end

      if product_obj.new_record?
        product_obj.mbk_import_new = true
        new_products.push product_obj

      elsif product_obj.changed?
        product_obj.mbk_import_update = true
        updated_products.push product_obj
      end

      # Validate the object
      @errors.push "#{product_code} did not pass validation: #{product_obj.errors.full_messages.join(", ")}" unless product_obj.valid?
    end 

    if @errors.empty?
      text << "New Products (#{new_products.count})"
      new_products.each do |product|
        text << "<li>#{product.v_productcode}</li>"
        product.save!
      end

      text << "<BR><BR>Updated Products (#{updated_products.count})"
      updated_products.each do |product|
        text << "<li>#{product.v_productcode}</li>"
        product.save!
      end
    end

    text << "<BR><a href='/'>Return Home</a>"
    render :text => (@errors.empty? ? text : @errors.join("<BR>"))
  end
end
