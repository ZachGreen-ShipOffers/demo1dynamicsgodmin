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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160217224035) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "client_channel_sku_maps", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_channel_id", null: false
    t.uuid     "client_sku_id",     null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "client_channel_sku_maps", ["client_channel_id", "client_sku_id"], name: "client_channel_sku_maps_unq", unique: true, using: :btree
  add_index "client_channel_sku_maps", ["client_channel_id"], name: "index_client_channel_sku_maps_on_client_channel_id", using: :btree
  add_index "client_channel_sku_maps", ["client_sku_id"], name: "index_client_channel_sku_maps_on_client_sku_id", using: :btree

  create_table "client_channel_types", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.boolean  "uploadable",             default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "client_channels", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "ship_station_store_id"
    t.uuid     "client_channel_type_id",             null: false
    t.string   "name",                   limit: 255, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.uuid     "client_company_id",                  null: false
  end

  add_index "client_channels", ["client_channel_type_id"], name: "index_client_channels_on_client_channel_type_id", using: :btree
  add_index "client_channels", ["ship_station_store_id"], name: "index_client_channels_on_ship_station_store_id", using: :btree

  create_table "client_companies", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "dyna_code"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "run_export"
    t.uuid     "api_password", default: "uuid_generate_v4()"
    t.uuid     "api_secret",   default: "uuid_generate_v4()"
  end

  add_index "client_companies", ["dyna_code"], name: "index_client_companies_on_dyna_code", unique: true, using: :btree
  add_index "client_companies", ["id"], name: "index_client_companies_on_uuid", unique: true, using: :btree

  create_table "client_order_files", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_channel_id",                               null: false
    t.date     "received_on"
    t.string   "status",                   default: "unimported", null: false
    t.string   "client_order_file_status", default: "unimported", null: false
    t.string   "raw_file_file_name"
    t.string   "raw_file_content_type"
    t.integer  "raw_file_file_size"
    t.datetime "raw_file_updated_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "client_order_files", ["client_channel_id"], name: "index_client_order_files_on_client_channel_id", using: :btree

  create_table "client_order_items", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_order_id",                         null: false
    t.uuid     "client_sku_id"
    t.string   "sku",             limit: 64,              null: false
    t.string   "description",     limit: 255
    t.integer  "quantity",                    default: 1, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "client_order_items", ["client_order_id"], name: "index_client_order_items_on_client_order_id", using: :btree
  add_index "client_order_items", ["client_sku_id"], name: "index_client_order_items_on_client_sku_id", using: :btree

  create_table "client_order_shipments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_order_id",    null: false
    t.uuid     "client_shipment_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "client_order_shipments", ["client_order_id", "client_shipment_id"], name: "client_order_shipments_unq", unique: true, using: :btree
  add_index "client_order_shipments", ["client_order_id"], name: "index_client_order_shipments_on_client_order_id", using: :btree
  add_index "client_order_shipments", ["client_shipment_id"], name: "index_client_order_shipments_on_client_shipment_id", using: :btree

