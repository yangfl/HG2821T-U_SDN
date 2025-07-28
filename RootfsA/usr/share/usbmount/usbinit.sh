#!/bin/sh
COMMON_CONF=/etc/fh_common.conf                                                 
GETCFGX=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `                   
SETCFGX=`grep "MISC_SHELL_PATH_SETCFG=" $COMMON_CONF | cut -d = -f 2 ` 
USB_PATH=`grep "MISC_SHELL_PATH=" $COMMON_CONF | cut -d = -f 2 `
NAME=`grep "DeviceType=" $COMMON_CONF | cut -d = -f 2 `
if [ -x /var/version ] 
then 
	echo "echo \"USBMOUNT.RP0100.081030\" " >> /var/version
else
	touch /var/version
	echo "#!/bin/sh" >> /var/version
	echo "echo \"USBMOUNT.RP0100.081030\" " >> /var/version
	chmod +x /var/version
fi

umask 000

fstype=""
BACCONFIGFLAG=""
#if [ -f /flash/etc/midware_enable ]
#then
	#vfatoptions="-o codepage=936,iocharset=gb2312"
#else
	vfatoptions="-o iocharset=utf8"
#fi
#vfatoptions="-o iocharset=utf8"
#vfatoptions="-o codepage=936,iocharset=gb2312"
mountinfo=""
devicename="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh"

#usbbacflag=`$GETCFGX /flash/cfg/agentconf/factory.conf UsbBacSwitch`
usbbacflag="on"

#init usbmoun.conf
if [ ! -f /etc/usbmount/usbmount.conf ]
then
	touch /etc/usbmount/usbmount.conf
	$SETCFGX /etc/usbmount/usbmount.conf mountnum 0
fi

m=1
for j in ${devicename}
do
	i=0
	subdevicename=""
	while :
	do
		if [ ${i} -lt 20 ]
		then
			if [ ${i} -eq 0 ]
			then
				subdevicename="${j}"
			else
				subdevicename="${j}${i}"
			fi

			if [ -b ${subdevicename} ]
			then
				SUCCESS=""

				mountflag=""
				mountflag=`mount | grep ${subdevicename}`
				if [ ! -z "${mountflag}" ]
				then
					Usbmountpoint="/mnt/usb${m}_${i}"
					mkdir ${Usbmountpoint}
				else
					Usbmountpoint=`mkdir ${subdevicename}`
				fi
				fstype="`/lib/udev/vol_id   \"$subdevicename\" | egrep '^ID_FS_TYPE' | awk -F "=" '{print $2}'`"
				if [ "$fstype" == "vfat" ]
				then
					Usbmountpoint="/mnt/usb${m}_${i}"
					mkdir ${Usbmountpoint}
					mountinfo="`mount -t vfat ${vfatoptions} ${subdevicename} ${Usbmountpoint}`"
					if [ "test${usbbacflag}" == "teston" ]
					then
						if [ -z "${BACCONFIGFLAG}" ]
						then
							if [ -f ${Usbmountpoint}/e8_Config_Backup/ctce8_$NAME.cfg ]
							then
								cp -rf ${Usbmountpoint}/e8_Config_Backup/ctce8_$NAME.cfg /var/ctce8_$NAME.cfg
								$USB_PATH/usbbak recovery
								BACCONFIGFLAG="success"
								touch /var/usbbac
							fi
						fi
					fi	
#					check if mount opt success,added by zyzhou,20090416
					mountflag=""
					mountflag=`mount | grep ${subdevicename}`
					if [ ! -z "${mountflag}" ]
					then
						SUCCESS="ok"
						/usr/bin/led_ctrl set usb on
						mountdevnum=`$GETCFGX /etc/usbmount/usbmount.conf mountnum`
						mountdevnum=$((mountdevnum+1))
						$SETCFGX /etc/usbmount/usbmount.conf mountnum ${mountdevnum}
					else
						rm -rf ${Usbmountpoint}
						/usr/bin/led_ctrl set usb off
					fi

					
				fi

				if [ "$fstype" == "ntfs" ] 
				then
					Usbmountpoint="/mnt/usb${m}_${i}"
					mkdir ${Usbmountpoint}
					mountinfo="`/usr/bin/ntfs-3g ${subdevicename} ${Usbmountpoint}`"
					if [ "test${usbbacflag}" == "teston" ]
					then
						if  [ -z "${BACCONFIGFLAG}" ]
						then
							if [ -f ${Usbmountpoint}/e8_Config_Backup/ctce8_$NAME.cfg ]
							then
								cp -rf ${Usbmountpoint}/e8_Config_Backup/ctce8_$NAME.cfg /var/ctce8_$NAME.cfg
								$USB_PATH/usbbak recovery
								BACCONFIGFLAG="success"
								touch /var/usbbac
							fi
						fi
					fi
					touch /var/ntfsdev
#					check if mount opt success,added by zyzhou,20090416
					mountflag=""
					mountflag=`mount | grep ${subdevicename}`
					if [ ! -z "${mountflag}" ]
					then
						SUCCESS="ok"
						/usr/bin/led_ctrl set usb on
						mountdevnum=`$GETCFGX /etc/usbmount/usbmount.conf mountnum`
						mountdevnum=$((mountdevnum+1))
						$SETCFGX /etc/usbmount/usbmount.conf mountnum ${mountdevnum}
					else
						rm -rf ${Usbmountpoint}
						/usr/bin/led_ctrl set usb off
					fi
				fi
	
				if [ "$SUCCESS" != "ok" ] 
				then
					rm -rf ${Usbmountpoint}
					/usr/bin/led_ctrl set usb off
				fi
			fi
#			echo "${subdevicename}"
		else
			break;
		fi
		i=$((i+1))
	done
	m=$((m+1))
done

#killall udevd
#udevd -d


