truncate table `vm_merged_products`;
insert into `vm_merged_products` (select 
round(productprice,2)   as `v_productprice`,
round(listprice,2)      as `v_listprice`,
categoryids             as `v_categoryid`,
categoryids             as `v_categoryids`,
productcode             as `v_productcode`,
productname             as `v_productname`,
round(saleprice,2)      as `v_salesprice`,
productweight           as `v_productweight`,
productmanufacturer     as `v_productmanufacturer`,
taxableproduct          as `v_taxableproduct`,
productdescription      as `v_productdescription`,
productdescriptionshort as `v_productdescriptionshort`,
productfeatures         as `v_productfeatures`,
stockstatus             as `v_stockstatus`,
metatag_title           as `v_metatag_title`,
metatag_description     as `v_metatag_description`,
hideproduct             as `v_hideproduct`,
stocklowqtyalarm        as `v_stocklowqtyalarm`,
maxqty                  as `v_maxqty`,
howtogetsaleprice       as `v_howtogetsaleprice`,
round(discountedprice_level1,2)  as `v_discountedprice_level1`,
round(discountedprice_level3,2)  as `v_discountedprice_level3`,
yahoo_category          as `v_yahoo_category`,
displaybegindate        as `v_displaybegindate`,
round(productprice,2)   as `m_price`,
round(listprice ,2)     as `m_mbk_retail_price`,
categoryids             as `m_category_ids`,
productcode             as `m_sku`,
productcode             as `m_mbk_product_code`,
productname             as `m_name`,
round(saleprice,2)      as `m_special_price`,
productweight           as `m_weight`,
productmanufacturer     as `m_manufacturer`,
taxableproduct          as `m_tax_class_id`,
productdescription      as `m_description`,
productdescriptionshort as `m_short_description`,
productfeatures         as `m_mbk_features_area`,
stockstatus             as `m_qty`,
metatag_title           as `m_meta_title`,
metatag_description     as `m_meta_description`,
IF(hideproduct='Y',"1","0")  `m_status`,
stocklowqtyalarm        as `m_notify_stock_qty`,
maxqty                  as `m_max_sale_qty`,
IF(howtogetsaleprice='addtocart',round(saleprice,2),NULL) as `m_mbk_map_price`,
round(discountedprice_level3,2)  as `m__tier_price_price`,
0,
0,
0,
now(),
now()
from Products_Joined );

delete from `vm_merged_products` where `v_stockstatus` < 1;
delete from `vm_merged_products` where `v_categoryid` = 0;
update `vm_merged_products`,`mbk`.`category_map` set `vm_merged_products`.m_category_ids = (select `category_map`.`m_name` from `mbk`.`category_map` where `category_map`.`v_id`=`vm_merged_products`.`v_categoryid`);
update vm_merged_products set v_productname = replace(v_productname,'\\','');
update vm_merged_products set v_productdescription = replace(v_productdescription,'\\','');
update vm_merged_products set v_productdescriptionshort = replace(v_productdescriptionshort,'\\','');
update vm_merged_products set v_productfeatures = replace(v_productfeatures,'\\','');
update vm_merged_products set v_metatag_title = replace(v_metatag_title,'\\','');
update vm_merged_products set v_metatag_description = replace(v_metatag_description,'\\','');

update vm_merged_products set m_name = replace(m_name,'\\','');
update vm_merged_products set m_description = replace(m_description,'\\','');
update vm_merged_products set m_short_description = replace(m_short_description,'\\','');
update vm_merged_products set m_mbk_features_area = replace(m_mbk_features_area,'\\','');
update vm_merged_products set m_meta_title = replace(m_meta_title,'\\','');
update vm_merged_products set m_meta_description = replace(m_meta_description,'\\','');


