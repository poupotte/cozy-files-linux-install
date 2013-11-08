#!/bin/bash

echo "Could you enter a username and a password for your local database ?"
read username
read password 
database="cozy-files"


# Create database
echo -e "\033[33m Database creation ... \033[0m"
COUCH="http://localhost:5984"
curl -HContent-Type:application/json -vXPUT $COUCH/_users/org.couchdb.user:$username --data-binary "{\"_id\": \"org.couchdb.user:$username\",\"name\": \"$username\",\"roles\": [],\"type\": \"user\",\"password\": \"$password\"}"
curl -vX PUT $COUCH/$database
curl -vX PUT $COUCH/$database/_security  \
   -Hcontent-type:application/json \
    --data-binary "{\"admins\":{\"names\":[\"$username\"],\"roles\":[]},\"members\":{\"names\":[\"$username\"],\"roles\":[]}}"
echo -e "\033[32m Database created \033[0m"


# Configure couchDB
echo -e "\033[33m Database configuration ... \033[0m"
#curl -vX PUT $COUCH/_config/admins/$username -d "\"$password\""
sed -i '/\[external\]/ a\
replication = python /usr/local/src/couchdb/replication.py' /usr/local/etc/couchdb/local.ini
sed -i '/\[httpd_db_handlers\]/ a\
_replication = {couch_httpd_external, handle_external_req, <<"replication">>}' /usr/local/etc/couchdb/local.ini
cd /etc/
mkdir cozy-files
cd cozy-files
wget https://raw.github.com/poupotte/cozy-files-couchapp/master/helpers/replication.py
mv replication.py /usr/local/src/couchdb
service couchdb restart
echo -e "\033[32m Database is well configurated \033[0m"

# Start couchFUSE as deamon
useradd couchfuse
usermod --shell /bin/bash couchfuse
usermod -g fuse couchfuse
echo -e "\033[33m Fuse configuration ... \033[0m"
touch /etc/cozy-files/couchdb.login
chown couchfuse /etc/cozy-files/couchdb.login
chmod 700 /etc/cozy-files/couchdb.login
echo -e "$username\n$password" >> /etc/cozy-files/couchdb.login
git clone https://github.com/poupotte/couchdb-fuse.git
cp couchdb-fuse/replication /etc/init.d
chmod 733 /etc/init.d/replication
cp couchdb-fuse/fuse /etc/init.d
chmod 733 /etc/init.d/fuse
/etc/init.d/fuse start
/etc/init.d/replication start
sudo update-rc.d fuse defaults
sudo update-rc.d replication defaults
echo -e "\033[32m Fuse is well configurated \033[0m"

# Publish couchApp
echo -e "\033[33m couchApp configuration ... \033[0m"
git clone https://github.com/poupotte/cozy-files-couchapp.git
cd cozy-files-couchapp
npm install -g kanso
kanso install
cd /etc/cozy-files/cozy-files-couchapp
echo "http://$username:$password@localhost:5984/$database"
kanso push "http://$username:$password@localhost:5984/$database"
echo -e "\033[32m couchApp is well configurated \033[0m"
echo -e "\033[32m cozy-files is well configurated \033[0m"
echo -e "\033[32m You can go to url :http://localhost:5984/cozy-files/_design/cozy-files/index.html
 to configured your device \033[0m"
