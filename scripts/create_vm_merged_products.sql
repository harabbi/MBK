create database if not exists vm_merged;
create table if not exists vm_merged_products (
`v_productprice`		double,
`v_listprice`			double,
`v_categoryid`			bigint,
`v_categoryids`			text,
`v_productcode`			text,
`v_productname`			text,
`v_saleprice`			double,
`v_productweight`		double,
`v_productmanufacturer`	text,
`v_taxableproduct`		text,
`v_productdescription`	text,
`v_productdescriptionshort`	text,
`v_productfeatures`		text,
`v_stockstatus`			int,
`v_metatag_title`		text,
`v_metatag_description`	text,
`v_hideproduct`         text,
`v_stocklowqtyalarm`    bigint,
`v_maxqty`              bigint,
`v_howtogetsaleprice`   text,
`v_discountedprice_level1` double,
`v_discountedprice_level3` double,
`v_yahoo_category`         text,
`v_displaybegindate`     datetime,
`v_vendor_price`         double,
`m_price`		        double,
`m_mbk_retail_price`	double,
`m_category_ids`	    text,
`m_sku`			        text,
`m_mbk_product_code`	text,
`m_name`            	text,
`m_special_price`       double,
`m_weight`            	double,
`m_manufacturer`  	    text,
`m_tax_class_id`     	bigint,
`m_description`	        text,
`m_short_description`	text,
`m_mbk_features_area`	text,
`m_qty`	                bigint,
`m_meta_title`	        text,
`m_meta_description`	text,
`m_status`              int,
`m_notify_stock_qty`    bigint,
`m_max_sale_qty`        bigint,
`m_mbk_map_price`       double,
`m__tier_price_price`   double,
`m_cost`                double,
`mbk_import_update`     tinyint(1) DEFAULT '0',
`mbk_import_new`        tinyint(1) DEFAULT '0',
`mbk_ready_to_import`   tinyint(1) DEFAULT '0',
`mbk_updated_at`        timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
`mbk_created_at`        datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
