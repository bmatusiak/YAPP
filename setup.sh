

# install nvm node npm
# install nvm
bash ./setup-scripts/install-nvm-node-npm.sh
sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-nvm-node-npm.sh"

bash ./setup-scripts/install-pm2.sh
sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-pm2.sh"


bash ./setup-scripts/install-c9sdk.sh

cd /home/pi/YAPP
npm install

sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-root-pm2-services.sh"
