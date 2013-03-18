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
    puts self.inspect
    search_strings = []

    unless self.send(:displaybegindate_max).blank?
      search_date = self.send(:displaybegindate_max).strftime("%Y-%m-%d 00:00:00")
      search_strings.push "`v_displaybegindate` < '#{search_date}'"
    end
    
    unless self.send(:displaybegindate_min).blank?
      search_date = self.send(:displaybegindate_min).strftime("%Y-%m-%d 00:00:00")
      search_strings.push "`v_displaybegindate` > '#{search_date}'"
    end

    self.class.contains_searches.each do |attr_string|
      search_strings.push "`v_#{attr_string}` like '%#{self.send(attr_string)}%'" unless self.send(attr_string).blank?
    end

    self.class.ranged_searches.each do |attr_string|
      attr_sym = (attr_string + "_max")
      search_strings.push "`v_#{attr_string}` > #{self.send(attr_sym)}" unless self.send(attr_sym).blank?

      attr_sym = (attr_string + "_min")
      search_strings.push "`v_#{attr_string}` < #{self.send(attr_sym)}" unless self.send(attr_sym).blank?
    end

  @results = Product.where( search_strings.join(' AND ') )
  end
end
