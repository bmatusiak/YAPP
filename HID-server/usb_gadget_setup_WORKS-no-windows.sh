#!/bin/bash

modprobe libcomposite

command="$1" # "up" or "down"

gadget_id=$2

if [[ -z "$gadget_id" ]]; then
gadget_id="1"
fi

gadget_id="my_gadget${gadget_id}"

gadgetDevice="/sys/kernel/config/usb_gadget/${gadget_id}"

echo "Running $1 on ${gadget_id}"

echo $gadgetDevice

# raw_HID="\x06\xd0\xf1\x09\x01\xa1\x01\x09\x20\x15\x00\x26\xff\x00\x75\x08\x95\x40\x81\x02\x09\x21\x15\x00\x26\xff\x00\x75\x08\x95\x40\x91\x02\xc0"
# norm_HID="\x05\x01\x09\x06\xa1\x01\x05\x07\x19\xe0\x29\xe7\x15\x00\x25\x01\x75\x01\x95\x08\x81\x02\x95\x01\x75\x08\x81\x03\x95\x05\x75\x01\x05\x08\x19\x01\x29\x05\x91\x02\x95\x01\x75\x03\x91\x03\x95\x06\x75\x08\x15\x00\x25\x65\x05\x07\x19\x00\x29\x65\x81\x00\xc0"

hid_discriptor1="\x05\x01\x09\x06\xA1\x01\x05\x07\x19\xE0\x29\xE7\x15\x00\x25\x01\x75\x01\x95\x08\x81\x02\x95\x01\x75\x08\x05\x0C\x09\xB8\x81\x01\x95\x05\x75\x01\x05\x08\x19\x01\x29\x05\x91\x02\x95\x01\x75\x03\x91\x01\x95\x06\x75\x08\x15\x00\x25\x7F\x05\x07\x19\x00\x29\x7F\x81\x00\x09\x76\x95\x08\x75\x08\xB1\x02\xC0"
hid_discriptor2="\x06\xD0\xF1\x09\x01\xA1\x01\x09\x20\x15\x00\x26\xFF\x00\x75\x08\x95\x40\x81\x02\x09\x21\x15\x00\x26\xFF\x00\x75\x08\x95\x40\x91\x02\xC0"
hid_discriptor3="\x06\xAB\xFF\x09\x02\xA1\x01\x09\x20\x15\x00\x26\xFF\x00\x75\x08\x95\x40\x81\x02\x09\x21\x15\x00\x26\xFF\x00\x75\x08\x95\x40\x91\x02\xC0"
hid_discriptor4="\x06\xC9\xFF\x09\x04\xA1\x5C\x75\x08\x15\x00\x26\xFF\x00\x95\x40\x09\x75\x81\x02\x95\x20\x09\x76\x91\x02\x95\x04\x09\x76\xB1\x02\xC0"

cd /sys/kernel/config/usb_gadget/

