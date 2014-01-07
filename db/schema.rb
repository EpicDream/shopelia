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

ActiveRecord::Schema.define(:version => 20140107104544) do

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

  create_table "algolia_tags", :force => true do |t|
    t.string   "name"
    t.string   "kind"
    t.integer  "count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "billing_transactions", :force => true do |t|
    t.integer  "meta_order_id"
    t.integer  "user_id"
    t.string   "processor"
    t.integer  "amount"
    t.boolean  "success"
    t.integer  "mangopay_contribution_id"
    t.integer  "mangopay_contribution_amount"
    t.string   "mangopay_contribution_message"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "mangopay_destination_wallet_id"
    t.integer  "mangopay_transfer_id"
  end

  create_table "blogs", :force => true do |t|
    t.string   "url"
    t.string   "name"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "flinker_id"
    t.string   "avatar_url"
    t.string   "country"
    t.boolean  "scraped",     :default => true
    t.boolean  "skipped",     :default => false
    t.boolean  "can_comment", :default => false
  end

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
    t.string   "uuid"
    t.integer  "kind"
  end

  create_table "cashfront_rules", :force => true do |t|
    t.integer  "merchant_id"
    t.integer  "category_id"
    t.integer  "developer_id"
    t.integer  "user_id"
    t.float    "rebate_percentage"
    t.float    "max_rebate_value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "device_id"
    t.integer  "max_orders_count"
  end

  create_table "collection_items", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "product_id"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "collection_tags", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "tag_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "collections", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "public",             :default => false
    t.string   "image_size"
    t.integer  "rank"
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
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
  end

  add_index "developers", ["confirmation_token"], :name => "index_developers_on_confirmation_token"
  add_index "developers", ["email"], :name => "index_developers_on_email"
  add_index "developers", ["reset_password_token"], :name => "index_developers_on_reset_password_token"

  create_table "developers_products", :id => false, :force => true do |t|
    t.integer "developer_id"
    t.integer "product_id"
  end

  add_index "developers_products", ["product_id"], :name => "index_developers_products_on_product_id"

  create_table "devices", :force => true do |t|
    t.string   "uuid"
    t.text     "user_agent"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "user_id"
    t.string   "push_token"
    t.string   "os"
    t.string   "os_version"
    t.string   "phone"
    t.string   "referrer"
    t.integer  "build"
    t.string   "version"
    t.boolean  "pending_answer"
    t.boolean  "autoreplied",    :default => false
    t.boolean  "is_dev"
    t.integer  "rating"
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

  add_index "events", ["developer_id"], :name => "index_events_on_developer_id"
  add_index "events", ["device_id"], :name => "index_events_on_device_id"
  add_index "events", ["product_id"], :name => "index_events_on_product_id"

  create_table "flinker_authentications", :force => true do |t|
    t.string   "flinker_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "flinker_follows", :force => true do |t|
    t.integer  "flinker_id"
    t.integer  "follow_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "flinker_follows", ["flinker_id"], :name => "index_flinker_follows_on_flinker_id"
  add_index "flinker_follows", ["follow_id"], :name => "index_flinker_follows_on_follow_id"

  create_table "flinker_likes", :force => true do |t|
    t.integer  "flinker_id"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "flinker_likes", ["flinker_id", "resource_type", "resource_id"], :name => "index_flinker_likes_on_all_fields"
  add_index "flinker_likes", ["resource_type", "resource_id"], :name => "index_flinker_likes_on_resource_type_and_resource_id"

  create_table "flinkers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_publisher",           :default => false
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
    t.string   "authentication_token"
    t.string   "username"
    t.integer  "country_id"
    t.integer  "followers_count",        :default => 0
    t.boolean  "staff_pick",             :default => false
    t.integer  "looks_count",            :default => 0
    t.integer  "follows_count",          :default => 0
    t.integer  "likes_count",            :default => 0
  end

  add_index "flinkers", ["authentication_token"], :name => "index_flinkers_on_authentication_token", :unique => true
  add_index "flinkers", ["email"], :name => "index_flinkers_on_email", :unique => true
  add_index "flinkers", ["reset_password_token"], :name => "index_flinkers_on_reset_password_token", :unique => true

  create_table "images", :force => true do |t|
    t.string   "url",                  :limit => 1024
    t.string   "type"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "picture_fingerprint"
    t.string   "picture_sizes"
    t.integer  "resource_id"
    t.integer  "display_order"
  end

  add_index "images", ["resource_id", "type"], :name => "index_images_on_resource_id_and_type"

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

  create_table "look_products", :force => true do |t|
    t.integer  "look_id"
    t.integer  "product_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "code"
    t.string   "brand"
  end

  add_index "look_products", ["look_id"], :name => "index_look_products_on_look_id"

  create_table "looks", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "url"
    t.integer  "flinker_id"
    t.datetime "published_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "is_published", :default => false
    t.string   "description"
  end

  add_index "looks", ["is_published"], :name => "index_looks_on_is_published"
  add_index "looks", ["uuid"], :name => "index_looks_on_uuid"

  create_table "mappings", :force => true do |t|
    t.text     "mapping"
    t.string   "domain"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.boolean  "accepting_orders",    :default => false
    t.string   "billing_solution"
    t.string   "injection_solution"
    t.string   "cvd_solution"
    t.string   "domain"
    t.boolean  "should_clean_args",   :default => false
    t.text     "viking_data"
    t.boolean  "vulcain_test_pass"
    t.string   "vulcain_test_output"
    t.boolean  "allow_quantities",    :default => true
    t.boolean  "rejecting_events",    :default => false
    t.boolean  "multiple_addresses",  :default => false
    t.integer  "mapping_id"
    t.integer  "products_count"
  end

  add_index "merchants", ["mapping_id"], :name => "index_merchants_on_mapping_id"

  create_table "merkav_transactions", :force => true do |t|
    t.integer  "virtual_card_id"
    t.string   "token"
    t.string   "optkey"
    t.integer  "amount"
    t.datetime "executed_at"
    t.string   "status"
    t.integer  "merkav_transaction_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "vad_id"
  end

  create_table "messages", :force => true do |t|
    t.text     "content"
    t.text     "data"
    t.boolean  "from_admin"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "device_id"
    t.datetime "read_at"
    t.string   "collection_uuid"
    t.string   "gift_gender"
    t.string   "gift_age"
    t.string   "gift_budget"
    t.integer  "rating"
  end

  create_table "meta_orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "address_id"
    t.integer  "payment_card_id"
    t.integer  "mangopay_wallet_id"
    t.string   "billing_solution"
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
    t.text     "message"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "questions_json"
    t.string   "error_code"
    t.integer  "retry_count"
    t.integer  "merchant_account_id"
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
    t.string   "payment_solution"
    t.string   "injection_solution"
    t.string   "cvd_solution"
    t.integer  "developer_id"
    t.string   "tracker"
    t.integer  "meta_order_id"
    t.float    "expected_cashfront_value"
    t.text     "gift_message"
    t.string   "informations"
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

  create_table "payment_transactions", :force => true do |t|
    t.integer  "order_id"
    t.string   "processor"
    t.integer  "mangopay_amazon_voucher_id"
    t.string   "mangopay_amazon_voucher_code"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "amount"
    t.integer  "mangopay_source_wallet_id"
    t.integer  "virtual_card_id"
  end

  create_table "posts", :force => true do |t|
    t.integer  "blog_id"
    t.datetime "published_at"
    t.string   "link"
    t.text     "content"
    t.text     "description"
    t.string   "title"
    t.string   "author"
    t.text     "categories"
    t.text     "images"
    t.text     "products"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "look_id"
    t.datetime "processed_at"
  end

  create_table "product_images", :force => true do |t|
    t.text     "url"
    t.integer  "product_version_id"
    t.string   "size"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "product_images", ["product_version_id"], :name => "index_product_images_on_product_version_id"

  create_table "product_masters", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_reviews", :force => true do |t|
    t.integer  "product_id"
    t.integer  "rating"
    t.string   "author"
    t.text     "content"
    t.date     "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "product_reviews", ["product_id", "author"], :name => "index_product_reviews_on_product_id_and_author"

  create_table "product_versions", :force => true do |t|
    t.integer  "product_id"
    t.float    "price"
    t.float    "price_shipping"
    t.float    "price_strikeout"
    t.string   "shipping_info"
    t.text     "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "option2"
    t.text     "option1"
    t.string   "name"
    t.boolean  "available"
    t.text     "image_url"
    t.string   "brand"
    t.string   "reference"
    t.text     "images"
    t.string   "availability_info"
    t.text     "option3"
    t.text     "option4"
    t.string   "option1_md5"
    t.string   "option2_md5"
    t.string   "option3_md5"
    t.string   "option4_md5"
    t.float    "rating"
    t.text     "json_description"
  end

  add_index "product_versions", ["product_id", "available"], :name => "index_product_versions_on_product_id_and_available"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "merchant_id"
    t.text     "url"
    t.text     "image_url"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "description"
    t.integer  "product_master_id"
    t.string   "brand"
    t.datetime "versions_expires_at"
    t.boolean  "viking_failure"
    t.string   "reference"
    t.datetime "muted_until"
    t.boolean  "options_completed",   :default => false
    t.datetime "viking_sent_at"
    t.string   "image_size"
    t.float    "rating"
    t.text     "json_description"
  end

  add_index "products", ["url"], :name => "index_products_on_url", :unique => true

  create_table "scan_logs", :force => true do |t|
    t.string   "ean"
    t.integer  "device_id"
    t.integer  "prices_count"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
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

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "traces", :force => true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.string   "resource"
    t.string   "action"
    t.integer  "extra_id"
    t.string   "extra_text"
    t.string   "ip_address"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "traces", ["device_id"], :name => "index_traces_on_device_id"

  create_table "user_sessions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "virtual_cards", :force => true do |t|
    t.string   "provider"
    t.string   "number"
    t.string   "exp_month"
    t.string   "exp_year"
    t.string   "cvv"
    t.float    "amount"
    t.string   "cvd_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
