class Product < ActiveRecord::Base
  set_table_name "vm_merged_products"
  set_primary_key "m_mbk_product_code"
end
