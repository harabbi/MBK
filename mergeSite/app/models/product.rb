class Product < ActiveRecord::Base
  require 'net/http'

  self.table_name= "vm_merged_products"
  self.primary_key= "v_productcode"

  has_many :product_attributes, :finder_sql => Proc.new{"SELECT * FROM `product_attributes` WHERE `v_productcode` = '#{self.v_productcode}'"},
                                :foreign_key => "v_productcode", :autosave => true

  #validate :product_code_format
  
  def method_missing(name, *args, &block)
    if MbkAttribute.all.map(&:name).include?(name.to_s.sub(/=$/,'').sub(/_changed\?$/,''))
      if name.to_s.match(/=$/).nil?
        attr = self.product_attributes.detect{|attr| attr.mbk_attribute_name == name.to_s.sub(/_changed\?$/,'')}
        if name.to_s.match(/_changed?/).nil?
          attr.try(:mbk_attribute_value)
        else
          attr.try(:changed?)
        end
      else
        attr = ( self.product_attributes.detect {|attr| attr.mbk_attribute_name == name.to_s.sub(/=$/,'')} ||
                 self.product_attributes.new(:v_productcode => self.v_productcode, :mbk_attribute_name => name.to_s.sub(/=$/,'')) )
        attr.mbk_attribute_value=(args.first)
      end
    else
      super(name, *args, &block)
    end
  end

  def changed?
    self.product_attributes.any?(&:changed?) || super
  end

  #def product_code_format
    #if self.v_productcode.match(/[A-Z]{3}-[0-9]{3}-[0-9]{3}/).nil?
      #errors.add :v_productcode, "must be AAA-###-###"
    #end
  #end

  def self.price_attributes
    self.attribute_names.select do |attr|
      attr.include? "v_" and attr.include? "price" and !attr.include? "howtoget"
    end
  end

  def self.xls_attributes
    self.preview_attributes + self.xls_only_attributes
  end 

  def self.xls_only_attributes
    self.attribute_names.select do |attr|
      attr.include? "v_" and !self.preview_attributes.include? attr
    end
  end
  
  def self.preview_attributes
    ["v_productcode", "v_productname", "v_listprice", "v_productprice", "v_saleprice", "v_discountedprice_level1", "v_discountedprice_level3",
     "v_categoryids", "v_yahoo_category",
     "v_stockstatus", "v_stocklowqtyalarm", "v_hideproduct",
     "v_displaybegindate"]
  end

  def self.short_attributes
    attributes = []
    self.xls_attributes.each do |attr|
      attributes.push(attr) if attr.include? "price"
    end
    attributes.push "v_categoryids"
    attributes.push "v_maxqty"
    attributes.push "v_stockstatus"
  end

  def self.long_attributes
    attributes = []
    self.xls_attributes.select do |attr|
      attributes.push(attr) if attr.include? "description"
    end
    attributes.push "v_metatag_title"
    attributes.push "v_productname"
    attributes
  end
  
  def self.short_attributes
    "v_categoryids"
  end

  def v_image_uri(size = 2)
    uri = "http://a248.e.akamai.net/origin-cdn.volusion.com/ztna9.tft5b/v/vspfiles/photos/#{v_image_name(size)}"
  end

  def v_image_name(size)
    "#{v_productcode}-#{size}.jpg".gsub(' ', '%20')
  end

  def v_product_path
    "http://www.modeltrainstuff.com/ProductDetails.asp?ProductCode=#{v_productcode}"
  end

  def mbk_image_dir
    "/ebs/home/pwood/mbksite/media/catalog/product/#{v_productcode.upcase[0]}/#{v_productcode.upcase[1]}"
  end
  
  def mbk_image_uri
    "/ebs/home/pwood/mbksite/media/catalog/product/#{v_productcode.upcase[0]}/#{v_productcode.upcase[1]}/#{v_productcode}.jpg"
  end

  def mbk_product_path
    "http://dev.mbk.thegrandriver.net/#{v_productname.downcase.gsub(/[^\w]/, ' ').gsub(/ +/, ' ').gsub(/ /, '-').gsub(/-$/, '')}.html"
  end
end
