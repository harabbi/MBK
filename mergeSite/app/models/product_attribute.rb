class ProductAttribute < ActiveRecord::Base
  attr_accessible :mbk_attribute_name, :mbk_attribute_value, :v_productcode

  belongs_to :product, :foreign_key => "v_productcode"

  validate :attribute_name_valid
  validate :mbk_attribute_value, :presence => true
  validate :v_productcode, :presence => true

  def attribute_name_valid
    errors.add :mbk_attribute_name, "is not predefined." unless MbkAttribute.all.collect(&:name).include? mbk_attribute_name
  end
end
