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

ActiveRecord::Schema[8.0].define(version: 2025_12_15_184623) do
  create_table "character_links", force: :cascade do |t|
    t.integer "character_id", null: false
    t.string "url"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_links_on_character_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.date "birth_date"
    t.date "death_date"
    t.string "relationship"
    t.string "nationality"
    t.string "occupation"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.string "title"
    t.date "event_date"
    t.date "end_date"
    t.string "location"
    t.string "entry_type"
    t.text "description"
    t.text "significance"
    t.integer "source_id"
    t.string "page_reference"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_year"
    t.integer "event_month"
    t.integer "event_day"
    t.integer "end_year"
    t.integer "end_month"
    t.integer "end_day"
    t.index ["source_id"], name: "index_entries_on_source_id"
  end

  create_table "entry_characters", force: :cascade do |t|
    t.integer "entry_id", null: false
    t.integer "character_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_entry_characters_on_character_id"
    t.index ["entry_id"], name: "index_entry_characters_on_entry_id"
  end

  create_table "entry_sources", force: :cascade do |t|
    t.integer "entry_id", null: false
    t.integer "source_id", null: false
    t.string "page_reference"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author"
    t.string "link"
    t.index ["entry_id"], name: "index_entry_sources_on_entry_id"
    t.index ["source_id"], name: "index_entry_sources_on_source_id"
  end

  create_table "source_links", force: :cascade do |t|
    t.integer "source_id", null: false
    t.string "url"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_source_links_on_source_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "source_type"
    t.date "publication_date"
    t.string "publisher"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "character_links", "characters"
  add_foreign_key "entries", "sources"
  add_foreign_key "entry_characters", "characters"
  add_foreign_key "entry_characters", "entries"
  add_foreign_key "entry_sources", "entries"
  add_foreign_key "entry_sources", "sources"
  add_foreign_key "source_links", "sources"
end
