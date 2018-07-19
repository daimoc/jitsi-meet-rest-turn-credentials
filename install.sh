#!/bin/sh



HOST=$1
API_KEY=$2

echo $HOST $API_KEY

insertAfter() # file line newText
{
   local file="$1" line="$2" newText="$3"
   echo $file'|'$line'|'$newText
   sed -i -e "/$line$/a$newText"'\n' "$file"
}

replace() #file search replace
{
  local file="$1" search="$2" replace="$3"
  echo $file'|'$search'|'$replace

  sed -i "s/$search/$replace/g" $file
}

# Basic jitsi-Meet installation for Ubuntu Distribution from quic install : https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
echo "Starting JItsi-Meet Installation"

echo "Set debconf"


echo "jitsi-videobridge jitsi-videobridge/jvb-hostname string $HOST" | debconf-set-selections
echo "jitsi-meet jitsi-meet/cert-choice select Self-signed certificate will be generated" | debconf-set-selections


echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list
wget -qO -  https://download.jitsi.org/jitsi-key.gpg.key | apt-key add -
apt-get update
apt-get -y install nginx jitsi-meet

cp mod_prosody/mod_restturn.lua  /usr/lib/prosody/modules/

# Get the Jitsi-Meet installation hostname and config files
HOSTNAME=`echo "get jitsi-videobridge/jvb-hostname" | debconf-communicate | awk '{print $2}'`
prosody_conf_file=/etc/prosody/conf.d/$HOSTNAME.cfg.lua
jitsi_meet_conf_file=/etc/jitsi/meet/$HOSTNAME-config.js

echo "Your Jisto Host name is : " $HOSTNAME
echo "Your Prosody Vhost configuration file is : " $prosody_conf_file
echo "Your Jitsi-Meet Javascript configuration file is : " $jitsi_meet_conf_file

echo "Modifing your prosody configuration to add mod_restturn"

ping_line="\"ping\"; -- Enable mod_ping"
restturn_line="\ \ \ \ \ \ \ \ \"restturn\"; -- Enable mod_restturn"
c2s_require_encryption_line="c2s_require_encryption = false"
rest_turn_host_line="\ \ \ \ \ \ \ \ rest_turn_host = \"https:\/\/api.turn.geant.org\""
rest_turn_api_key="\ \ \ \ \ \ \ \ rest_turn_api_key = \"$API_KEY\""

insertAfter $prosody_conf_file "$ping_line" "$restturn_line"
insertAfter $prosody_conf_file "$c2s_require_encryption_line" "$rest_turn_host_line"
insertAfter $prosody_conf_file "$c2s_require_encryption_line" "$rest_turn_api_key"

service prosody restart

echo "Setting on TURN XEP-0215 in your Jitsi-Meet installation for all your Peerconnection P2p And videobridge"
replace $jitsi_meet_conf_file "\/\/ useStunTurn: true," "useStunTurn: true,"

echo "Work Done"
