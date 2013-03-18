class CreateProductAttributes < ActiveRecord::Migration
  def change
    create_table :product_attributes do |t|
      t.string :v_productcode
      t.string :mbk_attribute_name
      t.string :mbk_attribute_value

      t.timestamps
    end
  end
end
