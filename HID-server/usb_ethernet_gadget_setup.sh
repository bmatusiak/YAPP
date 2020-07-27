#!/bin/bash

modprobe libcomposite

command="$1" # "up" or "down"

gadget_id=$2

if [[ -z "$gadget_id" ]]; then
gadget_id="2"
fi

config_id="c.2"

gadget_id="my_gadget${gadget_id}"

gadgetDevice="/sys/kernel/config/usb_gadget/${gadget_id}"

echo "Running $1 on ${gadget_id}"

echo $gadgetDevice


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

	# cd /sys/kernel/config/usb_gadget/
	mkdir -p ${gadget_id}
	cd ${gadget_id}
	
	#idVendor           0x1d50 OpenMoko, Inc.
	#idProduct          0x60fc OnlyKey Two-factor Authentication and Password Solution
	
	echo 0x1d6b > idVendor # Linux Foundation
	echo 0x0104 > idProduct # Multifunction Composite Gadget
	echo 0x0100 > bcdDevice # v1.0.0
	echo 0x0200 > bcdUSB # USB2
	
	
	# echo 0xEF > bDeviceClass
	# echo 0x02 > bDeviceSubClass
	#echo 0x01 > bDeviceProtocol
	
	# echo "0x0200" > bcdUSB
	# echo "0x02" > bDeviceClass
		
	echo "0x00" > bDeviceClass
	echo "0x00" > bDeviceSubClass
	echo "0x3066" > bcdDevice
		 
	mkdir -p strings/0x409
	echo "6837591367198653" > strings/0x409/serialnumber
	echo "bmatusiak" > strings/0x409/manufacturer
	echo "pi" > strings/0x409/product
	mkdir -p configs/${config_id}/strings/0x409
	echo "Configuration 2" > configs/${config_id}/strings/0x409/configuration
	echo 250 > configs/${config_id}/MaxPower
	
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
	
	ln -s functions/rndis.usb0 configs/${config_id}/
	
	
	
	ln -s configs/${config_id} os_desc
	
	
	ls /sys/class/udc > UDC
	
	
	ifconfig usb0 192.168.8.254 netmask 255.255.255.0 up
	

    echo "Done."
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
    
    
    rm -f ${gadgetDevice}/configs/${config_id}/rndis.usb0
    [ -d ${gadgetDevice}/functions/rndis.usb0 ] && rmdir ${gadgetDevice}/functions/rndis.usb0
	
	
	#remove strings
	[ -d ${gadgetDevice}/configs/${config_id}/strings/0x409 ] && rmdir ${gadgetDevice}/configs/${config_id}/strings/0x409
	[ -L ${gadgetDevice}/os_desc/${config_id} ] && rm -rf ${gadgetDevice}/os_desc/${config_id}
    [ -d ${gadgetDevice}/configs/${config_id} ] && rmdir ${gadgetDevice}/configs/${config_id}
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
