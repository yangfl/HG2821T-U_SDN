#!/bin/sh

FH_COMMON_PATH=/etc/fh_common.conf

echo "FH_COMMON_PATH=$FH_COMMON_PATH" 

get_fh_common_path_by_macro()
{
    echo `grep "$1=" $FH_COMMON_PATH | cut -d = -f 2 `
}

# The base path to backup the configuration files.
BASE_BAK_CONF_PATH="/flash/backup"
AREA_CONF_PATH="/data/tr069_control.conf"
# The base path of the agent configuration files.
BASE_AGENT_CONF_PATH=`get_fh_common_path_by_macro "APP_CONF_PATH_TR069"`
# The path of Agent configuration files in the ROM, 
ROM_AGENT_CONG_PATH=`get_fh_common_path_by_macro "APP_CONF_PATH_TR069_ROM"`
# The path to backup the Agent configuration files.
BAK_AGENT_CONF_PATH=$BASE_BAK_CONF_PATH"/agentconf"     

# The path of Preconfigured files,
PRECONFIGURED_PATH=`get_fh_common_path_by_macro "PRECONFIGURE_CONF_PATH"`

# The Path For factory reset module.
BASE_APP_CONF_PATH_FIREWALL=`get_fh_common_path_by_macro "APP_CONF_PATH_FIREWALL"`
BASE_MISC_CONF_PATH_QOSRATEV4=`get_fh_common_path_by_macro "MISC_CONF_PATH_QOSRATEV4"`
BASE_MISC_CONF_PATH_PORTVLANTRANS=`get_fh_common_path_by_macro "MISC_CONF_PATH_PORTVLANTRANS"`

ROM_APP_CONF_PATH_FIREWALL=`get_fh_common_path_by_macro "APP_CONF_PATH_FIREWALL_ROM"`
ROM_MISC_CONF_PATH_QOSRATEV4=`get_fh_common_path_by_macro "MISC_CONF_PATH_QOSRATEV4_ROM"`
ROM_MISC_CONF_PATH_PORTVLANTRANS=`get_fh_common_path_by_macro "MISC_CONF_PATH_PORTVLANTRANS_ROM"`

BASE_MISC_CONF_PATH_REGISTER=`get_fh_common_path_by_macro "MISC_CONF_PATH_REGISTER"`

BASE_DHCPV6_CONF_PATH=`get_fh_common_path_by_macro "APP_CONF_PATH_DHCPV6"`
BASE_UDHCPC_CONF_PATH=`get_fh_common_path_by_macro "APP_CONF_PATH_UDHCPC"`

BASE_MISC_CONF_PATH=`get_fh_common_path_by_macro "MISC_CONF_PATH"`

ROM_APP_CONF_PATH="/rom/cfg/app_conf"
ROM_MISC_CONF_PATH="/rom/cfg/misc_conf"
ROM_FHBOX_CONF_PATH="/rom/cfg/fhbox_conf"
FLASH_CONF_PATH="/flash/cfg/"

#The sync identification 
sync_status=0             
area=`grep "area_code=" $AREA_CONF_PATH | cut -d = -f 2 `

# Start of Function for common and for All module ------------------------------------------------------------------------------------------------------
# For check the path to bak the configuration files.If not exist, Create it.
make_bak_path()
{
    if [ ! -d "$1" ];
    then
        mkdir "$1"
		sync
    fi    
      
    return
}

# For sync the buffer to the configuration files.If sync_status is 1, do sync.
sync_conf()
{
	if [ "$1" == "1" ]
	then
		echo "start sync the configuration file!"	
		sync		
	else
		echo "don't sync the configuration file!"
	fi

	return
}

# End of Function for common and for All module ------------------------------------------------------------------------------------------------------

