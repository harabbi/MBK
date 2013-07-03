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
      @product_count = @products.count
      @products = @products.first(500)
      @preselected_optional_columns = @products.map{|p| p.product_attributes.map(&:mbk_attribute_name).uniq}.flatten.uniq 

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
              :filename => (@product_search.search_name || "products") + ".xls"
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
      begin
        Net::SSH.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |ssh|
          ssh.exec!("mkdir -p #{@product.mbk_image_dir}")
          begin
            Net::SCP.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |scp|
              scp.upload!(filename, @product.mbk_image_uri)
              @status << "Grand River: Oh... that looks good!\n"
            end
            ssh.exec!("cd /ebs/home/pwood/mbksite/media/catalog/product/cache")
            ssh.exec!("rm `find -name #{@product.v_productcode}`")
          rescue
            mbklogerr(__FILE__, "unseccessful image download with error: #{$!}")
            @status << "Grand River: Uh oh... it didn't go.\n"
          end
        end
      rescue => e
        @status << "Grand River: Login failed (#{e.message}: #{e.backtrace.first}\n"
      end

      #Volusion Image Upload
      begin
        Net::FTP.open('ftp.modeltrainstuff.com') do |ftp|
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
        end
      rescue => e
        @status << "Volusion: Login failed (#{e.message}: #{e.backtrace.first})\n"
      end
    end
  end

  def reindex_magento
    @product = Product.find_by_v_productcode(params[:productcode])
    begin
      Net::SSH.start(MBK_MAGENTO_SSH_HOST, MBK_MAGENTO_SSH_USER, :password => MBK_MAGENTO_SSH_PASS) do |ssh|
        ssh.exec!("php /ebs/home/pwood/mbksite/amartinez_customimportexport.php -r  < /dev/null")
        @status = "Reindexing was started... check the magento link in a few minutes to ensure success!"
      end
    rescue => e
      @status = "Reindex FAILED! (#{e.message}: #{e.backtrace.first})\n"
    end
  end

  private
  def get_v_stockstatus(product_code, try = 0)
    begin
      uri = URI("http://www.modeltrainstuff.com/net/WebService.aspx")
      params = { :Login => "philz@modeltrainstuff.com",
                 :EncryptedPassword => "75856D0BFF5EAD3E34E1C714AC07ED53A736591397D4C8F08B3F157EA85B6243",
                 :EDI_Name => "Generic\\Products",
                 :SELECT_Columns => "p.StockStatus",
                 :WHERE_Column => "p.ProductCode",
                 :WHERE_Value => "#{product_code}" }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get(uri)

      if (stock_line_match = response.match(/Stock.*\d+/)).nil?
        nil
      else
        stock_line_match[0].sub(/.*>/,'').to_i
      end
    rescue => e
      if try < 5
        get_v_stockstatus(product_code, (try + 1))
      else
        puts e.message
        puts e.backtrace.first
        return nil
      end
    end
  end
end
