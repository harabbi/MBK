truncate table `magento`.`m_products`;
	insert into `magento`.`m_products` (select `m_mbk_product_code`,
	"",
	"Default",
	"simple",
	`m_category_ids`,
	"base",
    replace(`m_name`,'"','\''),  
    CASE WHEN LENGTH(`m_description`) = 0 THEN "NONE" ELSE replace(`m_description`,'"','\'') END, 
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
	`mbk_import_update`,
	`mbk_import_new`,
	0,
	now(),
	now()
	from `vm_merged`.`vm_merged_products` where `vm_merged_products`.`mbk_import_update`=1 or `vm_merged_products`.`mbk_import_new`=1);