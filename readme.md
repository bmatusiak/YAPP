
flash your pi card,
put `ssh` file in boot part to enable ssh

login, change password

run this once
```
echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
```

reboot

then run this 
```
wget -qO- https://raw.githubusercontent.com/bmatusiak/YAPP/master/clone.sh | bash
```
