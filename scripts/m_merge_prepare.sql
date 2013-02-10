update `vm_merged`.`vm_merged_products` set `m_price` = `v_productprice`;
update `vm_merged`.`vm_merged_products` set `m_mbk_retail_price` = `v_listprice`;
update `vm_merged`.`vm_merged_products` set `m_category_ids` = `v_categoryids`;
update `vm_merged`.`vm_merged_products` set `m_sku` = `v_productcode`;
update `vm_merged`.`vm_merged_products` set `m_mbk_product_code` = `v_productcode`;
update `vm_merged`.`vm_merged_products` set `m_name` = `v_productname`;
update `vm_merged`.`vm_merged_products` set `m_weight` = `v_productweight`;
update `vm_merged`.`vm_merged_products` set `m_cost` = `v_vendor_price`;
update `vm_merged`.`vm_merged_products` set `m_special_price` = `v_saleprice`;
update `vm_merged`.`vm_merged_products` set `m_manufacturer` = `v_productmanufacturer`;
update `vm_merged`.`vm_merged_products` set `m_tax_class_id` = `v_taxableproduct`;
update `vm_merged`.`vm_merged_products` set `m_description` = `v_productdescription`;
update `vm_merged`.`vm_merged_products` set `m_short_description` = `v_productdescriptionshort`;
update `vm_merged`.`vm_merged_products` set `m_mbk_features_area` = `v_productfeatures`;
update `vm_merged`.`vm_merged_products` set `m_qty` = `v_stockstatus`;
update `vm_merged`.`vm_merged_products` set `m_meta_title` = `v_metatag_title`;
update `vm_merged`.`vm_merged_products` set `m_meta_description` = `v_metatag_description`;
update `vm_merged`.`vm_merged_products` set `m_notify_stock_qty` = `v_stocklowqtyalarm`;
update `vm_merged`.`vm_merged_products` set `m_max_sale_qty` = `v_maxqty`;
update `vm_merged`.`vm_merged_products` set `m__tier_price_price` = `v_discountedprice_level3`;
update `vm_merged`.`vm_merged_products` set `m_mbk_map_price` = IF(`v_howtogetsaleprice`='addtocart',`v_saleprice`, NULL);
update `vm_merged`.`vm_merged_products` set `m_status` =  IF(`v_hideproduct`='Y',"1","0");
