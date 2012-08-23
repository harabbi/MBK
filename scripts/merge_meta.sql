create table if not exists merge_meta (
  `map_type`           text,
  `map_from_tbl`       text,
  `map_from_fld`       text,
  `map_to_tbl`         text,
  `map_to_fld`		   text,
  `map_function_to`    text,
  `map_function_from`  text,
  `is_quotable`        boolean DEFAULT TRUE,
  `is_primary`         boolean DEFAULT FALSE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
