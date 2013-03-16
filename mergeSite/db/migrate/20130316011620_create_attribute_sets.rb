class CreateAttributeSets < ActiveRecord::Migration
  def change
    create_table :attribute_sets do |t|

      t.timestamps
    end
  end
end
