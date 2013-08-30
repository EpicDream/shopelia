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

ActiveRecord::Schema.define(:version => 20130830132539) do

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
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "company"
    t.string   "access_info"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "cart_items", :force => true do |t|
    t.string   "uuid"
    t.integer  "cart_id"
    t.integer  "product_version_id"
    t.float    "price_shipping"
    t.float    "price"
    t.boolean  "monitor",            :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "developer_id"
    t.string   "tracker"
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "developers", :force => true do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "uuid"
    t.text     "user_agent"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "devices", ["uuid"], :name => "index_devices_on_uuid"

  create_table "email_redirections", :force => true do |t|
    t.string   "user_name"
    t.string   "destination"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "action"
    t.string   "tracker"
    t.string   "ip_address"
    t.integer  "developer_id"
    t.integer  "product_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "monetizable"
    t.integer  "device_id"
  end

  create_table "incidents", :force => true do |t|
    t.integer  "severity"
    t.string   "issue"
    t.text     "description"
    t.boolean  "processed",     :default => false
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "merchant_accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.string   "login"
    t.string   "password"
    t.boolean  "is_default"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "merchant_created", :default => false
    t.integer  "address_id"
  end

  create_table "merchants", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "url"
    t.string   "tc_url"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "vendor"
    t.boolean  "accepting_orders",    :default => true
    t.string   "billing_solution"
    t.string   "injection_solution"
    t.string   "cvd_solution"
    t.string   "domain"
    t.boolean  "should_clean_args",   :default => false
    t.text     "viking_data"
    t.boolean  "allow_iframe",        :default => true
    t.boolean  "vulcain_test_pass"
    t.string   "vulcain_test_output"
  end

  create_table "meta_orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "quantity",           :default => 1
    t.float    "price",              :default => 0.0
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "product_version_id"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.string   "uuid"
    t.string   "state_name"
    t.text     "message",                       :limit => 255
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
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
    t.string   "shipping_info"
    t.float    "billed_price_product"
    t.float    "billed_price_shipping"
    t.datetime "notification_email_sent_at"
    t.integer  "mangopay_wallet_id"
    t.integer  "mangopay_contribution_id"
    t.string   "mangopay_contribution_status"
    t.integer  "mangopay_contribution_amount"
    t.string   "payment_solution"
    t.string   "billing_solution"
    t.string   "injection_solution"
    t.string   "cvd_solution"
    t.string   "mangopay_contribution_message"
    t.integer  "mangopay_amazon_voucher_id"
    t.string   "mangopay_amazon_voucher_code"
    t.integer  "developer_id"
    t.string   "tracker"
    t.integer  "meta_order_id"
  end

  create_table "payment_cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "number"
    t.string   "exp_month"
    t.string   "exp_year"
    t.string   "cvv"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "mangopay_id"
    t.text     "crypted"
  end

  create_table "product_masters", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_versions", :force => true do |t|
    t.integer  "product_id"
    t.float    "price"
    t.float    "price_shipping"
    t.float    "price_strikeout"
    t.string   "shipping_info"
    t.text     "description"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.text     "color",           :limit => 255
    t.text     "size",            :limit => 255
    t.string   "name"
    t.boolean  "available"
    t.text     "image_url"
    t.string   "brand"
    t.string   "reference"
    t.text     "images"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "merchant_id"
    t.text     "url",                 :limit => 255
    t.text     "image_url",           :limit => 255
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.text     "description"
    t.integer  "product_master_id"
    t.string   "brand"
    t.datetime "versions_expires_at"
    t.boolean  "viking_failure"
    t.string   "reference"
    t.datetime "muted_until"
  end

  create_table "states", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statuses", :force => true do |t|
    t.integer  "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "url_matchers", :force => true do |t|
    t.text     "url"
    t.text     "canonical"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "url_matchers", ["canonical"], :name => "index_url_matchers_on_canonical"
  add_index "url_matchers", ["url"], :name => "index_url_matchers_on_url"

  create_table "user_verification_failures", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
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
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "civility"
    t.datetime "birthdate"
    t.integer  "nationality_id"
    t.string   "ip_address"
    t.string   "pincode"
    t.integer  "mangopay_id"
    t.integer  "developer_id"
    t.boolean  "visitor",                :default => false
    t.string   "tracker"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
