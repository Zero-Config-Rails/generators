# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_25_160458) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boolean_fields", force: :cascade do |t|
    t.boolean "default_value"
    t.string "display_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configurations", force: :cascade do |t|
    t.bigint "generator_id", null: false
    t.string "configuration_key"
    t.string "label"
    t.string "description"
    t.string "fieldable_type"
    t.bigint "fieldable_id"
    t.boolean "is_required", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuration_key", "generator_id"], name: "index_configurations_on_configuration_key_and_generator_id", unique: true
    t.index ["generator_id"], name: "index_configurations_on_generator_id"
  end

  create_table "dropdown_fields", force: :cascade do |t|
    t.json "options"
    t.string "default_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "generators", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name"
    t.string "short_description"
    t.text "description"
    t.string "git_url"
    t.string "user_guide_urls", default: [], array: true
    t.string "logo_url"
    t.string "invocation_command"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_generators_on_identifier", unique: true
    t.index ["name"], name: "index_generators_on_name", unique: true
  end

  create_table "text_fields", force: :cascade do |t|
    t.string "default_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "configurations", "generators"
end
