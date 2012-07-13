$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

require 'mbk_utils.rb'

at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    mbkloginfo(__FILE__, 'successfully finished')
  else
    code = $!.is_a?(SystemExit) ? $!.status : 1
    mbklogerr(__FILE__, "unseccessful failure with code #{code}")
  end
end

mbk_app_init(__FILE__)

export_db = ARGV[0].to_s
export_db = "mbk_grandriver_export_#{Time.now.strftime("%Y%m%d")}" if export_db.length < 1
mbk_db_create_run(export_db)

client  = mbk_magento_init()
session = mbk_magento_login(client)

keys = [] # define outside scope of loop
products = []
prices = []
price_keys = []

LAST_ID = 142
START_ID = x = 139
while(x < LAST_ID)
  values = [] # ensure empty
  price_values = ["#{x}"]
  #begin
    response = client.request :call do 
      soap.body = {:session => session,:method => 'catalog_product.info', :id=>x } 
    end
    response[:call_response][:call_return][:item].each do |pair| 
      keys.push pair[:key] if x == START_ID
      case pair[:value]
      when Nori::StringWithAttributes
        values.push pair[:value]
      when Hash
        if pair[:key] == "tier_price"
          if pair[:value][:item]
            price_keys = ["product_id"]
            pair[:value][:item].each do |price| 
              price[:item].each do |attr| 
                price_keys.push(attr[:key])
                price_values.push(attr[:value])
              end
            end
            prices.push price_values.join(',')
          else
            price_values.push ""
          end
        else
          values.push pair[:value][:item]
        end
      when NilClass
        values.push ""
      end 
    end
  #rescue
    #puts "#{x} failed"
  #end
  x+=1
  products.push values.join(',')
end

File.open("test.csv", "w") do |f| 
  f.write "#{keys.join(',')}\n"
  products.each do |p| 
    f.write "#{p}\n"
  end
end

File.open("price.csv", "w") do |f|
  f.write "#{price_keys.join(',')}\n"
  prices.each do |p|
    f.write "#{p}\n"
  end
end
