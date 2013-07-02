class AddScriptRunners < ActiveRecord::Migration
  def change
    create_table :script_runners do |t|
      t.string :name
      t.string :description
      t.string :confirm_message
    end
  end
end
