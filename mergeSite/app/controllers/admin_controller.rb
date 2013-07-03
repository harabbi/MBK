class AdminController < ActionController::Base
  http_basic_authenticate_with :name => "admin", :password => "secret4shane"
  protect_from_forgery
  layout 'application'

  def home
    @new_attr = MbkAttribute.new
    @logs = Log.all
    @staged = {}
    @staged[:pending]  = { :updated => Product.find_all_by_mbk_import_update(true).count,
                           :new     => Product.find_all_by_mbk_import_new(true).count }
    @staged[:magento]  = { :updated => StagedMagento.find_all_by_mbk_import_update(true).count,
                           :new     => StagedMagento.find_all_by_mbk_import_new(true).count }
    @staged[:volusion] = { :updated => StagedVolusion.find_all_by_mbk_import_update(true).count,
                           :new     => StagedVolusion.find_all_by_mbk_import_new(true).count }
    if params[:attr_name]
      @new_attr = MbkAttribute.new :name => params[:attr_name].downcase.gsub(/\s/,'_')
      if @new_attr.save
        flash.alert = "New Attribute #{@new_attr.name} Created"
        @new_attr = MbkAttribute.new
      else
        flash.alert = @new_attr.errors.full_messages.join(', ')
      end
    elsif params[:delete]
      MbkAttribute.find_by_name(params[:delete]).delete
      flash.alert = "Removed #{params[:delete]}..."
    end
  end

  def run_script
    script = ScriptRunner.find(params[:id])
    if system("cd /home/jason/MBK; ./" + script.name + " &")
      flash.alert = "Started #{script.name}."
    else
      flash.alert = "#{script.name} did not run."
    end
    redirect_to "/admin"
  end

  def upload
    @errors = []
    @new_products = [] 
    @updated_products = [] 
    @unchanged_products = []
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

      products.each do |product_code, product|
        debugger
        if (product_obj = Product.find_by_v_productcode(product_code.to_s)).nil?
          product_obj = Product.new
          product_obj.v_productcode = product_code.to_s
        end
        product.each do |attr_key, attr_value|
          attr_value = attr_value.value if attr_value.is_a? Spreadsheet::Formula # Force the value to be a value in the event that it's a formula
          attr_key = attr_key.to_s.underscore # Change the attr_key from search object to product object format unless mbk_attribute name
          attr_key = ("v_" + attr_key.to_s) unless MbkAttribute.all.map(&:name).include?(attr_key)
          if attr_key == "v_stockstatus" # Update the value if it's different
            xls_delta = attr_value.to_i - product_obj.v_stockstatus.to_i
            v_delta   = attr_value.to_i - (get_v_stockstatus(product_code) || 0 )
            product_obj.v_stockstatus = (product_obj.send(attr_key).to_i + xls_delta + v_delta) unless ( xls_delta + v_delta ) == 0
          else
            begin
              product_obj.send( (attr_key + "="), attr_value ) unless product_obj.send(attr_key) == attr_value
            rescue(NoMethodError)
              @errors.push("#{attr_key} is not an allowed column name.") unless errors.include?("#{attr_key} is not an allowed column name.")
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
        @errors.push "#{product_code} did not pass validation: #{product_obj.errors.full_messages.join(", ")}" unless product_obj.valid?
      end
      if @errors.empty?
        Parallel.each(@new_products) do |product|
          ActiveRecord::Base.connection.reconnect!
          product.save(validate: false)
        end
        Parallel.each(@updated_products) do |product, nevermind|
          ActiveRecord::Base.connection.reconnect!
          product.save(validate: false)
        end
      end
    end
    render "results"
  end
end
