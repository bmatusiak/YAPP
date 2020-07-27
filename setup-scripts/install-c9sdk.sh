cd /home/pi
rm -rf ./c9sdk
#rm -rf ./.c9
git clone git://github.com/c9/core.git c9sdk
cd c9sdk
scripts/install-sdk.sh
cd /home/pi/YAPP
pm2 start pi.ecosystem.config.js --only c9sdk
