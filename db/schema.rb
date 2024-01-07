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

ActiveRecord::Schema[7.1].define(version: 2023_12_29_171508) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "monthly_due_transactions", force: :cascade do |t|
    t.string "is_paid"
    t.float "amount"
    t.bigint "user_id"
    t.string "year"
    t.string "month"
    t.bigint "monthly_due_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["monthly_due_id"], name: "index_monthly_due_transactions_on_monthly_due_id"
    t.index ["user_id"], name: "index_monthly_due_transactions_on_user_id"
  end

  create_table "monthly_dues", force: :cascade do |t|
    t.string "amount"
    t.string "is_current"
    t.bigint "subdivision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdivision_id"], name: "index_monthly_dues_on_subdivision_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "water_billing_id"
    t.text "name"
    t.text "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["water_billing_id"], name: "index_photos_on_water_billing_id"
  end

  create_table "subdivisions", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "block"
    t.string "lot"
    t.string "street"
    t.bigint "subdivision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin", default: false
    t.boolean "subdivision_admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["subdivision_id"], name: "index_users_on_subdivision_id"
  end

  create_table "water_billing_transactions", force: :cascade do |t|
    t.integer "current_reading", default: 0
    t.integer "previous_reading", default: 0
    t.integer "consumption", default: 0
    t.string "is_paid"
    t.float "bill_amount", default: 0.0
    t.float "paid_amount", default: 0.0
    t.integer "month"
    t.integer "year"
    t.bigint "user_id"
    t.bigint "subdivision_id"
    t.bigint "water_billing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdivision_id"], name: "index_water_billing_transactions_on_subdivision_id"
    t.index ["user_id"], name: "index_water_billing_transactions_on_user_id"
    t.index ["water_billing_id"], name: "index_water_billing_transactions_on_water_billing_id"
  end

  create_table "water_billings", force: :cascade do |t|
    t.integer "month"
    t.integer "year"
    t.integer "mother_meter_current_reading", default: 0
    t.integer "mother_meter_previous_reading", default: 0
    t.integer "consumption", default: 0
    t.string "is_paid"
    t.integer "residence_count", default: 0
    t.float "bill_amount", default: 0.0
    t.float "per_cubic_price", default: 0.0
    t.float "paid_amount", default: 0.0
    t.integer "number_residence", default: 0
    t.bigint "subdivision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month", "year"], name: "index_water_billings_on_month_and_year", unique: true
    t.index ["subdivision_id"], name: "index_water_billings_on_subdivision_id"
  end

  add_foreign_key "photos", "water_billings"
end
