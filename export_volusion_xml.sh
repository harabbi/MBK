#!/bin/sh

#check for the output database name parameter
if [ $# -ne 2 ]
then
  echo "Usage: `$0` {output_database_name}"
  exit
fi

rm -rf volusion_exported_xml
rm filesToDownload
java -jar selenium-server-standalone-2.21.0.jar [-timeout 3600] &
sleep 5
ruby scripts/getFilenames.rb
ruby scripts/fetchFiles.rb
ruby scripts/volusionxml2mysql.rb $1

