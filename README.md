you will need the following gems installed
>gem install mechanize
>gem install selenium-client

1- Type this command
	cp wholeTableList.master tablesToDownload

2- Edit tableToDownload to include only the tables wanted

3- Start the selenium server with this command (run in background, modify timeout if needed)
	java -jar selenium-server-standalone-2.21.0.jar [-timeout 3600] &

4- Execute this script to populate the filename file:
	ruby scripts/getFilenames.rb

5- Execute this script to pull down the XMLs

Enjoy!