# Could not dump table "client_orders" because of following StandardError
#   Unknown type 'client_order_status' for column 'status'

  create_table "client_product_sku_maps", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_product_id",             null: false
    t.uuid     "client_sku_id",                 null: false
    t.integer  "quantity",          default: 1, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "client_product_sku_maps", ["client_product_id", "client_sku_id"], name: "client_product_sku_map_unq01", unique: true, using: :btree

  create_table "client_products", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_company_id",                                                          null: false
    t.uuid     "ship_offers_product_id",                                                     null: false
    t.string   "sku",                    limit: 32,                                          null: false
    t.string   "name",                   limit: 255,                                         null: false
    t.string   "description",                                                                null: false
    t.decimal  "weight",                             precision: 15, scale: 2, default: 1.0,  null: false
    t.boolean  "active",                                                      default: true, null: false
    t.boolean  "shippable",                                                   default: true, null: false
    t.string   "label_file_name"
    t.string   "label_content_type"
    t.integer  "label_file_size"
    t.datetime "label_updated_at"
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
  end

  add_index "client_products", ["client_company_id", "sku"], name: "client_product_sku_unq", unique: true, using: :btree
  add_index "client_products", ["client_company_id"], name: "index_client_products_on_client_company_id", using: :btree
  add_index "client_products", ["ship_offers_product_id"], name: "index_client_products_on_ship_offers_product_id", using: :btree

  create_table "client_shipment_items", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "client_shipment_id",             null: false
    t.uuid     "client_product_id",              null: false
    t.integer  "quantity",           default: 1, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "client_shipment_items", ["client_product_id"], name: "index_client_shipment_items_on_client_product_id", using: :btree
  add_index "client_shipment_items", ["client_shipment_id", "client_product_id"], name: "client_shipment_items_unq", unique: true, using: :btree
  add_index "client_shipment_items", ["client_shipment_id"], name: "index_client_shipment_items_on_client_shipment_id", using: :btree

  create_table "client_shipment_returns", force: :cascade do |t|
    t.date     "returned_on",                           null: false
    t.string   "order_numbers"
    t.string   "rma_numbers"
    t.string   "customer"
    t.integer  "ship_station_store_id"
    t.integer  "ship_station_order_id"
    t.integer  "processed_by"
    t.string   "reason"
    t.boolean  "medical",               default: false
    t.text     "comments"
    t.string   "sku_01"
    t.string   "sku_02"
    t.string   "sku_03"
    t.string   "sku_04"
    t.string   "sku_05"
    t.string   "sku_06"
    t.string   "sku_07"
    t.string   "sku_08"
    t.string   "sku_09"
    t.string   "sku_10"
    t.integer  "returned_01",           default: 0
    t.integer  "returned_02",           default: 0
    t.integer  "returned_03",           default: 0
    t.integer  "returned_04",           default: 0
    t.integer  "returned_05",           default: 0
    t.integer  "returned_06",           default: 0
    t.integer  "returned_07",           default: 0
    t.integer  "returned_08",           default: 0
    t.integer  "returned_09",           default: 0
    t.integer  "returned_10",           default: 0
    t.integer  "restock_01",            default: 0
    t.integer  "restock_02",            default: 0
    t.integer  "restock_03",            default: 0
    t.integer  "restock_04",            default: 0
    t.integer  "restock_05",            default: 0
    t.integer  "restock_06",            default: 0
    t.integer  "restock_07",            default: 0
    t.integer  "restock_08",            default: 0
    t.integer  "restock_09",            default: 0
    t.integer  "restock_10",            default: 0
    t.integer  "damagaed_01",           default: 0
    t.integer  "damagaed_02",           default: 0
    t.integer  "damagaed_03",           default: 0
    t.integer  "damagaed_04",           default: 0
    t.integer  "damagaed_05",           default: 0
    t.integer  "damagaed_06",           default: 0
    t.integer  "damagaed_07",           default: 0
    t.integer  "damagaed_08",           default: 0
    t.integer  "damagaed_09",           default: 0
    t.integer  "damagaed_10",           default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "client_shipment_returns", ["ship_station_order_id", "ship_station_store_id"], name: "ak_returns_01", using: :btree

