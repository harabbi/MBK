class ApplicationController < ActionController::Base
  require 'spreadsheet'
  require 'net/http'
  require 'net/ssh'
  require 'net/scp'
  require 'net/ftp'
  require '../scripts/mbk_params.rb'
  require 'RMagick'

  protect_from_forgery
  def home
    if params[:attr_name] and params[:attr_pass]
      @new_attr = MbkAttribute.new :name => params[:attr_name].downcase.gsub(/\s/,'_')
      if params[:attr_pass] == "shaneATTRp@55"
        @new_attr.save
      else
        @status = "Wrong Password"
      end
    else
      @new_attr = MbkAttribute.new
    end

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
        @product_search = ProductSearch.new(params[:product_search])
      elsif params[:commit] == "Save New Search"
        @product_search = ProductSearch.new(params[:product_search])
        @product_search.save!
      else # Update and Search
        @product_search = ProductSearch.find(params[:product_search][:id])
        @product_search.update_attributes(params[:product_search])
      end

      @products = @product_search.search_results
      @preselected_optional_columns = @products.map{|p| p.product_attributes.map(&:mbk_attribute_name).uniq}.flatten.uniq 

      if @products.count > 1000
        @status = "Your search rendered more than 1000 products.  Please try something a little smaller..."
        render 'home'
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
    send_data @product_search.search_results.to_xls(:columns => (Product.xls_attributes + Array.wrap(params[:optional_attributes])),
              :headers => (Product.xls_attributes + Array.wrap(params[:optional_attributes])).collect{|attr| attr.gsub("v_", "").camelize}),
              :filename => "products.xls"
  end

  def upload
    @errors = []
    uploaded_io = params[:file]
    if uploaded_io.nil?
      @errors.push "No file!"
    else
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
          # Change the attr_key from search object to product object format unless mbk_attribute name
          attr_key = attr_key.to_s.underscore
          attr_key = ("v_" + attr_key.to_s) unless MbkAttribute.all.map(&:name).include?(attr_key)

          # Update the value if it's different
          if attr_key == "v_stockstatus"
            xls_delta = attr_value - product_obj.v_stockstatus
            v_delta = get_v_stockstatus(product_code) || 0

            unless ( xls_delta + v_delta ) == 0
              product_obj.v_stockstatus = (product_obj.send(attr_key) + xls_delta + v_delta)
            end
          else
            begin
              unless product_obj.send(attr_key) == attr_value
                product_obj.send( (attr_key + "="), attr_value )
              end
            rescue(NoMethodError)
              unless @errors.include?("#{attr_key} is not an allowed column name.")
                @errors.push("#{attr_key} is not an allowed column name.")
              end
            end
          end
        end

        if product_obj.new_record?
          product_obj.mbk_import_new = true
          @new_products.push product_obj

        elsif product_obj.changed?
          product_obj.mbk_import_update = true
          changed_attrs = (product_obj.attribute_names + MbkAttribute.all.map(&:name)).select do |attr|
            !['mbk_import_update', 'mbk_import_new'].include? attr and product_obj.send(attr + '_changed?')
          end.map(&:camelize).join(',').gsub('v_', '')

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
    end

    render "results"
  end

  def change_preview
    @product = Product.find_by_v_productcode(params[:productcode])
    @filename = "public/uploads/#{Time.now.to_i.to_s}.jpg"

    if params[:image].blank? or params[:image].path.blank?
      @status = "You didn't supply an image!"
    else
      image = Magick::Image.read(params[:image].path).first
      image.write(@filename)
    end
  end

  def change_image
    @product = Product.find_by_v_productcode(params[:productcode])

    if request.method == "POST"

      filename = params[:temp_filename]
      image = Magick::Image.read(filename).first
      @status ||= ""

      #MBK Image Upload
      Net::SSH.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |ssh|
        begin
          ssh.exec!("mkdir -p #{@product.mbk_image_dir}")
          Net::SCP.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |scp|
            begin
              scp.upload!(filename, @product.mbk_image_uri)
              @status << "Grand River: Oh... that looks good!\n"
            rescue
              mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
              @status << "Grand River: Uh oh... it didn't go.\n"
            end
          end
          ssh.exec!("cd /ebs/home/pwood/mbksite/media/catalog/product/cache")
          ssh.exec!("rm `find -name #{@product.v_productcode}`")
        rescue
          @status << "Grand River: Login failed\n"
        end
      end

      #Volusion Image Upload
      Net::FTP.open('ftp.modeltrainstuff.com') do |ftp|
        begin
          ftp.login(V_FTP_USER, V_FTP_PASS)
          ftp.chdir('vspfiles/photos')

          # pure file
          ftp.putbinaryfile(filename, @product.v_image_name("2"))

          # width = 150px 
          image_w150 = image.resize_to_fit(150, 150)
          image_w150.write(filename.sub('.jpg', '-w150.jpg'))
          ftp.putbinaryfile(filename.sub('.jpg', '-w150.jpg'), @product.v_image_name("0"))
          ftp.putbinaryfile(filename.sub('.jpg', '-w150.jpg'), @product.v_image_name("1"))
          ftp.putbinaryfile(filename.sub('.jpg', '-w150.jpg'), @product.v_image_name("2T"))

          # height = 25px
          image_h25 = image.resize_to_fit(25, 25)
          image_h25.write(filename.sub('.jpg', '-h25.jpg'))
          ftp.putbinaryfile(filename.sub('.jpg', '-h25.jpg'), @product.v_image_name("2S"))

          # width = 50px
          image_w50 = image.resize_to_fit(50, 50)
          image_w50.write(filename.sub('.jpg', '-w50.jpg'))
          ftp.putbinaryfile(filename.sub('.jpg', '-w50.jpg'), @product.v_image_name("2t_mobile").downcase)
          @status << "Volusion: That's a nice photo.\n"
        rescue
          @status << "Volusion: Login failed\n"
        end
      end
    end

    #TODO
    #rm filename.sub('.jpg', '*.jpg')
  end

  def reindex_magento
    @product = Product.find_by_v_productcode(params[:productcode])
    
    Net::SSH.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |ssh|
      begin
        ssh.exec!("php /ebs/home/pwood/mbksite/amartinez_customimportexport.php -r  < /dev/null")
        @status = "Reindexing was started... check the magento link in a few minutes to ensure success!"
      rescue
        @status = "Reindex FAILED!"
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

    response = Net::HTTP.get(uri)

    if (stock_line_match = response.match(/Stock.*\d+/)).nil?
      puts response
    else
      stock_line_match[0].sub(/.*>/,'').to_i
    end
  end
end
