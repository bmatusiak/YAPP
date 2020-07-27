
cd /home/pi

wget -qO- https://raw.githubusercontent.com/bmatusiak/YAPP/master/setup-scripts/install-system-deps.sh | bash


rm -rf ./YAPP

git clone https://github.com/bmatusiak/YAPP.git YAPP

cd YAPP

bash ./setup.sh
