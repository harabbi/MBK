#!/bin/sh

java -jar selenium-server-standalone-2.21.0.jar [-timeout 3600] &
sleep 5
ruby scripts/getFilenames.rb
ruby scripts/fetchFiles.rb
ruby scripts/volusionxml2mysql.rb mbk_volusion_export

