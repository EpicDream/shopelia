# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130517144650) do

  create_table "addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "code_name"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "country_id"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company"
    t.string   "access_info"
  end

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "developers", :force => true do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_redirections", :force => true do |t|
    t.string   "user_name"
    t.string   "destination"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.string   "login"
    t.string   "password"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "merchant_created", :default => false
    t.integer  "address_id"
  end

  create_table "merchants", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "url"
    t.string   "tc_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor"
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity",          :default => 1
    t.float    "price_product",     :default => 0.0
    t.string   "product_title"
    t.string   "product_image_url"
    t.string   "price_text"
    t.string   "delivery_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price_delivery"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.string   "uuid"
    t.string   "state_name"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "questions_json"
    t.string   "error_code"
    t.integer  "address_id"
    t.integer  "retry_count"
    t.integer  "merchant_account_id"
    t.integer  "payment_card_id"
    t.float    "expected_price_product"
    t.float    "expected_price_shipping"
    t.float    "expected_price_total"
    t.float    "prepared_price_product"
    t.float    "prepared_price_shipping"
    t.float    "prepared_price_total"
    t.float    "billed_price_total"
    t.string   "shipping_information"
    t.float    "billed_price_product"
    t.float    "billed_price_shipping"
  end

  create_table "payment_cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "number"
    t.string   "exp_month"
    t.string   "exp_year"
    t.string   "cvv"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "address_id"
    t.string   "number"
    t.integer  "line_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "merchant_id"
    t.string   "url"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "psp_payment_cards", :force => true do |t|
    t.integer  "payment_card_id"
    t.integer  "psp_id"
    t.integer  "remote_payment_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "psp_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "psp_id"
    t.integer  "remote_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "psps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.integer  "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "civility"
    t.datetime "birthdate"
    t.integer  "nationality_id"
    t.string   "ip_address"
    t.string   "pincode"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
