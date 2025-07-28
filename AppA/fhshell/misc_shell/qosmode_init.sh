#!/bin/sh

#-----lqu modify 20120820
COMMON_CONF=/etc/fh_common.conf
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
QOSRatev4_CONF=`grep "MISC_CONF_PATH_QOSRATEV4=" $COMMON_CONF | cut -d = -f 2 `
APP_CONF_PATH=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `
IGD_XCTCOMUQS_Enable=`grep "IGD_XCTCOMUQS_Enable=" $APP_CONF_PATH | cut -d = -f 2 `
IGD_XCTCOMUQS_Plan=`grep "IGD_XCTCOMUQS_Plan=" $APP_CONF_PATH | cut -d = -f 2 `
IGD_XCTCOMUQS_Bandwidth=`grep "IGD_XCTCOMUQS_Bandwidth=" $APP_CONF_PATH | cut -d = -f 2 `
QOSCONF=$QOSRatev4_CONF
while :
do
	if [ -f /var/manager_finished ]; then
      QOSENABLE=`$FHBOX_PATH/inter_web get $IGD_XCTCOMUQS_Enable`
	  QOSPLAN=`$FHBOX_PATH/inter_web get $IGD_XCTCOMUQS_Plan`
      if [ "$QOSENABLE" == "1&" ]; then
         RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_XCTCOMUQS_Enable  1`
         if [ "$QOSPLAN" == "priority_band&" ]; then
			 rate1=`$GETCFG ${QOSCONF} QueueRate1`    
			 if  [ ! -n "$rate1" ]     
			 then
				rate1=0
			 fi
			 
			 rate2=`$GETCFG ${QOSCONF} QueueRate2`    
			 if  [ ! -n "$rate2" ]     
			 then
				rate2=0
			 fi
			 
			 rate3=`$GETCFG ${QOSCONF} QueueRate3`    
			 if  [ ! -n "$rate3"  ]     
			 then
				 rate3=0
			 fi
			 
			 rate4=`$GETCFG ${QOSCONF} QueueRate4`    
			 if  [ ! -n "$rate4" ]     
			 then
				 rate4=0
			 fi
			 
			 rate5=`$GETCFG ${QOSCONF} QueueRate5`    
			 if  [ ! -n "$rate5" ]     
			 then
				rate5=0
			 fi

			 rate6=`$GETCFG ${QOSCONF} QueueRate6`    
			 if  [ ! -n "$rate6" ]     
			 then
				 rate6=0
			 fi
			 
			 band=`$FHBOX_PATH/inter_web get $IGD_XCTCOMUQS_Bandwidth | cut -d "&" -f 1`
			 if  [ ! -n "$band" ]     
			 then
				 rate6=0
			 fi
			calltpm set  car  15 $band  $rate1 $rate2 $rate3 $rate4 $rate5 $rate6 > /dev/null
		fi
      fi  
      exit
	fi
	sleep 1
done

 