# Start of Function for command for confbak and confcheck and for Agent ------------------------------------------------------------------------------------------------------
# For bak the configuration files of Agent.
bak_agent_conf()
{
    # Check the bak path of Agent exist? If not Exist, Create it.
    make_bak_path $BAK_AGENT_CONF_PATH
    
    # Backup the all files of Agent.
    if [ "xall"=="x$1" ]
    then 
        # Backup All, Must list the files or recorver the files.I don't know how to do it now.
        cp -rf $BASE_AGENT_CONF_PATH"/param.xml"  $BAK_AGENT_CONF_PATH"/."
        cp -rf $BASE_AGENT_CONF_PATH"/factory.conf"  $BAK_AGENT_CONF_PATH"/."
        
    # Backup for the file defined only.
    else
        if [ -s $BASE_AGENT_CONF_PATH"/$1" ]
        then 
            cp -rf $BASE_AGENT_CONF_PATH"/$1"  $BAK_AGENT_CONF_PATH"/."
        else
            echo "$BASE_AGENT_CONF_PATH/$1 not found or is Empty. Nothing to Backup."
        fi
    fi
    
    sync 
    
    return
    
}

# For check the configuration files of the Agent.
check_agent_conf()
{    
    # Check the Base path of Agent exist? If not Exist, Create it.
    make_bak_path $BASE_AGENT_CONF_PATH
    
    # Check All, Must list the files or recorver the files.I don't know how to do it now.
    if [ "xall"=="x$1" ]
    then         
        # Check for param.xml.
        if [ ! -s $BASE_AGENT_CONF_PATH"/param.xml" ]
        then 
            # Recover from Bak path of Agent.
            if [ -s $BAK_AGENT_CONF_PATH"/param.xml" ]
            then
                cp -rf $BAK_AGENT_CONF_PATH"/param.xml" $BASE_AGENT_CONF_PATH"/."
            else
                # Recover from path of preconfigured, 
                if [ -s  $PRECONFIGURED_PATH"/param.xml" ]
                then 
                    cp -rf $PRECONFIGURED_PATH"/param.xml" $BASE_AGENT_CONF_PATH"/."
                # Recover from path of Path of ROM, 
                else
                    cp -rf $ROM_AGENT_CONG_PATH"/param.xml" $BASE_AGENT_CONF_PATH"/."
                fi # End of if [ -s  $PRECONFIGURED_PATH"/param.xml"]
                
            fi # End of if [ -s $BAK_AGENT_CONF_PATH"/param.xml" ]  
			sync_status=1			
        else 
            echo "$BASE_AGENT_CONF_PATH/param.xml found and not Empty. Nothing to do." 
        fi # End of if [ -s $BASE_AGENT_CONF_PATH"/param.xml" ]

        sync_conf $sync_status
		sync_status=0
        
        # Check for factory.conf.
        if [ ! -s $BASE_AGENT_CONF_PATH"/factory.conf" ]
        then 
            # Recover from Bak path of Agent.
            if [ -s $BAK_AGENT_CONF_PATH"/factory.conf" ]
            then
                cp -rf $BAK_AGENT_CONF_PATH"/factory.conf" $BASE_AGENT_CONF_PATH"/."
            else
                # Recover from path of preconfigured, 
                if [ -s  $PRECONFIGURED_PATH"/factory.conf" ]
                then 
                    cp -rf $PRECONFIGURED_PATH"/factory.conf" $BASE_AGENT_CONF_PATH"/."
                # Recover from path of Path of ROM, 
                else
                    cp -rf $ROM_AGENT_CONG_PATH"/factory.conf" $BASE_AGENT_CONF_PATH"/."
                fi # End of if [ -s  $PRECONFIGURED_PATH"/factory.conf"]
                
            fi # End of if [ -s $BAK_AGENT_CONF_PATH"/factory.conf" ]
			sync_status=1            
        else 
            echo "$BASE_AGENT_CONF_PATH/param.xml found and not Empty. Nothing to do." 
        fi # End of if [ -s $BASE_AGENT_CONF_PATH"/factory.conf" ]

        sync_conf $sync_status
		sync_status=0
		
        # Check for manager_inc.		
        # if [ ! -s $BASE_AGENT_CONF_PATH"/hgcxml.param" ]
		# then
            # Recover from path of Path of ROM, 		
			# cp -rf $ROM_AGENT_CONG_PATH"/hgcxml.param" $BASE_AGENT_CONF_PATH"/."
		# fi		
			
        # if [ ! -s $BASE_AGENT_CONF_PATH"/hgcxml.conf" ]
		# then
			# cp -rf $ROM_AGENT_CONG_PATH"/hgcxml.conf" $BASE_AGENT_CONF_PATH"/." 
		# fi

        if [ ! -s $BASE_AGENT_CONF_PATH"/request_auth.conf" ]
		then
			cp -rf $ROM_AGENT_CONG_PATH"/request_auth.conf" $BASE_AGENT_CONF_PATH"/." 
			sync_status=1 
		fi
		
		sync_conf $sync_status
		sync_status=0
        
        # if [ ! -s $BASE_AGENT_CONF_PATH"/hgcxml.obj" ]
		# then
			# cp -rf $ROM_AGENT_CONG_PATH"/hgcxml.obj" $BASE_AGENT_CONF_PATH"/." 
		# fi

        # if [ ! -s $BASE_AGENT_CONF_PATH"/objxml.conf" ]
		# then
			# cp -rf $ROM_AGENT_CONG_PATH"/objxml.conf" $BASE_AGENT_CONF_PATH"/." 
		# fi

        if [ ! -s $BASE_AGENT_CONF_PATH"/sys_conf.conf" ]
		then
			cp -rf $ROM_AGENT_CONG_PATH"/sys_conf.conf" $BASE_AGENT_CONF_PATH"/." 
			sync_status=1 
		fi	
		
		sync_conf $sync_status
		sync_status=0

        # Check for libdev.so.		
        # if [ ! -s $BASE_AGENT_CONF_PATH"/libdev.so" ]
		# then
			# cp -rf $ROM_AGENT_CONG_PATH"/libdev.so" $BASE_AGENT_CONF_PATH"/." 
		# fi			
    
    # Check for the file defined only.
    else
        if [ ! -s $BAK_AGENT_CONF_PATH"/$1" ]
        then
            cp -rf $BAK_AGENT_CONF_PATH"/$1"  $BASE_AGENT_CONF_PATH"/."
			sync_status=1
        else
            echo "$BASE_AGENT_CONF_PATH/$1 found and not Empty. Nothing to do." 
        fi # End of if [ ! -s $BAK_AGENT_CONF_PATH"/$1" ]
		
        sync_conf $sync_status
		
    fi # End ofif [ "xall"=="x$1" ]    
    
    return
}
# End of Function for command for confbak and confcheck and for Agent ------------------------------------------------------------------------------------------------------

