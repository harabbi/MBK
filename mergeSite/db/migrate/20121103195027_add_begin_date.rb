class AddBeginDate < ActiveRecord::Migration
  def up
    add_column :product_searches , :displaybegindate_min, :datetime
    add_column :product_searches, :displaybegindate_max, :datetime
  end

  def down
    remove_column :product_searches, :displaybegindate_min
    remove_column :product_searches, :displaybegindate_max
  end
end
