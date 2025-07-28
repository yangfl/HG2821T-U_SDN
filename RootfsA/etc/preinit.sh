#!/bin/sh
echo "Pre_initialization script"
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH

#case $(uname -r) in
#    2.6*|2.7*)	;;
#    *)		exit 0;;
#esac

udev_root=/dev
# Check for missing binaries
UDEV_BIN=/usr/sbin/udevd
test -x $UDEV_BIN || echo "test -x $UDEV_BIN" || exit 5
UDEVSTART_BIN=/usr/sbin/udevstart
test -x $UDEVSTART_BIN || echo "test -x $UDEVSTART_BIN" || exit 5

# Check for config file and read it
UDEV_CONFIG=/etc/udev/udev.conf
test -r $UDEV_CONFIG || echo "test -r $UDEV_CONFIG" || exit 6
. $UDEV_CONFIG

/bin/mount -t proc proc /proc
/bin/mount -t tmpfs tmpfs /tmp
# Directory where sysfs is mounted
SYSFS_DIR=/sys

# mount sysfs if it's not yet mounted
if [ ! -d $SYSFS_DIR ]; then
echo "${0}: SYSFS_DIR \"$SYSFS_DIR\" not found"
#exit 1
fi
grep -q "^sysfs $SYSFS_DIR" /proc/mounts || mount -t sysfs sys /sys 
#|| exit 1

# mount $udev_root as ramfs if it's not yet mounted
# we know 2.6 kernels always support ramfs
if [ ! -d $udev_root ]; then
echo "${0}: udev_root \"$udev_root\" not found"
#exit 1
fi
grep -q "^udev $udev_root" /proc/mounts || mount -t ramfs udev $udev_root || exit 1
mknod /dev/ttyS0 c 4 64
mkdir $udev_root/pts $udev_root/shm
mknod -m 0666 /dev/null c 1 3
mknod -m 0666 /dev/zero c 1 5
mknod -m 0600 /dev/console c 5 1

# populate /dev (normally)
echo -n "Populating $udev_root using udev: "
echo -e '\000\000\000\000' > /proc/sys/kernel/hotplug
$UDEV_BIN -d || (echo "FAIL" && exit 1)
$UDEVSTART_BIN || (echo "FAIL" && exit 1)
mount -t devpts /dev/pts /dev/pts || (echo "FAIL" && exit 1)
echo "done"		
bootfrom=`fw_printenv | grep bootflag= | awk -F "=" '{print $2}'`
echo "bootfrom=$bootfrom"

#mount appfs
if [ "$bootfrom" == "bootfromA" ]
then
	/usr/sbin/ubiattach /dev/ubi_ctrl -m 2 -d 1
	mount -t ubifs -o sync,ro ubi1:Appfs /rom
elif [ "$bootfrom" == "bootfromB" ]
then
	/usr/sbin/ubiattach /dev/ubi_ctrl -m 5 -d 1
	mount -t ubifs -o sync,ro ubi1:Appfs /rom
else
	echo "warning:bootfrom is error or empty"
	/usr/sbin/ubiattach /dev/ubi_ctrl -m 2 -d 1
	mount -t ubifs -o sync,ro ubi1:Appfs /rom
fi
	
mount -t jffs2 -o rw /dev/mtdblock8 /flash || echo "failed mount mtdblock8"
mount -t jffs2 -o rw /dev/mtdblock9 /usr/local || echo "failed mount mtdblock9"
mount -t jffs2 -o rw /dev/mtdblock10 /usr/wrifh || echo "failed mount mtdblock10"

if [ ! -f /usr/local/fh ]
then 
	ln -s /usr/wrifh /usr/local/fh
	sync
fi

if [ -f /usr/local/fh/mf/factory_mode ]                                         
then                                                                            
        mount -t jffs2 -o rw /dev/mtdblock7 /data || echo "failed mount mtdblock7"
else                                                                            
        mount -t jffs2 -o ro /dev/mtdblock7 /data || echo "failed mount mtdblock7"
fi

