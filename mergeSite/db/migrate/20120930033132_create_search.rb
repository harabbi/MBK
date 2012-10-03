class CreateSearch < ActiveRecord::Migration
  def change
    create_table :product_searches do |t|
      t.integer :id
      t.text :search_name
      t.float :productprice_min
      t.float :listprice_min
      t.integer :stockstatus_min
      t.integer :stocklowqtyalarm_min
      t.integer :maxqty_min
      t.float :saleprice_min
      t.float :productweight_min
      t.float :productprice_max
      t.float :listprice_max
      t.integer :stockstatus_max
      t.integer :stocklowqtyalarm_max
      t.integer :maxqty_max
      t.float :saleprice_max
      t.float :productweight_max
      t.text :productcode
      t.text :productname
      t.integer :categoryids
      t.text :productmanufacturer
      t.text :productdescription
      t.text :productdescriptionshort
      t.text :productfeatures
      t.text :metatag_title
      t.text :metatag_description
      t.boolean :hideproduct
      t.timestamps
    end

    create_table :customer_searches do |t|
      t.integer :id
      t.text :search_name
      t.text :firstname
      t.text :lastname
      t.text :billingaddress1
      t.text :billingaddress2
      t.text :city
      t.text :state
      t.text :postalcode
      t.text :country
      t.text :phonenumber
      t.text :faxnumber
      t.text :emailaddress
    end
  end
end
