echo "Could you enter your cozy password ?"
read password

# Remove device
device="$(curl http://localhost:5984/cozy-files/_design/device/_view/all)"
id=`echo $device| cut -c45-76`
device="$(curl http://localhost:5984/cozy-files/_design/device/_view/byUrl)"
url=`echo $device| cut -d'"' -f 14`
curl -X DELETE --user "owner:$password" "$url/device/$id/"

# Remove daemon
/etc/init.d/cozy_files stop
update-rc.d -f cozy_file remove
rm /etc/init.d/cozy_files

# Remove database
curl -X DELETE http://localhost:5984/cozy-files