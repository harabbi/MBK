class Product < ActiveRecord::Base
  set_table_name "vm_merged_products"
  set_primary_key "m_mbk_product_code"

  def self.hidden_attributes
    ["v_stocklowqtyalarm", "v_hideproduct"]
  end

  def self.xls_attributes
    self.attribute_names.select do |attr|
      attr.include? "v_" and !self.hidden_attributes.include? attr
    end
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
    self.xls_attributes.each do |attr|
      attributes.push(attr) if attr.include? "description"
    end
    attributes.push "v_metatag_title"
    attributes.push "v_productname"
    attributes.push "v_hideproduct"
  end
end
