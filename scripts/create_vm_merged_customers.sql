create database if not exists vm_merged;
create table if not exists vm_merged_customers (
`v_password`            text, 
`v_firstname`           text,
`v_lastname`            text,
`v_companyname`         text,
`v_billingaddress1`     text,
`v_billingaddress2`     text,
`v_city`                text,
`v_state`               text,
`v_postalcode`          text,
`v_country`             text,
`v_phonenumber`         text,
`v_faxnumber`           text,
`v_emailaddress`        text,
`m_email`               text,
`m_firstname`           text,
`m_lastname`            text,
`m_password_hash`       text,
`m__address_city`       text,
`m__address_company`    text,
`m__address_country_id` text,
`m__address_fax`        text,
`m__address_firstname`  text,
`m__address_lastname`   text,
`m__address_postcode`   text,
`m__address_region`     text,
`m__address_street`     text,
`m__address_suffix`     text,
`m__address_telephone`  text,
`mbk_import_update`     tinyint(1) DEFAULT '0',
`mbk_import_new`        tinyint(1) DEFAULT '0',
`mbk_ready_to_import`   tinyint(1) DEFAULT '0',
`mbk_updated_at`        timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
`mbk_created_at`        datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
