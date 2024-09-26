class CreateConfigurations < ActiveRecord::Migration[7.2]
  def change
    create_table :configurations do |t|
      t.references :generator, null: false, foreign_key: true
      t.string :configuration_key
      t.string :label
      t.string :description
      t.string :fieldable_type
      t.bigint :fieldable_id
      t.boolean :is_required, default: false
      t.boolean :is_active, default: true

      t.timestamps

      t.index %i[configuration_key generator_id], unique: true
    end
  end
end