/usr/sbin/ubiattach /dev/ubi_ctrl -m 13 -d 2
if [ ! -d /sys/class/ubi/ubi2 ]
then                              
    mtd erase /dev/mtd13  
	/usr/sbin/ubiattach /dev/ubi_ctrl -m 13 -d 2
fi 
if [ ! -c /dev/ubi2 ]
then
	MAJOR1=`awk -F ':' '{print $1}' /sys/class/ubi/ubi2/dev`
	MINOR1=`awk -F ':' '{print $2}' /sys/class/ubi/ubi2/dev` 
	mknod /dev/ubi2 c $MAJOR1 $MINOR1
fi
	VOLUMES_COUNT=`cat /sys/class/ubi/ubi2/volumes_count`
if [ $VOLUMES_COUNT -eq 0 ]
then
	/usr/sbin/ubimkvol /dev/ubi2 -N Apps_ubifs -m
fi
if [ ! -c /dev/ubi2_0 ]
then
	MAJOR2=`awk -F ':' '{print $1}' /sys/class/ubi/ubi2_0/dev`
	MINOR2=`awk -F ':' '{print $2}' /sys/class/ubi/ubi2_0/dev` 
	mknod /dev/ubi2_0 c $MAJOR2 $MINOR2
fi
mount -t ubifs -o sync ubi2:Apps_ubifs /opt/upt/apps

if [ ! -f /opt/upt/apps/etc/dbus-1/system.conf ]
then
	cp -r /usr/etc /opt/upt/apps/
fi

# #删除整个/flash/cfg目录
# if [ ! -d /flash/cfg ]
# then
	# mkdir /flash/cfg
	# cp -fr /rom/cfg/* /flash/cfg/.	
# else
	# #删除/flash/cfg/app_conf目录
	# if [ ! -d /flash/cfg/app_conf ]
	# then 
		# cp -fr /rom/cfg/app_conf /flash/cfg/.
# #	else
# #	app_conf_filelist=`ls /flash/cfg/app_conf`
# #	for app_conf_tmpfile in app_conf_filelist
# #	do
# #		./rom/fhshell/misc_shell/cfg_bak_restore.sh app_conf_tmpfile confcheck all
# #	done
	# fi

	# #agent
	# if [ ! -d /flash/cfg/agentconf ]
	# then 
		# cp -fr /rom/cfg/agentconf /flash/cfg/.	
	# else
		# #check all conf from agent
		# ./rom/fhshell/misc_shell/cfg_bak_restore.sh agent confcheck all
	# fi	
	
	# #fhbox
	# if [ ! -d /flash/cfg/fhbox_conf ]
	# then 
		# cp -fr /rom/cfg/fhbox_conf /flash/cfg/.
	# fi	
		
	# #wlan_conf
	# if [ ! -d /flash/cfg/wlan_conf ]
	# then 
		# cp -fr /rom/cfg/wlan_conf /flash/cfg/.	
	# fi	
	
# fi

# #ADD FOR SOFTVERSION
AREA_CODE=`getcfgx /data/tr069_control.conf "area_code"`                
SoftVersion=`getcfgx /data/factory.conf SoftwareVersion`
SoftVersion_origin=`getcfgx /etc/SoftwareVersionTable.conf "$AREA_CODE"`
if [ "$SoftVersion" != "$SoftVersion_origin" ]         
then
		echo new softwareversion is $SoftVersion_origin
        mount -o remount,rw /data                                
        setcfgx /data/factory.conf SoftwareVersion $SoftVersion_origin
        #for sdn hg,jzhchen 201706
        setcfgx /flash/cfg/agentconf/factory.conf SoftwareVersion $SoftVersion_origin
        mount -o remount,ro /data  
fi 

if [ ! -f /flash/cfg/app_conf/secret/iv ]
then
	sn=`getcfgx /data/factory.conf SerialNumber`
	mac=`getcfgx /data/factory.conf internetmac`
	pwd=`getcfgx /data/factory.conf UserPasswd`
	ivStr="$sn"_"$mac"_"$pwd"
	md5=`code-gen $ivStr`
	iv-gen $md5
	sync
fi

exec /bin/init