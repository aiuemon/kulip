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

ActiveRecord::Schema[8.1].define(version: 2026_03_18_070956) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "auth_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "local_auth_enabled", default: true, null: false
    t.boolean "local_auth_show_on_login", default: true, null: false
    t.boolean "self_signup_enabled", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "identity_providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "name", null: false
    t.string "provider_type", null: false
    t.json "settings", default: {}, null: false
    t.boolean "show_on_login", default: true, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_identity_providers_on_enabled"
    t.index ["provider_type"], name: "index_identity_providers_on_provider_type"
    t.index ["slug"], name: "index_identity_providers_on_slug", unique: true
  end

  create_table "image_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_image_groups_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "image_group_id"
    t.string "name"
    t.text "ocr_result"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["image_group_id"], name: "index_images_on_image_group_id"
    t.index ["status"], name: "index_images_on_status"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "ocr_settings", force: :cascade do |t|
    t.string "api_key", default: ""
    t.datetime "created_at", null: false
    t.string "endpoint", default: ""
    t.string "model", default: ""
    t.json "options", default: {}
    t.text "prompt", default: ""
    t.integer "timeout", default: 300
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "image_groups", "users"
  add_foreign_key "images", "image_groups"
  add_foreign_key "images", "users"
end
