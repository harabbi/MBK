1- Type this d
        bundle install

2- edit your ~/.bashrc or ~/.bash_profile to set the environment variables needed in scripts/mbk_params.rb

3- Type this command
	cp wholeTableList.master tablesToDownload

4- Edit tableToDownload to include only the tables wanted

5- Type this command
        crontab -e    #to edit the cron daemon. Add the application run intervals
        example crontab...
          SHELL=/bin/bash
          PATH=/sbin:/bin:/usr/sbin:/usr/bin:/home/<mbk>/.rvm/rubies/ruby-1.9.3-p194/bin
          BASH_ENV=/home/<mbk>/.bashrc
          MAILTO=<mbkadmin>@gmail.com
          0 0  * * * /bin/bash -c -l "/home/<mbk>/run_v_site2xml.sh"
          */10 * * * * /bin/bash -c -l "/home/<mbk>/run_v_xml2mysql.sh"
          */10 * * * * /bin/bash -c -l "/home/<mbk>/run_v_mysql2site.sh"
          */10 * * * * /bin/bash -c -l "/home/<mbk>/run_v_hsm.sh"
~                                                             

Enjoy!
