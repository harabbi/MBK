#!/bin/sh

#check for the output database name parameter
if [ $# -ne 1 ]
then
  echo "Usage: `$0` {output_database_name}"
  exit
fi

rm -rf volusion_exported_xml
ruby scripts/download_xmls.rb
ruby scripts/passwords.rb
ruby scripts/volusionxml2mysql.rb $1

