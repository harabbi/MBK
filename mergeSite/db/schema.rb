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

ActiveRecord::Schema.define(:version => 0) do

  create_table "vm_merged_customers", :id => false, :force => true do |t|
    t.text      "v_password"
    t.text      "v_firstname"
    t.text      "v_lastname"
    t.text      "v_companyname"
    t.text      "v_billingaddress1"
    t.text      "v_billingaddress2"
    t.text      "v_city"
    t.text      "v_state"
    t.text      "v_postalcode"
    t.text      "v_country"
    t.text      "v_phonenumber"
    t.text      "v_faxnumber"
    t.text      "v_emailaddress"
    t.text      "m_email"
    t.text      "m_firstname"
    t.text      "m_lastname"
    t.text      "m_password_hash"
    t.text      "m__address_city"
    t.text      "m__address_company"
    t.text      "m__address_country_id"
    t.text      "m__address_fax"
    t.text      "m__address_firstname"
    t.text      "m__address_lastname"
    t.text      "m__address_postcode"
    t.text      "m__address_region"
    t.text      "m__address_street"
    t.text      "m__address_suffix"
    t.text      "m__address_telephone"
    t.boolean   "mbk_import_update",     :default => false
    t.boolean   "mbk_import_new",        :default => false
    t.boolean   "mbk_ready_to_import",   :default => false
    t.timestamp "mbk_updated_at",                           :null => false
    t.datetime  "mbk_created_at"
  end

  create_table "vm_merged_products", :id => false, :force => true do |t|
    t.float     "v_productprice"
    t.float     "v_listprice"
    t.integer   "v_categoryids",             :limit => 8
    t.text      "v_productcode"
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
    t.text      "m_status"
    t.integer   "m_notify_stock_qty",        :limit => 8
    t.integer   "m_max_sale_qty",            :limit => 8
    t.boolean   "mbk_import_update",                      :default => false
    t.boolean   "mbk_import_new",                         :default => false
    t.boolean   "mbk_ready_to_import",                    :default => false
    t.timestamp "mbk_updated_at",                                            :null => false
    t.datetime  "mbk_created_at"
  end

end
