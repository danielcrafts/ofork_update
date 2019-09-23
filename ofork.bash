#!/bin/bash

    version=
    echo -n "Enter the Version like ofork-8.0.8: "
    read version
    archive="$version.tar.gz"

    decision=
    echo -n "Version is $version ? Type yes to continue: "
    read decision

        if [ "$decision" = "yes" ]; then
        echo "Startin preperation"

		echo "Stopping Services"
		cd /opt/
		/etc/init.d/cron stop
		/etc/init.d/postfix stop
		/etc/init.d/apache stop

		echo "Stopping Crons"
		sudo -u ofork /opt/ofork/bin/Cron.sh stop
		sudo -u ofork /opt/ofork/bin/ofork.Daemon.pl stop

		echo "Cleanup/Backup Database"
		/etc/init.d/mysql stop
		rm -r /var/lib/mysql_old
		cp -r /var/lib/mysql /var/lib/mysql_old
		/etc/init.d/mysql start
		
		echo "Cleanup/Backup Directory"
		rm -r /opt/ofork-old
		mv /opt/ofork /opt/ofork-old

		echo "Startin Update itself"
		wget https://ftp.o-fork.de/$archive
		tar xzf $archive
		rm $archive
		mv /opt/$version /opt/ofork
		cp /opt/ofork-old/Kernel/Config.pm /opt/ofork/Kernel/Config.pm

		echo "Changing Permissions"
		/opt/ofork/bin/ofork.SetPermissions.pl

		echo "Update Database"
		sudo -u ofork /opt/ofork/scripts/DBUpdate-to-8.pl
		databaseupdate=
		echo -n "Incase of any exceptions type fail: "
		read databaseupdate
		if [ "$databaseupdate" = "fail" ]; then
        exit
        fi
		
		rm /opt/ofork/Kernel/Config/Files/ZZZAAuto.pm
		
		echo "Starting Services"
		/etc/init.d/apache start
		/etc/init.d/postfix start
		/etc/init.d/cron start

		echo "Startin Cron"
		sudo -u ofork /opt/ofork/bin/ofork.Daemon.pl start
		sudo -u ofork /opt/ofork/bin/Cron.sh start

		echo "Finished type anything to close"
		read finish
		
		exit
		fi

	echo "Update abort"
	exit

