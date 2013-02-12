class ApplicationController < ActionController::Base
  require 'spreadsheet'
  require 'net/http'
  require 'net/ssh'
  require 'net/scp'
  require '../scripts/mbk_params.rb'

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
      if params[:commit] == "Search without Save"
        @product_search = ( ProductSearch.find_by_id(params[:product_search][:id]) || ProductSearch.new(params[:product_search]) )
      elsif params[:commit] == "Save New Search"
        @product_search = ProductSearch.new(params[:product_search])
        @product_search.save!
      else # Update and Search
        @product_search = ProductSearch.find(params[:product_search][:id])
        @product_search.update_attributes(params[:product_search])
      end

      @products = @product_search.search_results

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

    @new_products = [] 
    @updated_products = [] 
    @unchanged_products = []

    products.each do |product_code, product|

      product_obj = ( Product.find_by_v_productcode(product_code.to_s) || Product.new(:v_productcode => product_code) )

      product.each do |attr_key, attr_value|
        # Change the attr_key from search object to product object format
        attr_key = ("v_" + attr_key.to_s.underscore).to_sym

        # Update the value if it's different
        if attr_key == :v_stockstatus
          xls_delta = attr_value - product_obj[attr_key]
          v_delta = get_v_stockstatus(product_code) || 0

          unless ( xls_delta + v_delta ) == 0
            product_obj[attr_key] = ( product_obj[attr_key] + xls_delta + v_delta )
          end
        else
          product_obj[attr_key] = attr_value unless product_obj[attr_key] == attr_value
        end
      end

      if product_obj.new_record?
        product_obj.mbk_import_new = true
        @new_products.push product_obj

      elsif product_obj.changed?
        product_obj.mbk_import_update = true
        changed_attrs = product_obj.attribute_names.select do |attr|
          !['mbk_import_update', 'mbk_import_new'].include? attr and product_obj.send(attr + '_changed?')
        end.join(',').gsub('v_', '')

        @updated_products.push [ product_obj, changed_attrs ]

      else
        @unchanged_products.push product_obj
      end

      # Validate the object
      @errors.push "#{product_code} did not pass validation: #{product_obj.errors.full_messages.join(", ")}" unless product_obj.valid?
    end 

    if @errors.empty?
      @new_products.each do |product|
        product.save!
      end

      @updated_products.each do |product, nevermind|
        product.save!
      end
    end

    render "results"
  end

  def change_image
    @product = Product.find_by_v_productcode(params[:productcode])

    if request.method == "POST"
      Net::SSH.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |ssh|
        begin
          ssh.exec!("mkdir -p #{@product.mbk_image_dir}")
          Net::SCP.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |scp|
            begin
              scp.upload!(params[:image].path, @product.mbk_image_uri)
              @status = "Oh... that looks good!"
            rescue
              mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
              @status = "Uh oh... it didn't go."
            end
          end
        rescue
          @status = "Magento login failed"
        end
      end
    end
  end

  private
  def get_v_stockstatus(product_code)
    uri = URI("http://www.modeltrainstuff.com/net/WebService.aspx")
    params = { :Login => "philz@modeltrainstuff.com",
               :EncryptedPassword => "88AF8010F29099954CF0ECB014C8D83DD29DB0B57322B045875DD653705B89A7",
               :EDI_Name => "Generic/\Products",
               :SELECT_Columns => "p.StockStatus",
               :WHERE_Column => "p.ProductCode",
               :WHERE_Value => "#{product_code}" }

    uri.query = URI.encode_www_form(params)

    Net::HTTP.get(uri).match(/Stock.*\d+/)[0].sub(/.*>/,'').to_i
  end
end
