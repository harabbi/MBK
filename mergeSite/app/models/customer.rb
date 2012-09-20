class Customer < ActiveRecord::Base
  set_table_name "vm_merged_customers"

  def self.xls_attributes
    self.attribute_names.select do |attr|
      attr.include? "v_"
    end
  end 
end
