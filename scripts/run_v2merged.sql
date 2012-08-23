truncate table `vm_merged_products`;
insert into `vm_merged_products` (select 
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

delete from `vm_merged_products` where `v_stockstatus` < 1;
delete from `vm_merged_products` where `v_categoryids` = 0;
update `vm_merged_products`,`mbk`.`category_map` set `vm_merged_products`.m_category_ids = (select `category_map`.`m_name` from `mbk`.`category_map` where `category_map`.`v_id`=`vm_merged_products`.`v_categoryids`);

