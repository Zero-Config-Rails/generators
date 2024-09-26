class CreateBooleanFields < ActiveRecord::Migration[7.2]
  def change
    create_table :boolean_fields do |t|
      t.boolean :default_value
      t.string :display_type

      t.timestamps
    end
  end
end
