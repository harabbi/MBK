CREATE DATABASE IF NOT EXISTS `volusion`;
CREATE TABLE if not exists `volusion`.`Products_Joined`(
`productcode`			text,
`productprice`		double,
`listprice`			double,
`categoryid`			bigint,
`categoryids`			text,
`productname`			text,
`saleprice`			double,
`productweight`		double,
`productmanufacturer`	text,
`taxableproduct`		text,
`productdescription`	text,
`productdescriptionshort`	text,
`productfeatures`		text,
`stockstatus`			int,
`metatag_title`		text,
`metatag_description`	text,
`hideproduct`         text,
`stocklowqtyalarm`    bigint,
`maxqty`              bigint,
`howtogetsaleprice`   text,
`discountedprice_level1` double,
`discountedprice_level3` double,
`yahoo_category`         text,
`displaybegindate`     datetime,
`mbk_import_update`     tinyint(1) DEFAULT '0',
`mbk_import_new`        tinyint(1) DEFAULT '0',
`mbk_ready_to_import`   tinyint(1) DEFAULT '0',
`mbk_updated_at`        timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
`mbk_created_at`        datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;