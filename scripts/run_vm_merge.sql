create database if not exists `vm_merged`;
create table if not exists `vm_merged`.`vm_merged_products` (
`v_productprice`		double,
`v_listprice`			double,
`v_categoryids`			bigint,
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
`m_price`				double,
`m_mbk_retail_price`	double,
`m_category_ids`		text,
`m_sku`					text,
`m_mbk_product_code`	text,
`m_name`            	text,
`m_special_price`       double,
`m_weight`         		double,
`m_manufacturer`  	 	text,
`m_tax_class_id`     	bigint,
`m_description`	        text,
`m_short_description`	text,
`m_mbk_features_area`	text,
`m_qty`	                bigint,
`m_meta_title`	        text,
`m_meta_description`	text,
`mbk_import_update`     tinyint(1) DEFAULT '0',
`mbk_import_new`        tinyint(1) DEFAULT '0',
`mbk_ready_to_import`   tinyint(1) DEFAULT '0',
`mbk_updated_at`        timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
`mbk_created_at`        datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

truncate table `vm_merged`.`vm_merged_products`;
insert into `vm_merged`.`vm_merged_products` (select 
productprice            as `v_productprice`,
listprice               as `v_listprice`,
categoryids             as `v_categoryids`,
productcode             as `v_productcode`,
productname             as `v_productname`,
saleprice               as `v_salesprice`,
productweight           as `v_productweight`,
productmanufacturer     as `v_productmanufacturer`,
taxableproduct          as `v_taxableproduct`,
productdescription      as `v_productdescription`,
productdescriptionshort as `v_productdescriptionshort`,
productfeatures         as `v_productfeatures`,
stockstatus             as `v_stockstatus`,
metatag_title           as `v_metatag_title`,
metatag_description     as `v_metatag_description`,
productprice            as `m_price`,
listprice               as `m_mbk_retail_price`,
categoryids             as `m_category_ids`,
productcode             as `m_sku`,
productcode             as `m_mbk_product_code`,
productname             as `m_name`,
saleprice               as `m_special_price`,
productweight           as `m_weight`,
productmanufacturer     as `m_manufacturer`,
taxableproduct          as `m_tax_class_id`,
productdescription      as `productdescription m_description`,
productdescriptionshort as `m_short_description`,
productfeatures         as `m_mbk_features_area`,
stockstatus             as `m_qty`,
metatag_title           as `m_meta_title`,
metatag_description     as `m_meta_description`,
0,
0,
0,
now(),
now()
from Products_Joined );

delete from `vm_merged`.`vm_merged_products` where `v_stockstatus` < 1;
delete from `vm_merged`.`vm_merged_products` where `v_categoryids` = 0;
update `vm_merged`.`vm_merged_products`,`mbk`.`category_map` set `vm_merged_products`.m_category_ids = (select `category_map`.`m_name` from `mbk`.`category_map` where `category_map`.`v_id`=`vm_merged_products`.`v_categoryids`);


create database if not exists `magento`;
create table if not exists `magento`.`m_products` (select * from `mbk`.`m_products_template`)
truncate table `magento`.`m_products`;
	insert into `magento`.`m_products` (select `m_mbk_product_code`,
	"",
	"Default",
	"simple",
	`m_category_ids`,
	"base",
    replace(`m_name`,'"','\''),  
	replace(`m_description`,'"','\''), 
    CASE WHEN LENGTH(`m_short_description`) = 0 THEN "NONE" ELSE replace(`m_short_description`,'"','\'') END, 
	round(`m_price`,2),
	"",
	"",
	"",
	"0",
	`m_weight`,
	`m_manufacturer`,	
	replace(`m_meta_title`,'"','\''),  
	"",
    replace(`m_meta_description`,'"','\''),  
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	"",
	"",
	"",
	"",
	concat("/", `m_mbk_product_code`,".jpg"),
	"1",
	"2",
	"",
	"",
	"",
	"4",
	"",
	"",
	"",
	"",
	"",
	"Block after Info Column"
	"0",
	"0",
	"",
	"",
	"",
	"",
	"",
	"1",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
    CASE WHEN LENGTH(`m_mbk_features_area`) = 0 THEN "NONE" ELSE replace(`m_mbk_features_area`,'"','\'') END,
	"",
	round(`m_mbk_retail_price`,2),
	"",
	`m_sku`,
	"",
	round(`m_mbk_retail_price`,2),
	round(`m_special_price`,2),	
	`m_sku`,
	"",
	"",
	"",
	"",
	"",
	"",
	round(`m_special_price`,2),
	`m_qty`,
	"0",
	"1",
	"0",
	"0",
	"1",
	"1",
	"1",
	"0",
	"1",
	"1",
	"",	
	"1",
	"0",
	"1",
	"1",
	"0",
	"1",
	"0",
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",		
	"",
	0,
	0,
	0,
	now(),
	now()
	from `vm_merged`.`vm_merged_products`);

SELECT 
sku,
_store,
_attribute_set,
_type,
_category,
_product_websites,
name,
description,
short_description,
price,
special_price,
special_from_date,
special_to_date,
cost,
weight,
manufacturer,
meta_title,
meta_keyword,
meta_description,
image,
small_image,
thumbnail,
media_gallery,
color,
news_from_date,
news_to_date,
gallery,
status,
tax_class_id,
url_key,
url_path,
minimal_price,
visibility,
custom_design,
custom_design_from,
custom_design_to,
custom_layout_update,
page_layout,
required_options,
has_options,
image_label,
small_image_label,
thumbnail_label,
created_at,
updated_at,
enable_googlecheckout,
gift_message_available,
gift_wrapping_available,
gift_wrapping_price,
related_targetrule_position_limit,
related_targetrule_position_behavior,
upsell_targetrule_position_limit,
upsell_targetrule_position_behavior,
is_imported,
features,
specifications,
retail_price,
product_video,
product_code,
newest,
mbk_retail_price,
mbk_map_price,
mbk_product_code,
mbk_video,
mbk_locomotive_type,
mbk_dcc_and_sound,
mbk_pre_weathered,
mbk_roadname,
mbk_features_area,
map_price,
qty,
min_qty,
use_config_min_qty,
is_qty_decimal,
backorders,
use_config_backorders,
min_sale_qty,
use_config_min_sale_qty,
max_sale_qty,
use_config_max_sale_qty,
is_in_stock,
notify_stock_qty,
use_config_notify_stock_qty,
manage_stock,
use_config_manage_stock,
use_config_qty_increments,
qty_increments,
use_config_enable_qty_increments,
enable_qty_increments
FROM `magento`.`m_products`  INTO OUTFILE '/tmp/products.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n';
	
	