# Start of Function for command for confbak and confcheck and for Agent ------------------------------------------------------------------------------------------------------

# For local factory reset.
local_factroy_reset_conf()
{    
    echo "Begin to reset the common configuration files for the local factory reset module."
    
    #rm -rf $BASE_MISC_CONF_PATH_QOSRATEV4
    cp -rf $ROM_MISC_CONF_PATH_QOSRATEV4 $BASE_MISC_CONF_PATH_QOSRATEV4
    
    #rm -rf $BASE_APP_CONF_PATH_FIREWALL
    cp -rf $ROM_APP_CONF_PATH_FIREWALL $BASE_APP_CONF_PATH_FIREWALL
    
    #rm -rf $BASE_MISC_CONF_PATH_PORTVLANTRANS
    cp -rf $ROM_MISC_CONF_PATH_PORTVLANTRANS $BASE_MISC_CONF_PATH_PORTVLANTRANS
    
    #rm -rf $BASE_AGENT_CONF_PATH"/digitmap"
    cp -rf $PRECONFIGURED_PATH"/digitmap" $BASE_AGENT_CONF_PATH"/."
    
    cp -rf $PRECONFIGURED_PATH"/mpa.conf" /flash/cfg/app_conf/mpa/
    rm -f /flash/firstregflag.txt
    
    /usr/sbin/factory_restore 0
        
    sync
    
    return
}

# For app conf & misc conf
misc_app_conf_reset()
{
	cp -rf $ROM_APP_CONF_PATH $FLASH_CONF_PATH
	cp -rf $ROM_MISC_CONF_PATH $FLASH_CONF_PATH
	cp -rf $ROM_FHBOX_CONF_PATH $FLASH_CONF_PATH
	
	sync
	sleep 1
	
	#rm -rf $BASE_AGENT_CONF_PATH"/digitmap"
	cp -rf $PRECONFIGURED_PATH"/digitmap" $BASE_AGENT_CONF_PATH"/."
	
	#rm -rf $BASE_MISC_CONF_PATH"/voice_factory.conf"
	cp -rf $PRECONFIGURED_PATH"/voice_factory.conf" $BASE_MISC_CONF_PATH"/."
	
	sync
	return
}

