class CreateDropdownFields < ActiveRecord::Migration[7.2]
  def change
    create_table :dropdown_fields do |t|
      t.json :options
      t.string :default_value

      t.timestamps
    end
  end
end
