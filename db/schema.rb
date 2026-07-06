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

ActiveRecord::Schema[8.1].define(version: 2026_07_06_212927) do
  create_table "account_users", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "user_role", default: 0
  end

  create_table "accounts", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "owner_id"
    t.datetime "updated_at", null: false
  end

  create_table "audits1984_audits", force: :cascade do |t|
    t.integer "auditor_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "session_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["auditor_id"], name: "index_audits1984_audits_on_auditor_id"
    t.index ["session_id"], name: "index_audits1984_audits_on_session_id"
  end

  create_table "console1984_commands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "sensitive_access_id"
    t.integer "session_id", null: false
    t.text "statements"
    t.datetime "updated_at", null: false
    t.index ["sensitive_access_id"], name: "index_console1984_commands_on_sensitive_access_id"
    t.index ["session_id", "created_at", "sensitive_access_id"], name: "on_session_and_sensitive_chronologically"
  end

  create_table "console1984_sensitive_accesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "justification"
    t.integer "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_console1984_sensitive_accesses_on_session_id"
  end

  create_table "console1984_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_console1984_sessions_on_created_at"
    t.index ["user_id", "created_at"], name: "index_console1984_sessions_on_user_id_and_created_at"
  end

  create_table "console1984_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["username"], name: "index_console1984_users_on_username"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email_address"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_customers_on_account_id"
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
  end

  create_table "inventory_groups", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_inventory_groups_on_account_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.integer "inventory_group_id"
    t.string "name"
    t.integer "parent_id"
    t.integer "price_cents"
    t.string "price_currency"
    t.integer "unit_type", default: 0
    t.datetime "updated_at", null: false
    t.string "weight_unit"
    t.decimal "weight_value", precision: 10, scale: 2
    t.index ["account_id"], name: "index_inventory_items_on_account_id"
    t.index ["deleted_at"], name: "index_inventory_items_on_deleted_at"
    t.index ["inventory_group_id"], name: "index_inventory_items_on_inventory_group_id"
    t.index ["parent_id"], name: "index_inventory_items_on_parent_id"
  end

  create_table "inventory_levels", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "inventory_item_id", null: false
    t.integer "location_id", null: false
    t.integer "quantity", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_inventory_levels_on_account_id"
    t.index ["inventory_item_id"], name: "index_inventory_levels_on_inventory_item_id"
    t.index ["location_id"], name: "index_inventory_levels_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_locations_on_account_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "customers", "accounts"
  add_foreign_key "inventory_groups", "accounts"
  add_foreign_key "inventory_items", "accounts"
  add_foreign_key "inventory_items", "inventory_groups"
  add_foreign_key "inventory_items", "inventory_items", column: "parent_id"
  add_foreign_key "inventory_levels", "accounts"
  add_foreign_key "inventory_levels", "inventory_items"
  add_foreign_key "inventory_levels", "locations"
  add_foreign_key "locations", "accounts"
  add_foreign_key "sessions", "users"
end