# For remote factory reset.
remote_fatroy_reset_conf()
{
  echo "Starting remote factory resetting......." 
  rm -f /usr/local/fh/mf/long_xvr_tx_enable
  rm -f /usr/local/fh/mf/factory_mode
  rm -f /usr/local/fh/logined
  
	# For app conf and misc conf to reset
	misc_app_conf_reset
 
  # Form register.conf
  rm -rf $BASE_MISC_CONF_PATH_REGISTER
  
  # Form register.conf
  rm -rf $BASE_MISC_CONF_PATH_REGISTER"_ok"
  
	setcfgx $BASE_AGENT_CONF_PATH"/fr.conf" boot_key 0
    
	# For factory.conf 
	TMPUSER=`grep "TelecomAccount=" $BASE_AGENT_CONF_PATH"/factory.conf" | cut -d = -f 2 `
	TMPPWD=`grep "TelecomPasswd=" $BASE_AGENT_CONF_PATH"/factory.conf" | cut -d = -f 2 `
	cp -rf $PRECONFIGURED_PATH"/factory.conf" $BASE_AGENT_CONF_PATH"/." 
	
	if [ "$1" != "factory" ]
	then
		if [ "$area" == "Shanghai" ]
		then
			setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" TelecomAccount $TMPUSER
			setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" TelecomPasswd $TMPPWD
		fi
	else
		rm -rf $BASE_AGENT_CONF_PATH"/dl.conf"
		cp -rf $ROM_AGENT_CONG_PATH"/request_auth.conf" $BASE_AGENT_CONF_PATH"/." 
		cp -rf $ROM_AGENT_CONG_PATH"/sys_conf.conf" $BASE_AGENT_CONF_PATH"/."
	fi
	
	if [ "$area" != "Shanghai" ] || [ -f /var/RESET_LONGLONG_INTERRUPT_BIT ]
	then
		cp -rf $PRECONFIGURED_PATH"/mpa.conf" /flash/cfg/app_conf/mpa/
		rm -f /flash/firstregflag.txt
	fi

	
  # For remove param.log
  rm  -rf $BASE_AGENT_CONF_PATH"/param.log" 
	
	# For dhcp_client.conf
	cp -rf $PRECONFIGURED_PATH"/dhcp_client.conf" $BASE_UDHCPC_CONF_PATH"/." 
	
	# For dhcp6c_client.conf
	cp -rf $PRECONFIGURED_PATH"/dhcp6c_client.conf" $BASE_DHCPV6_CONF_PATH"/." 

	# For precheck_prerepair.conf
	cp -rf $PRECONFIGURED_PATH"/precheck_prerepair.conf" $BASE_AGENT_CONF_PATH"/." 		
 
	# For ids_protocol.conf
	cp -rf $PRECONFIGURED_PATH"/ids_protocol.conf" $BASE_AGENT_CONF_PATH"/." 
 
 	# For service.conf of nsm
	cp -rf $PRECONFIGURED_PATH"/service.conf" /flash/cfg/app_conf/nsm/conf/
	
	# For stbcheck.conf of stbcheck
	cp -rf $PRECONFIGURED_PATH"/stbcheck.conf" /flash/cfg/app_conf/loop/
	
	sync
}
# End of Function for command for confbak and confcheck and for Agent ------------------------------------------------------------------------------------------------------

