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

ActiveRecord::Schema.define(:version => 20130317070025) do

  create_table "attribute_sets", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customer_searches", :force => true do |t|
    t.text "search_name"
    t.text "firstname"
    t.text "lastname"
    t.text "billingaddress1"
    t.text "billingaddress2"
    t.text "city"
    t.text "state"
    t.text "postalcode"
    t.text "country"
    t.text "phonenumber"
    t.text "faxnumber"
    t.text "emailaddress"
  end

  create_table "mbk_attributes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_attributes", :force => true do |t|
    t.string   "v_productcode"
    t.string   "mbk_attribute_name"
    t.string   "mbk_attribute_value"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "product_searches", :force => true do |t|
    t.text     "search_name"
    t.text     "productcode"
    t.text     "productname"
    t.integer  "categoryids"
    t.text     "productmanufacturer"
    t.text     "yahoo_category"
    t.float    "productprice_max"
    t.float    "productprice_min"
    t.float    "listprice_max"
    t.float    "listprice_min"
    t.integer  "stockstatus_max"
    t.integer  "stockstatus_min"
    t.integer  "stocklowqtyalarm_max"
    t.integer  "stocklowqtyalarm_min"
    t.float    "saleprice_max"
    t.float    "saleprice_min"
    t.boolean  "hideproduct"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.datetime "displaybegindate_min"
    t.datetime "displaybegindate_max"
  end

  create_table "vm_merged_customers", :id => false, :force => true do |t|
    t.string "name"
  end

  create_table "vm_merged_products", :id => false, :force => true do |t|
    t.float     "v_productprice"
    t.float     "v_listprice"
    t.integer   "v_categoryid",              :limit => 8
    t.text      "v_categoryids"
    t.string    "v_productcode"
    t.text      "v_productname"
    t.float     "v_saleprice"
    t.float     "v_productweight"
    t.text      "v_productmanufacturer"
    t.text      "v_taxableproduct"
    t.text      "v_productdescription"
    t.text      "v_productdescriptionshort"
    t.text      "v_productfeatures"
    t.integer   "v_stockstatus"
    t.text      "v_metatag_title"
    t.text      "v_metatag_description"
    t.text      "v_hideproduct"
    t.integer   "v_stocklowqtyalarm",        :limit => 8
    t.integer   "v_maxqty",                  :limit => 8
    t.text      "v_howtogetsaleprice"
    t.float     "v_discountedprice_level1"
    t.float     "v_discountedprice_level3"
    t.text      "v_yahoo_category"
    t.datetime  "v_displaybegindate"
    t.float     "v_vendor_price"
    t.float     "m_price"
    t.float     "m_mbk_retail_price"
    t.text      "m_category_ids"
    t.text      "m_sku"
    t.text      "m_mbk_product_code"
    t.text      "m_name"
    t.float     "m_special_price"
    t.float     "m_weight"
    t.text      "m_manufacturer"
    t.integer   "m_tax_class_id",            :limit => 8
    t.text      "m_description"
    t.text      "m_short_description"
    t.text      "m_mbk_features_area"
    t.integer   "m_qty",                     :limit => 8
    t.text      "m_meta_title"
    t.text      "m_meta_description"
    t.integer   "m_status"
    t.integer   "m_notify_stock_qty",        :limit => 8
    t.integer   "m_max_sale_qty",            :limit => 8
    t.float     "m_mbk_map_price"
    t.float     "m__tier_price_price"
    t.float     "m_cost"
    t.boolean   "mbk_import_update",                      :default => false
    t.boolean   "mbk_import_new",                         :default => false
    t.boolean   "mbk_ready_to_import",                    :default => false
    t.timestamp "mbk_updated_at",                                            :null => false
    t.datetime  "mbk_created_at"
  end

  add_index "vm_merged_products", ["v_productcode"], :name => "v_productcode"

end
