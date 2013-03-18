class CreateMbkAttributes < ActiveRecord::Migration
  def change
    create_table :mbk_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end