# Could not dump table "client_shipments" because of following StandardError
#   Unknown type 'client_shipment_status' for column 'status'

  create_table "client_skus", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "sku",         limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "clients_users", force: :cascade do |t|
    t.integer "user_id"
    t.uuid    "client_company_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string  "name"
    t.string  "code"
    t.boolean "default"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dynamics_infos", force: :cascade do |t|
    t.uuid    "client_company_id"
    t.integer "ship_count"
    t.date    "date"
    t.string  "export_file"
  end

  create_table "generic_skus", force: :cascade do |t|
    t.string  "map_name",   limit: 50
    t.string  "sku",        limit: 50
    t.string  "client_sku", limit: 50
    t.integer "quantity"
  end

  create_table "notification_recipients", force: :cascade do |t|
    t.integer  "client_company_id",                 null: false
    t.string   "name",                  limit: 255, null: false
    t.boolean  "wants_tracking"
    t.boolean  "wants_returns"
    t.string   "email_address"
    t.string   "ftp_server"
    t.string   "ftp_username"
    t.string   "ftp_password"
    t.string   "ftp_directory"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "ship_station_store_id"
  end

  add_index "notification_recipients", ["client_company_id"], name: "index_notification_recipients_on_client_company_id", using: :btree

  create_table "return_reason_codes", force: :cascade do |t|
    t.string   "code",       limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "return_skus", force: :cascade do |t|
    t.string   "code",       limit: 255, null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ship_offers_product_categories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ship_offers_products", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "sku",                         limit: 40,                                                           null: false
    t.string   "sku_kind",                    limit: 255,                          default: "ShipOffers::Product", null: false
    t.string   "name",                        limit: 255,                                                          null: false
    t.string   "description",                 limit: 255
    t.boolean  "active",                                                           default: true,                  null: false
    t.datetime "created_at",                                                                                       null: false
    t.datetime "updated_at",                                                                                       null: false
    t.uuid     "category_id"
    t.string   "count_description",           limit: 255
    t.decimal  "weight",                                  precision: 15, scale: 2, default: 0.0
    t.decimal  "tier01",                                  precision: 15, scale: 2, default: 0.0
    t.decimal  "tier02",                                  precision: 15, scale: 2, default: 0.0
    t.decimal  "tier03",                                  precision: 15, scale: 2, default: 0.0
    t.decimal  "tier04",                                  precision: 15, scale: 2, default: 0.0
    t.decimal  "tier05",                                  precision: 15, scale: 2, default: 0.0
    t.boolean  "wholesale_only",                                                   default: false,                 null: false
    t.uuid     "restrict",                                                         default: [],                    null: false, array: true
    t.string   "product_image_file_name"
    t.string   "product_image_content_type"
    t.integer  "product_image_file_size"
    t.datetime "product_image_updated_at"
    t.string   "label_template_file_name"
    t.string   "label_template_content_type"
    t.integer  "label_template_file_size"
    t.datetime "label_template_updated_at"
  end

  add_index "ship_offers_products", ["category_id"], name: "index_ship_offers_products_on_category_id", using: :btree
  add_index "ship_offers_products", ["sku"], name: "sho_product_sku_unq", unique: true, using: :btree

  create_table "ship_offers_ship_types", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "sku",           limit: 40,                                   null: false
    t.string   "sku_kind",      limit: 255, default: "ShipOffers::ShipType", null: false
    t.string   "name",          limit: 255,                                  null: false
    t.string   "description",   limit: 255
    t.boolean  "active",                    default: true,                   null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "min_qty",                   default: 1,                      null: false
    t.integer  "max_qty",                   default: 9999,                   null: false
    t.boolean  "international",             default: false,                  null: false
    t.boolean  "express",                   default: false,                  null: false
  end

  add_index "ship_offers_ship_types", ["sku"], name: "sho_shiptype_sku_unq", unique: true, using: :btree

  create_table "ship_offers_skus", id: false, force: :cascade do |t|
    t.uuid     "id",                      default: "uuid_generate_v4()"
    t.string   "sku",         limit: 40,                                 null: false
    t.string   "sku_kind",    limit: 255,                                null: false
    t.string   "name",        limit: 255,                                null: false
    t.string   "description", limit: 255
    t.boolean  "active",                  default: true,                 null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "ship_station_orders", force: :cascade do |t|
    t.integer  "ship_station_store_id"
    t.string   "order_number",          limit: 255,                 null: false
    t.string   "order_key",             limit: 255
    t.date     "order_date"
    t.string   "order_status",          limit: 255
    t.string   "email",                 limit: 255
    t.string   "carrier_code",          limit: 255
    t.string   "service_code",          limit: 255
    t.string   "package_code",          limit: 255
    t.string   "name",                  limit: 255
    t.string   "company",               limit: 255
    t.string   "street1",               limit: 255
    t.string   "street2",               limit: 255
    t.string   "street3",               limit: 255
    t.string   "city",                  limit: 255
    t.string   "state",                 limit: 255
    t.string   "postal_code",           limit: 255
    t.string   "country",               limit: 2
    t.string   "phone",                 limit: 255
    t.boolean  "residential",                       default: false
    t.string   "address_verified",      limit: 255
    t.hstore   "items",                                                          array: true
    t.date     "ship_date"
    t.text     "customer_notes"
    t.text     "internal_notes"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
    t.integer  "parent_id"
    t.string   "merged_or_split"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "ship_station_orders", ["id", "ship_station_store_id", "order_number", "ship_date"], name: "ak_shipstationorders_01", unique: true, using: :btree
  add_index "ship_station_orders", ["ship_station_store_id", "order_number", "ship_date", "name", "street1", "city", "state", "postal_code", "country"], name: "ak_shipstationorders_02", using: :btree

  create_table "ship_station_shipment_items", force: :cascade do |t|
    t.integer  "ship_station_shipment_id"
    t.integer  "ship_station_order_id"
    t.string   "sku",                      limit: 255
    t.string   "name",                     limit: 255
    t.integer  "quantity",                             default: 0, null: false
    t.integer  "product_id",                           default: 0
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "ship_station_shipment_items", ["ship_station_order_id"], name: "index_ship_station_shipment_items_on_ship_station_order_id", using: :btree
  add_index "ship_station_shipment_items", ["ship_station_shipment_id"], name: "index_ship_station_shipment_items_on_ship_station_shipment_id", using: :btree

  create_table "ship_station_shipments", force: :cascade do |t|
    t.integer  "ship_station_order_id"
    t.integer  "ship_station_store_id"
    t.string   "order_number",          limit: 255
    t.string   "tracking_number",       limit: 255
    t.string   "batch_number",          limit: 255
    t.string   "carrier_code",          limit: 255
    t.string   "service_code",          limit: 255
    t.string   "package_code",          limit: 255
    t.string   "confirmation",          limit: 255
    t.boolean  "return_label",                                               default: false
    t.boolean  "voided",                                                     default: false
    t.date     "void_date"
    t.string   "name",                  limit: 255
    t.string   "company",               limit: 255
    t.string   "street1",               limit: 255
    t.string   "street2",               limit: 255
    t.string   "street3",               limit: 255
    t.string   "city",                  limit: 255
    t.string   "state",                 limit: 255
    t.string   "postal_code",           limit: 255
    t.string   "country",               limit: 2
    t.string   "phone",                 limit: 255
    t.string   "email",                 limit: 255
    t.hstore   "items",                                                                                   array: true
    t.date     "ship_date"
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.decimal  "shipment_cost",                     precision: 12, scale: 2, default: 0.0
    t.decimal  "insurance_cost",                    precision: 12, scale: 2, default: 0.0
  end

  add_index "ship_station_shipments", ["ship_station_order_id", "order_number", "ship_date", "tracking_number"], name: "ak_shipstationshipments_01", unique: true, using: :btree

  create_table "ship_station_stores", force: :cascade do |t|
    t.string   "store_name"
    t.string   "company_name"
    t.integer  "marketplace_id"
    t.string   "marketplace_name"
    t.boolean  "active"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.uuid     "client_company_id"
  end

  create_table "shipment_stats", force: :cascade do |t|
    t.string   "dyna_code"
    t.integer  "shipment_count"
    t.date     "ship_date"
    t.integer  "client_company_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "us_zipcodes", id: false, force: :cascade do |t|
    t.string "zipcode",      limit: 5
    t.string "state",        limit: 2
    t.string "fips_regions", limit: 2
    t.string "city",         limit: 64
    t.float  "latitude"
    t.float  "longitude"
  end

  create_table "users", force: :cascade do |t|
    t.boolean  "admin",                              default: false, null: false
    t.string   "name",                   limit: 255,                 null: false
    t.string   "email",                              default: "",    null: false
    t.string   "encrypted_password",                 default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "client_channel_sku_maps", "client_channels"
  add_foreign_key "client_channel_sku_maps", "client_skus"
  add_foreign_key "client_channels", "client_channel_types"
  add_foreign_key "client_order_items", "client_orders"
  add_foreign_key "client_order_items", "client_skus"
  add_foreign_key "client_order_shipments", "client_orders"
  add_foreign_key "client_order_shipments", "client_shipments"
  add_foreign_key "client_products", "client_companies"
  add_foreign_key "client_products", "ship_offers_products"
  add_foreign_key "client_shipment_items", "client_products"
  add_foreign_key "client_shipment_items", "client_shipments"
  add_foreign_key "dynamics_infos", "client_companies"
end
