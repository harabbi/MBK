class Product < ActiveRecord::Base
  set_table_name "vm_merged_products"
  set_primary_key "m_mbk_product_code"

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
     "v_stockstatus", "v_stocklowqtyalarm", "v_hideproduct"]
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
end
