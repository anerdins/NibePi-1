#!/bin/bash
echo "Starting Update of NibePi"
echo "Setting R/W mode for the filesystem during update..."
mount=$(sudo mount -o remount,rw / 2>/tmp/tar_stderr);
echo "Looking for Node-RED folder."
dirNodeRED=$(find / -type f -name 'flows.json' 2>/dev/null | sed -r 's|/[^/]+$||' |sort |uniq);
echo $dirNodeRED
if [ -z $dirNodeRED ]
then
echo "Path not found, restoring last version."
cp /home/pi/.node-red/flows_saved.bak /home/pi/.node-red/flows.json 2>/dev/null
cp /home/pi/.nibepi/heatpump_saved.js /home/pi/.nibepi/heatpump.js 2>/dev/null
cp /home/pi/.nibepi/config_saved.json /home/pi/.nibepi/config.json 2>/dev/null
echo "Restarting with the old version"
sudo service nibepi restart
sudo service nodered restart
# Abort
else
echo "Path found: ${dirNodeRED}"

echo "Installing the NibePi addon to Node-RED"
cd $dirNodeRED && npm uninstall node-red-contrib-ibm-watson-iot
cd $dirNodeRED && npm audit fix
cd $dirNodeRED && npm uninstall node-red-contrib-nibepi && npm install --save anerdins/node-red-contrib-nibepi#master
echo "Downloading new flows for Node-RED"

cd /tmp && wget https://raw.githubusercontent.com/anerdins/nibepi-flow/master/flows.json
cd /tmp && mv -f flows.json $dirNodeRED/flows.json
echo "Updated succesfully"

echo "Looking for NibePi folder."
dirNode=$(find / -type f -name 'heatpump.js' 2>/dev/null | sed -r 's|/[^/]+$||' |sort |uniq);
if [ -z $dirNode ]
then
echo "Path not found"
else
echo "Path found: ${dirNode}"
rm -R $dirNode
fi
fi
