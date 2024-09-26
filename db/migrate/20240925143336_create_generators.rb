class CreateGenerators < ActiveRecord::Migration[7.2]
  def change
    create_table :generators do |t|
      t.string :name
      t.string :short_description
      t.text :description
      t.string :git_url
      t.string :user_guide_urls, array: true, default: []
      t.string :logo_url
      t.string :invocation_command
      t.boolean :is_active, default: true

      t.timestamps

      t.index :name, unique: true
    end
  end
end
