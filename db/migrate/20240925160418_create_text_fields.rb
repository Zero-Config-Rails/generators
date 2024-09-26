class CreateTextFields < ActiveRecord::Migration[7.2]
  def change
    create_table :text_fields do |t|
      t.string :default_value

      t.timestamps
    end
  end
end
