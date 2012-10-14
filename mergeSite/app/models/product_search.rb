class ProductSearch < ActiveRecord::Base
  def self.ranged_searches
    [ 
      "productprice",
      "listprice",
      "stockstatus",
      "stocklowqtyalarm",
      "saleprice"
    ]
  end 

  def self.contains_searches
    [
      "productcode",
      "productname",
      "categoryids",
      "productmanufacturer",
      "yahoo_category"
    ]
  end 

  def self.boolean_searches
    [
      "hideproduct"
    ]
  end

  def search_results
    @results = Product.all
    self.class.contains_searches.each do |attr_string|
      unless self.send(attr_string).blank?
        @results = @results.select do |product| 
          product.send("v_" + attr_string) and product.send("v_" + attr_string).include? self.send(attr_string)
        end
      end
    end
    self.class.ranged_searches.each do |attr_string|
      attr_sym = (attr_string + "_max")
      @results = @results.select do |product| 
        product.send("v_" + attr_string) and self.send(attr_sym) > product.send("v_" + attr_string) 
      end unless self.send(attr_sym).blank?

      attr_sym = (attr_string + "_min")
      @results = @results.select do |product| 
        product.send("v_" + attr_string) and self.send(attr_sym) < product.send("v_" + attr_string) 
      end unless self.send(attr_sym).blank?
    end
    @results
  end
end
