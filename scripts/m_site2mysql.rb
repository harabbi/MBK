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

require 'savon'

client = Savon::Client.new do
  wsdl.document = "http://www.mbk.thegrandriver.net/index.php/api/?wsdl"
  end

  client.http.auth.basic "mbk", "mbkp@ss"

  response = client.request :login do
    soap.body = { :username => 'philz', :apiKey => 'apikey' }
  end

  session =  response[:login_response][:login_return]

  first = last = false
  LAST_ID = 142
  x=139
  products = {}
  while(!last and x < LAST_ID)
    begin
      response = client.request :call do soap.body = {:session => session,:method => 'catalog_product.info', :id=>x } end
      first = true
      products[x] = {}; response[:call_response][:call_return][:item].each{|pair| products[x][pair[:key]] = pair[:value]}
      puts "Got #{x}"
    rescue
      puts "#{x} failed"
      if first
        last = true
      end
    end
    x+=1
  end

  File.open("test_#{Time.now.to_i}.txt", "w") do |f|
    f.puts products[products.keys.first].keys.join(",_")
    products.keys.each do |k|
      f.puts "#{k}:"
      f.puts products[k].values.join(",_")
    end
  end
