#!/bin/sh

if [ $# != 1 ]
then
	echo "param num error,usage: preconfig_check area"
	exit
fi

if [ -f /usr/local/fh/mf/factory_mode ]
then
	echo "please not in the factory mode！"
	exit
fi

COMMON_CONF=/etc/fh_common.conf
GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2`
VOICE_CONF=`grep "MISC_CONF_PATH_VOICE_FACTORY=" $COMMON_CONF | cut -d = -f 2`
DATA_CONF=`grep "PRODUCT_CONF_PATH_FACTORY=" $COMMON_CONF | cut -d = -f 2`
DIGITMAP_CONF=/data/digitmap
ZFILE=/var/precfg_tmp
ZFILE2=/var/tmp_check_result

AREA_CODE=$1
preconfig_voice_conf=/flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_voice.conf
preconfig_data_conf=/flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_data.conf
preconfig_digitmap_conf=/flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_digitmap.conf

if [ -f $ZFILE ]; then
	rm -rf $ZFILE
fi

if [ -f $ZFILE2 ]; then
	rm -rf $ZFILE2
fi
#输出设备基本信息
####
BROANCONF="/var/WEB-GUI/webgui.conf"
TR069_CONF=`grep "PRODUCT_CONF_PATH_TR069_CONTROL=" $COMMON_CONF | cut -d = -f 2 `
gareacode=`$GETCFG ${TR069_CONF} area_code`
if [ "$AREA_CODE" != "$gareacode" ]; then
	echo "preconfig check nok,地区码错误!" 
	echo "preconfig check nok,地区码错误!" >> $ZFILE
	exit	
fi

ProvName=`echo "$gareacode" | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`
if [ "$ProvName" == "SHAN_XI" ]; then
        ProvName="SHAANXI"
fi

#PONMODE=`$GETCFG ${BROANCONF} PONMODE` #for sdn hg,201706
PONMODE=`$GETCFG ${DATA_CONF} pon_flag`
#wireless_enable=`$GETCFG ${BROANCONF} wireless_enable` #for sdn hg,201706   
wireless_enable=1
echo "------------------------------------------------------------" >> $ZFILE
echo "地区是$ProvName" >> $ZFILE
#DTYPE=`$GETCFG $BROANCONF DeviceType` #for sdn hg,201706
DTYPE=`$GETCFG $DATA_CONF Model`
echo "设备类型是$DTYPE" >> $ZFILE
WANMAC=`$GETCFG $DATA_CONF internetmac`
echo "WAN MAC是$WANMAC" >> $ZFILE
GPONSN=`$GETCFG $DATA_CONF GponSN`
ONUMAC=`$GETCFG $DATA_CONF PONMac`
if [ "$PONMODE" == "EPON" ];then
	echo "ONU MAC是$ONUMAC" >> $ZFILE
else
	echo "GPON SN是$GPONSN" >> $ZFILE
fi
MOUI=`$GETCFG $DATA_CONF ManufacturerOUI`
ITMSSN=`$GETCFG $DATA_CONF SerialNumber`
echo "设备标识是$MOUI-$ITMSSN" >> $ZFILE
if [ "$wireless_enable" == "1" ];then
	SSIDNAME=`$GETCFG $DATA_CONF SSID`
	echo "无线名称是$SSIDNAME" >> $ZFILE
	WIFIPWD=`$GETCFG $DATA_CONF PreSharedKey`
	echo "无线密钥是$WIFIPWD" >> $ZFILE
fi
USERPWD=`$GETCFG $DATA_CONF UserPasswd`
echo "用户密码是$USERPWD" >> $ZFILE
SOFTV=`$GETCFG $DATA_CONF SoftwareVersion`
echo "软件版本号是$SOFTV" >> $ZFILE
echo
echo >> $ZFILE
echo "------------------------------------------------------------" >> $ZFILE

COMPILETIME=`cat /rom/Appfs_compiledate.log | awk -F = '{print $2}'`
echo "编译时间是$COMPILETIME" >> $ZFILE
IMAGEID=`cat /rom/IMAGEID`
echo "镜像ID是$IMAGEID" >> $ZFILE

ExtNum=`$GETCFG $DATA_CONF ExtNumber`
echo "扩展版本号是$ExtNum" >> $ZFILE

if [ $# == 0 ]
then
if [ -f /usr/local/fh/mf/factory_mode ]
 then
	echo "设备处于工厂模式，请先退出工厂模式后重新检查预配置" > $ZFILE
exit
fi
fi

if [ -f /data/precf_id ]; then
	PreconfigID=`cat /data/precf_id`
else
	PreconfigID=
	echo "请先导入预配置" > $ZFILE
	exit
fi
echo "预配置ID是$PreconfigID" >> $ZFILE

echo
echo >> $ZFILE
echo "------------------------------------------------------------" >> $ZFILE
if [ -f /usr/local/fh/logined ]; then
        echo "有用户曾经登录WEB界面，建议恢复开箱状态后重新检查预配置" >> $ZFILE
fi
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $ZFILE

if [ 0 == 1 ]; then #for sdn hg,jzhchen 201706
#检查设备型号确定xml conf文件名称
for i in HG220G HG221G HG260G HG261G HG225G HG265G HG22xG HG26xG HG2x1G
do
	if [ -f /flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_${i}_xml.conf ]
	then
		preconfig_xml_conf=/flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_${i}_xml.conf
		break
	fi
done
if [ x"$preconfig_xml_conf" == x ]
then
	 preconfig_xml_conf=/flash/precfg/${AREA_CODE}/preconfig_required_${AREA_CODE}_xml.conf
fi
echo "preconfig_xml_conf=$preconfig_xml_conf"

XML_Err_Num=0
VOICE_Err_Num=0
DATA_Err_Num=0
Digitmap_Err_Num=0
TOTAL_Err_Num=0

Curr_Check_Num=0
Check_Sum=`cat $preconfig_xml_conf | wc -l`
WLAN_Enable=`getcfgx /var/WEB_GUI/webgui.conf wireless_enable`

if [ ! -f $preconfig_xml_conf ]; then
	echo "preconfig check nok,the xml conf file not exist"
	echo "preconfig check nok,the xml conf file not exist" >> $ZFILE
	exit
fi	
echo "XML preconfig check start\n"
. /var/WEB-GUI/hgcxml.conf
while read line
do
	#echo "$Curr_Check_Num:$line"
	wlan_flag=`echo $line | grep WLANC`
	if [ "x$wlan_flag" != "x" ]
	then
		Curr_Check_Num=`expr $Curr_Check_Num + 1`
		echo -en "\r XML $Curr_Check_Num/$Check_Sum check!"		
		if [ "x$WLAN_Enable"  = "x1" ]
		then
			#param_path=0
			param_value=0
			param_igd=0
			curr_param_value=0
			param_igd=`echo $line | awk -F '=' '{print $1}'`
			param_value=`echo $line | awk -F '=' '{print $2}'`
			eval param_num=$(echo \$$param_igd)
			curr_param_value=`inter_web get $param_num | awk -F '&' '{print $1}'`
			if [ "x${param_value}" != "x${curr_param_value}" ]
			then
				XML_Err_Num=`expr $XML_Err_Num + 1`
				echo -e "$param_igd 不一致,预配置要求为$param_value,当前配置值为$curr_param_value" >> $ZFILE				
			else
				echo -e "$param_igd 校验成功,值为$curr_param_value" >> $ZFILE2				
			fi
		fi
	else
		#param_path=0
		param_value=0
		param_igd=0
		curr_param_value=0
		Curr_Check_Num=`expr $Curr_Check_Num + 1`	
		echo -en "\r XML $Curr_Check_Num/$Check_Sum check!"
		param_igd=`echo $line | awk -F '=' '{print $1}'`
		param_value=`echo $line | awk -F '=' '{print $2}'`
		eval param_num=$(echo \$$param_igd)
		curr_param_value=`inter_web get $param_num | awk -F '&' '{print $1}'`
		if [ "x${param_value}" != "x${curr_param_value}" ]
		then
			XML_Err_Num=`expr $XML_Err_Num + 1`
			echo -e "$param_igd 不一致,预配置要求为$param_value,当前配置值为$curr_param_value" >> $ZFILE
		else
			echo -e "$param_igd 校验成功,值为$curr_param_value" >> $ZFILE2
		fi	
	fi
done < $preconfig_xml_conf
echo -e "XML CHECK FINISH,$XML_Err_Num different!\n" >> $ZFILE

if [ ! -f $preconfig_voice_conf ]; then
	echo "preconfig check nok,the voice conf file not exist"
	echo "preconfig check nok,the voice conf file not exist" >> $ZFILE
	exit
fi	
Curr_Check_Num=0
Check_Sum=`cat $preconfig_voice_conf | wc -l`
echo "VOICE配置检查开始\n"
while read line
do
	voice_key=0
	voice_value=0
	curr_voice_value=0
	Curr_Check_Num=`expr $Curr_Check_Num + 1`
	echo -en "\r VOICE $Curr_Check_Num/$Check_Sum check!"
	voice_key=`echo $line | awk -F '=' '{print $1}'`
	voice_value=`echo $line | awk -F '=' '{print $2}'`
	curr_voice_value=`$GETCFG $VOICE_CONF $voice_key`
	if [ "x$voice_value" != "x$curr_voice_value" ]
	then
		VOICE_Err_Num=`expr $VOICE_Err_Num + 1`
		echo -e "$voice_key 不一致,预配置要求为$voice_value,当前配置值为$curr_voice_value" >> $ZFILE
	else
		echo -e "$voice_key 校验成功,值为$curr_voice_value" >> $ZFILE2
	fi	
done < $preconfig_voice_conf
echo -e "VOICE CHECK FINISH,$VOICE_Err_Num different!\n" >> $ZFILE

if [ ! -f $preconfig_data_conf ]; then
	echo "preconfig check nok,the data conf file not exist"
	echo "preconfig check nok,the data conf file not exist" >> $ZFILE
	exit
fi
Curr_Check_Num=0
Check_Sum=`cat $preconfig_data_conf | wc -l`
echo "DATA preconfig check start"
while read line
do
	ssid_flag=`echo $line | grep SSID`
	if [ "x$ssid_flag" != "x" ]
	then
		Curr_Check_Num=`expr $Curr_Check_Num + 1`	
		echo -en "\r DATA $Curr_Check_Num/$Check_Sum Check!"
	    if [ "x$WLAN_Enable"  = "x1" ]
		then
			data_key=0
			data_value=0
			curr_data_value=0
			data_key=`echo $line | awk -F '=' '{print $1}'`
			data_value=`echo $line | awk -F '=' '{print $2}'`
			curr_data_value=`$GETCFG $DATA_CONF $data_key`
			if [ "x$data_value" != "x$curr_data_value" ]
			then
			DATA_Err_Num=`expr $DATA_Err_Num + 1`
			echo -e "$data_key 不一致,预配置要求为$data_value,当前配置值为$curr_data_value" >> $ZFILE
			else
			echo -e "$data_key 校验成功,值为$curr_data_value" >> $ZFILE2
			fi
		fi
	else
		data_key=0
		data_value=0
		curr_data_value=0
		Curr_Check_Num=`expr $Curr_Check_Num + 1`	
		echo -en "\r DATA $Curr_Check_Num/$Check_Sum Check!"
		data_key=`echo $line | awk -F '=' '{print $1}'`
		data_value=`echo $line | awk -F '=' '{print $2}'`
		curr_data_value=`$GETCFG $DATA_CONF $data_key`
		if [ "x$data_value" != "x$curr_data_value" ]
		then
			DATA_Err_Num=`expr $DATA_Err_Num + 1`
			echo -e "$data_key 不一致,预配置要求为$data_value,当前配置值为$curr_data_value" >> $ZFILE
		else
			echo -e "$data_key 校验成功,值为$curr_data_value" >> $ZFILE2
		fi
	fi
done < $preconfig_data_conf
echo -e "DATA CHECK FINISH,$DATA_Err_Num different!\n" >> $ZFILE

if [ ! -f $preconfig_digitmap_conf ]; then
	echo "preconfig check nok,the digitmap conf file not exist"
	echo "preconfig check nok,the digitmap conf file not exist" >> $ZFILE
	exit
fi
Curr_Check_Num=0
Check_Sum=`cat $preconfig_digitmap_conf | wc -l`
echo "Digitmap preconfig check start! "
while read line
do
	digit_key=0
	digit_value=0
	curr_digit_value=0
	Curr_Check_Num=`expr $Curr_Check_Num + 1`	
	echo -en "\r Digitmap $Curr_Check_Num/$Check_Sum Check!"
	digit_key=`echo $line | awk -F '=' '{print $1}'`
	digit_value=`echo $line | awk -F '=' '{print $2}'`
	curr_digit_value=`$GETCFG $DIGITMAP_CONF $digit_key`
		if [ "x$digit_value" != "x$curr_digit_value" ]
		then
			Digitmap_Err_Num=`expr $Digitmap_Err_Num + 1`
			echo -e "$digit_key 不一致,预配置要求为$digit_value,当前配置值为$curr_digit_value" >> $ZFILE
		else
			echo -e "$digit_key 校验成功,值为$curr_digit_value" >> $ZFILE2
		fi
	done < $preconfig_digitmap_conf
echo -e "Digitmap CHECK FINISH,$DATA_Err_Num different!\n" >> $ZFILE

TOTAL_Err_Num=`expr $XML_Err_Num + $VOICE_Err_Num + $DATA_Err_Num + $Digitmap_Err_Num`
if [ $TOTAL_Err_Num -eq 0 ]
then
	echo "preconfig check ok!" >> $ZFILE
	echo "------------------------------------------------------------" >> $ZFILE
	cat $ZFILE2 >> $ZFILE
else
	echo "preconfig check nok,$TOTAL_Err_Num different!" >> $ZFILE
fi

fi #for sdn hg,jzhchen 201706
echo "check finished,see /var/precfg_tmp" 
