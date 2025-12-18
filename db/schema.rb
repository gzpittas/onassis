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

ActiveRecord::Schema[8.0].define(version: 2025_12_18_155823) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_characters", force: :cascade do |t|
    t.integer "article_id", null: false
    t.integer "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_characters_on_article_id"
    t.index ["character_id"], name: "index_article_characters_on_character_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "publication"
    t.string "author"
    t.date "publication_date"
    t.string "url"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.boolean "lead_character", default: false
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

  create_table "entry_articles", force: :cascade do |t|
    t.integer "entry_id", null: false
    t.integer "article_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_entry_articles_on_article_id"
    t.index ["entry_id"], name: "index_entry_articles_on_entry_id"
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

  create_table "entry_images", force: :cascade do |t|
    t.integer "entry_id", null: false
    t.integer "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_entry_images_on_entry_id"
    t.index ["image_id"], name: "index_entry_images_on_image_id"
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

  create_table "image_characters", force: :cascade do |t|
    t.integer "image_id", null: false
    t.integer "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_image_characters_on_character_id"
    t.index ["image_id"], name: "index_image_characters_on_image_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "title"
    t.date "taken_date"
    t.string "location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_url"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "article_characters", "articles"
  add_foreign_key "article_characters", "characters"
  add_foreign_key "character_links", "characters"
  add_foreign_key "entries", "sources"
  add_foreign_key "entry_articles", "articles"
  add_foreign_key "entry_articles", "entries"
  add_foreign_key "entry_characters", "characters"
  add_foreign_key "entry_characters", "entries"
  add_foreign_key "entry_images", "entries"
  add_foreign_key "entry_images", "images"
  add_foreign_key "entry_sources", "entries"
  add_foreign_key "entry_sources", "sources"
  add_foreign_key "image_characters", "characters"
  add_foreign_key "image_characters", "images"
  add_foreign_key "source_links", "sources"
end