usb_up() {

	if [ -d ${gadgetDevice} ]; then
		if [ "$(cat ${gadgetDevice}/UDC)" != "" ]; then
			echo "Gadget is already up."
			exit 1
		fi
		echo "Cleaning up old directory..."
		usb_down
	fi
	echo "Setting up gadget..."

	cd /sys/kernel/config/usb_gadget/
	mkdir -p ${gadget_id}
	cd ${gadget_id}
	
	#idVendor           0x1d50 OpenMoko, Inc.
	#idProduct          0x60fc OnlyKey Two-factor Authentication and Password Solution
	
	
	echo 0x16c0 > idVendor # CryptoTrust
	echo 0x0486 > idProduct # OnlyKey
	
	# echo 0x1d6b > idVendor # Linux Foundation
	# echo 0x0104 > idProduct # Multifunction Composite Gadget
	
#	echo 0x0100 > bcdDevice # v1.0.0
	echo 0x0200 > bcdUSB # USB2
	
	echo "0x00" > bDeviceClass
	echo "0x00" > bDeviceSubClass
	echo "0x3066" > bcdDevice
		 
	 
	mkdir -p strings/0x409
	echo "1000000000" > strings/0x409/serialnumber
	echo "CRYPTOTRUST" > strings/0x409/manufacturer
	echo "ONLYKEY" > strings/0x409/product
	
	
	
	
	
	#ethernet
	mkdir -p functions/rndis.usb0
	# first byte of address must be even
	HOST="46:6f:73:74:50:43" # "HostPC"
	SELF="44:61:64:55:53:42" # "BadUSB"
	echo $HOST > functions/rndis.usb0/host_addr
	echo $SELF > functions/rndis.usb0/dev_addr
	
    ms_vendor_code="0xcd" # Microsoft
    ms_qw_sign="MSFT100" # also Microsoft (if you couldn't tell)
    ms_compat_id="RNDIS" # matches Windows RNDIS Drivers
    ms_subcompat_id="5162001" # matches Windows RNDIS 6.0 Driver
	
	echo 1      				>	os_desc/use
	echo "${ms_vendor_code}"    >	os_desc/b_vendor_code
	echo "${ms_qw_sign}"		>	os_desc/qw_sign
    echo "${ms_compat_id}"		>	functions/rndis.usb0/os_desc/interface.rndis/compatible_id
    echo "${ms_subcompat_id}"	>	functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id
	
	
	mkdir -p configs/c.1/strings/0x409
	echo "Configuration 1" > configs/c.1/strings/0x409/configuration
	echo 120 > configs/c.1/MaxPower
	ln -s functions/rndis.usb0 configs/c.1/
	ln -s configs/c.1 os_desc
	
	
	mkdir -p configs/c.2/strings/0x409
	echo "Configuration 2" > configs/c.2/strings/0x409/configuration
	echo 120 > configs/c.2/MaxPower
	ln -s functions/rndis.usb0 configs/c.2/
	# ln -s configs/c.2 os_desc
	
	hid_usb_up 0 $hid_discriptor1
	hid_usb_up 1 $hid_discriptor2
	hid_usb_up 2 $hid_discriptor3
	hid_usb_up 3 $hid_discriptor4
	
	
	ls /sys/class/udc > UDC
	
	
	ifconfig usb0 192.168.8.254 netmask 255.255.255.0 up
	
	
	chmod a+rw /dev/hidg*

    echo "Done."
}


hid_usb_up() {
	mkdir -p functions/hid.usb$1
	echo 0 > functions/hid.usb$1/protocol
	echo 0 > functions/hid.usb$1/subclass
	echo 64 > functions/hid.usb$1/report_length
	# HID descriptor
	echo -ne $2 > functions/hid.usb$1/report_desc
	ln -s functions/hid.usb$1 configs/c.2/
}

hid_usb_down() {
	rm -rf ${gadgetDevice}/configs/c.2/hid.usb$1
    [ -d ${gadgetDevice}/functions/hid.usb$1 ] && rmdir ${gadgetDevice}/functions/hid.usb$1
}


usb_down() {
	if [ ! -d ${gadgetDevice} ]; then
        echo "Gadget is already down."
        exit 1
    fi
    echo "Taking down gadget..."
	
	# kill the UDC
	if [ "$(cat ${gadgetDevice}/UDC)" != "" ]; then
        echo "" > ${gadgetDevice}/UDC
    fi
    
    
    rm -f ${gadgetDevice}/configs/c.1/rndis.usb0
    [ -d ${gadgetDevice}/functions/rndis.usb0 ] && rmdir ${gadgetDevice}/functions/rndis.usb0
	
	
	hid_usb_down 0
	hid_usb_down 1
	hid_usb_down 2
	hid_usb_down 3
	
	#remove strings
	[ -d ${gadgetDevice}/configs/c.1/strings/0x409 ] && rmdir ${gadgetDevice}/configs/c.1/strings/0x409
	[ -L ${gadgetDevice}/os_desc/c.1 ] && rm -rf ${gadgetDevice}/os_desc/c.1
	[ -d ${gadgetDevice}/configs/c.1 ] && rmdir ${gadgetDevice}/configs/c.1
	
	[ -d ${gadgetDevice}/configs/c.2/strings/0x409 ] && rmdir ${gadgetDevice}/configs/c.2/strings/0x409
	[ -L ${gadgetDevice}/os_desc/c.2 ] && rm -rf ${gadgetDevice}/os_desc/c.2
	[ -d ${gadgetDevice}/configs/c.2 ] && rmdir ${gadgetDevice}/configs/c.2
	
	
    [ -d ${gadgetDevice}/strings/0x409 ] && rmdir ${gadgetDevice}/strings/0x409
	
	#remove the gadget
	rmdir ${gadgetDevice}
	
    echo "Done."
}

case ${command} in

up)
    usb_up
    ;;
down)
    usb_down
    ;;
*)
    echo "Usage: usb_gadget.sh up|down"
    exit 1
    ;;
esac
