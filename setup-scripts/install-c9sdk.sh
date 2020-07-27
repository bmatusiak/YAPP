cd /home/pi


if [ ! -d "/home/pi/c9sdk" ] 
then

pm2 stop c9sdk
pm2 delete c9sdk

rm -rf ./c9sdk
#rm -rf ./.c9
git clone git://github.com/c9/core.git c9sdk
cd c9sdk
scripts/install-sdk.sh
cd /home/pi/YAPP
pm2 start pi.ecosystem.config.js --only c9sdk
mkdir -p /home/pi/workspace
ln -s /home/pi/YAPP /home/pi/workspace/YAPP

fi
