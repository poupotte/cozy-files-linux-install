# Avoir couchdb > 1.1

echo "Could you enter a username and a password for your local database ?"
read username
read password 
database="cozy-files"
COUCH="http://localhost:5984"

curl -X DELETE $COUCH/$database
rm -rf /etc/cozy-files

echo "\033[33m Database configuration ... \033[0m"
curl -HContent-Type:application/json -vXPUT $COUCH/_users/org.couchdb.user:$username --data-binary "{\"_id\": \"org.couchdb.user:$username\",\"name\": \"$username\",\"roles\": [],\"type\": \"user\",\"password\": \"$password\"}"
echo "\033[32m Database configured \033[0m"


echo "\033[33m Recover source ... \033[0m"
mkdir /etc/cozy-files
cd /etc/cozy-files
git clone https://github.com/poupotte/couchdb-fuse.git
echo "\033[32m Source recovered \033[0m"

# Stocker password
echo "\033[33m Password configuration ... \033[0m"
touch /etc/cozy-files/couchdb.login
user="$(users)"
chown $user:$user /etc/cozy-files/couchdb.login
chmod 700 /etc/cozy-files/couchdb.login
echo "$username\n$password"
echo "$username" >> /etc/cozy-files/couchdb.login
echo "$password" >> /etc/cozy-files/couchdb.login
echo "\033[32m Password configured \033[0m"

cd couchdb-fuse/
# Install dependencies
echo "\033[33m Dependencies installation ... \033[0m"
apt-get install python-fuse
apt-get install python-couchdb
apt-get install python-pip
pip install requests
apt-get install python-appindicator
apt-get install python-glade2
apt-get install python-gobject
apt-get install gir1.2-gtk-3.0
echo "\033[32m Dependencies installed ... \033[0m"
su $user -c 'python cozy_files.py'
echo "\033[32m Cozy-files is well installed ... \033[0m"