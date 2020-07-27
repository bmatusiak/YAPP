

# install nvm node npm
# install nvm
bash ./setup-scripts/install-nvm-node-npm.sh

bash ./setup-scripts/install-npm-deps.sh

sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-nvm-node-npm.sh"

bash ./setup-scripts/install-pm2.sh
sudo env PATH=$PATH:/home/pi/.nvm/versions/node/v10.21.0/bin /home/pi/.nvm/versions/node/v10.21.0/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi

sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-pm2.sh"
sudo su - -c "pm2 startup"

bash ./setup-scripts/install-c9sdk.sh

sudo su - -c "bash /home/pi/YAPP/setup-scripts/install-root-pm2-services.sh"

sudo su - -c "bash /home/pi/YAPP/setup-scripts/save-pm2-services.sh"
bash ./setup-scripts/save-pm2-services.sh
