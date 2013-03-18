class ProductAttribute < ActiveRecord::Base
  attr_accessible :mbk_attribute_name, :mbk_attribute_value, :v_productcode

  validate :attribute_name_valid

  def attribute_name_valid
    errors.add :mbk_attribute_name, "is not predefined." unless MBKAttribute.all.collect(&:name).include? mbk_attribute_name
  end
end