# For local short reset. clean smart param
LocalRestore()
{
	rm -rf /flash/cfg/app_conf/mpa/ubus_devname_config
	rm -rf /flash/cfg/app_conf/mpa/wlan/wifitimer_config
	rm -rf /flash/cfg/app_conf/mpa/wlan/wifitimer1_config
	rm -rf /flash/lanhost_control
	rm -rf /flash/cfg/app_conf/mpa/lanhost_speed
	rm -rf /flash/lanhost_conf
	rm -rf /flash/lanhost_device
	rm -rf /flash/lanhost_iftype
	echo > /flash/lanhost_notify
	echo > /flash/cfg/app_conf/mpa/ubus_sleep_config
	rm -rf /flash/cfg/app_conf/mpa/ubus_led_config
	echo > /flash/cfg/app_conf/mpa/http_url_config
	rm -rf /flash/cfg/app_conf/udhcpd/udhcpd_lan.conf
	rm -f /flash/cfg/app_conf/mpa/wlan/5gbackup
	rm -rf /flash/mem/mem_control
	sync
	return
}
#end local short reset
#For local long reset. clean smart param
LocalLongRestore()
{
	rm -rf /flash/cfg/app_conf/mpa/dns_url
	rm -rf /flash/cfg/app_conf/mpa/ftp_anonymous
	rm -rf /flash/cfg/app_conf/mpa/ftp_username
	rm -rf /flash/cfg/app_conf/mpa/smb_username
	dbus-send --system --type=method_call --print-reply --dest=com.ctc.saf1 /com/ctc/saf1 com.ctc.saf1.framework.Restore
	sync
	return
}
# Function main for the Entrance of the Tool.
main()
{    
    # For Check the path for backup. 
    make_bak_path $BASE_BAK_CONF_PATH

    # For the Module.
    case "$1" in
        # For the Module of Agent.
        agent)
            # For the Command surpport in the Module of Agent.
            case "$2" in            
                # For the conbak Command.
                confbak)
                    bak_agent_conf $3
                ;; # end of confbak)
                
                # For the confcheck Command.
                confcheck)
                    check_agent_conf $3
                ;; # end of confcheck)
                
                # For the Default command usually not surpport.
                *)
                    echo "Command Not Surpport."
                ;; # end of *)
                esac
        ;; # end of agent)   
        
        # For the Factory reset Module.
        factory_reset)
            case "$2" in 
                # For local factory reset.
                local_reset)
                		LocalRestore
                    local_factroy_reset_conf $3
                ;;
                # For local Long reset
                long_reset)
                    LocalRestore
             	    LocalLongRestore
                    remote_fatroy_reset_conf $3
                ;;
                
                # For Remote factory reset.
                remote_reset) 
					case "$3" in 
						all)
							remote_fatroy_reset_conf $3
                            				#for sdn hg                        
                            				/usr/init_scripts/reset_factory.sh
						;;
						factory)
						  LocalRestore
              					  LocalLongRestore
							remote_fatroy_reset_conf $3
                            				#for sdn hg                        
                            				/usr/init_scripts/reset_factory.sh
							if [ -f /data/param.xml ]
							then							
								cp -rf /data/param.xml /flash/cfg/agentconf/param.xml
								sync
							fi
							reboot
						;;
						*)
						;; 
						esac						
                ;;
                
                # For the Default command usually not surpport.
                *)
                    echo "Command Not Surpport."
                ;; # end of *)
              
                
            esac
        ;; # end of factory_reset)   
        
        # For the Default Module, usually not surpport.
        *)
            echo "Module Not Surpport."
        ;; # end of *)
    esac
    
    sync
    return
}

# Check the arguments input by Usrs. And echo the help if Necessary.
if [ $# -lt 3 ]
then
   echo "#"
   echo "# Usage:"
   echo "#       Conftool Module_Name Command Configuration_Files"
   echo "#"
   echo "# Conftool,                [Conftool|XXXXX], name of the tool that your bin as."
   echo "# Module_Name,             [agent|dhcpc|dhcpd|factory_reset......], Name of the Module to exec the command."
   echo "# Command,                 [confbak|confcheck|local_reset|remote_reset], confbak/confcheck files of the moudle."
   echo "#                          local_reset|remote_reset for factory reset only"
   echo "# Configuration_Files,     [all|file name|factory], all for all files of the module to exec the command. otherwise the file defined only."   
   echo "#                          factory for remote_reset to init status"
   echo "#                          if command for factory reset, all for the files please."
   echo "#"
   
else
    # Get the functions to do
    main $1 $2 $3
fi

