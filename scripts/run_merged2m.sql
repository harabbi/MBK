	insert into `magento`.`m_products` (select `m_mbk_product_code`,
	"",
	"Default",
	"simple",
	`m_category_ids`,
	"base",
    replace(`m_name`,'"','\''),  
    CASE WHEN LENGTH(`m_description`) = 0 THEN "NONE" ELSE replace(replace(`m_description`,'\\',''),'"','\'') END, 
    CASE WHEN LENGTH(`m_short_description`) = 0 THEN "NONE" ELSE replace(replace(`m_short_description`,'\\',''),'"','\'') END, 
	round(`m_price`,2),
	"",
	"",
	"",
	"0",
	`m_weight`,
	`m_manufacturer`,	
	replace(replace(`m_meta_title`,'\\',''),'"','\''),  
	"",
    replace(replace(`m_meta_description`,'\\',''),'"','\''),  
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	concat("/",substr(`m_mbk_product_code`,1,1),"/",substr(`m_mbk_product_code`,2,1),"/", `m_mbk_product_code`,".jpg"),
	"",
	"",
	"",
	"",
	concat("/", `m_mbk_product_code`,".jpg"),
	`m_status`,
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
    CASE WHEN LENGTH(`m_mbk_features_area`) = 0 THEN "NONE" ELSE replace(replace(replace(`m_mbk_features_area`,'\\',''),'"','\''),'"','\'') END,
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
	"0",
	"1",
	"0",
	"0",
	"1",
        "0",
	`m_max_sale_qty`,
	"0",
	"1",
	`m_notify_stock_qty`,
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
	"1",		
	"DEALER",		
	"1",		
	round(`m__tier_price_price`,2),	
	"",	
	`mbk_import_update`,
	`mbk_import_new`,
	0,
	now(),
	now()
	from `vm_merged`.`vm_merged_products` where `vm_merged_products`.`mbk_import_update`=1 or `vm_merged_products`.`mbk_import_new`=1);
	update `vm_merged`.`vm_merged_products` set `mbk_import_update`=0, `mbk_import_new`=0;