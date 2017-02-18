
if [ -e "/etc/postgresql/9.3/main/pg_hba.conf" ]; then
	echo "pg_hba.conf is there, skipping postgresql setup"
else
	echo "pg_hba.conf is NOT there, installing postgresql"
	sudo apt-get install -y postgresql postgresql-contrib
fi

if [ $(sudo cat /etc/postgresql/9.3/main/pg_hba.conf | grep 'vagrant' | wc -l) -eq 0 ]; then
	echo "vagrant user is NOT set up for postgresql databases, adding vagrant"
	echo "local\tall\t\tvagrant\t\t\t\tpeer" | sudo tee -a /etc/postgresql/9.3/main/pg_hba.conf
	sudo -u postgres /usr/lib/postgresql/9.3/bin/pg_ctl -D /var/lib/postgresql/9.3/main restart
	sudo -u postgres psql -c "CREATE USER vagrant SUPERUSER;"
else
	echo "vagrant user is set up for postgresql databases"
fi
