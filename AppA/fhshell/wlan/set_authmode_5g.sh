#!/bin/sh
#set_authmode.sh [auth_mode] [index] [SSID_name] [passphrase]
APCFG=/var/wlan/apcfg_5
echo "$0 $1 $2 $3 $4"

INDEX=`expr $2 - 1`
ENABLE=ENABLE_${INDEX}
#ESSID=ESSID_${INDEX}
#AUTHMODE=AUTHMODE_${INDEX}
#ENCRYPTYPE=ENCRYPTYPE_${INDEX}
#wpa_passphrase=wpa_passphrase_${INDEX}

SSIDIndex=$2

OrgESSIDParam=`getcfgx ${APCFG} SSID`
OrgAuthModeParam=`getcfgx ${APCFG} AuthMode`
OrgEncryTypeParam=`getcfgx ${APCFG} EncrypType`
OrgWPAPassPhraseParam=`getcfgx ${APCFG} WPAPSK`

# echo "OrgESSIDParam is $OrgESSIDParam"
# echo "OrgAuthModeParam is $OrgAuthModeParam"
# echo "OrgEncryTypeParam is $OrgEncryTypeParam"
# echo "OrgWPAPassPhraseParam is $OrgWPAPassPhraseParam"

NewESSIDParam=""
NewAuthModeParam=""
NewEncryTypeParam=""
NewWPAPassPhraseParam=""

SignalAuthParam=""
SignalEncrypTypeParam=""

len=`echo ${#4}`

if [ "$1" = "wpa" ];then
	if [ $len -lt 8  ]; then
		echo "Password length should not be less than 8 characters"
		exit 1
	fi
	SignalAuthParam="WPAPSK"
	SignalEncrypTypeParam="AES"
elif [ "$1" = "wpa2" ]; then
	if [ $len -lt 8  ]; then
		echo "Password length should not be less than 8 characters"
		exit 1
	fi
	SignalAuthParam="WPA2PSK"
	SignalEncrypTypeParam="AES"
elif [ "$1" = "open" ]; then
	SignalAuthParam="OPEN"
	SignalEncrypTypeParam="NONE"
else
	echo "Usage:\t/rom/fhshell/wlan/set_authmode.sh [wpa] [index] [SSID_name] [passphrase]"
	echo "\t/rom/fhshell/wlan/set_authmode.sh [wpa2] [index] [SSID_name] [passphrase]"
	echo "\t/rom/fhshell/wlan/set_authmode.sh [open] [index] [SSID_name]"
fi

#echo "SignalAuthParam is $SignalAuthParam"
#echo "SignalEncrypTypeParam is $SignalEncrypTypeParam"

#generate ESSID Param
for i in 1 2 3 4
do

if [ "$i" != "$SSIDIndex" ];then
        TEMP=`echo "$OrgESSIDParam" | cut -d ';' -f "$i"`
else
        TEMP="$3"
fi
        NewESSIDParam="$NewESSIDParam""$TEMP"";"
done
NewESSIDParam=${NewESSIDParam%;}

#generate WPAPassPhrase Param
for i in 1 2 3 4
do

if [ "$i" != "$SSIDIndex" ];then
        TEMP=`echo "$OrgWPAPassPhraseParam" | cut -d ';' -f "$i"`
else
        TEMP="$4"
fi
        NewWPAPassPhraseParam="$NewWPAPassPhraseParam""$TEMP"";"
done
NewWPAPassPhraseParam=${NewWPAPassPhraseParam%;}

#generate AuthMode Param
for i in 1 2 3 4
do
if [ "$i" != "$SSIDIndex" ];then
        TEMP=`echo "$OrgAuthModeParam" | cut -d ';' -f "$i"`
else
        TEMP="$SignalAuthParam"
fi
        NewAuthModeParam="$NewAuthModeParam""$TEMP"";"
done
NewAuthModeParam=${NewAuthModeParam%;}

#generate EncrypType Param
for i in 1 2 3 4
do
if [ "$i" != "$SSIDIndex" ];then
        TEMP=`echo "$OrgEncryTypeParam" | cut -d ';' -f "$i"`
else
        TEMP="$SignalEncrypTypeParam"
fi
        NewEncryTypeParam="$NewEncryTypeParam""$TEMP"";"
done
NewEncryTypeParam=${NewEncryTypeParam%;}

setcfgx ${APCFG} ${ENABLE} 1

setcfgx ${APCFG} AuthMode "$NewAuthModeParam"
setcfgx ${APCFG} EncrypType "$NewEncryTypeParam"

if [ "$3" != "" ];then
	echo "Change SSID1 "
	setcfgx ${APCFG} SSID "$NewESSIDParam"
fi


if [ "$4" != "" ];then
	echo "Change SSID1 Password"
	setcfgx ${APCFG} WPAPSK "$NewWPAPassPhraseParam"
fi


# echo "NewESSIDParam is $NewESSIDParam"
# echo "NewAuthModeParam is $NewAuthModeParam"
# echo "NewEncryTypeParam is $NewEncryTypeParam"
# echo "NewWPAPassPhraseParam is $NewWPAPassPhraseParam"

exit 0




# len=`echo ${#4}`
# 
# if [ "$1" = "wpa" ]; then
# 	if [ $len -lt 8  ]; then
		# echo "Password length should not be less than 8 characters"
		# exit 1
	# fi
	# setcfgx ${APCFG} ${ENABLE} 1
	# setcfgx ${APCFG} ${ESSID} $3
	# setcfgx ${APCFG} ${AUTHMODE} wpa
	# setcfgx ${APCFG} ${ENCRYPTYPE} aes
	# setcfgx ${APCFG} ${wpa_passphrase} $4
# elif [ "$1" = "wpa2" ]; then
	# if [ $len -lt 8  ]; then
		# echo "Password length should not be less than 8 characters"
		# exit 1
	# fi
	# setcfgx ${APCFG} ${ENABLE} 1
	# setcfgx ${APCFG} ${ESSID} $3
	# setcfgx ${APCFG} ${AUTHMODE} wpa2
	# setcfgx ${APCFG} ${ENCRYPTYPE} aes
	# setcfgx ${APCFG} ${wpa_passphrase} $4
# elif [ "$1" = "open" ]; then
	# setcfgx ${APCFG} ${ENABLE} 1
	# setcfgx ${APCFG} ${ESSID} $3
	# setcfgx ${APCFG} ${AUTHMODE} open
	# setcfgx ${APCFG} ${ENCRYPTYPE} none
# else
	# echo "Usage:\t/rom/fhshell/wlan/set_authmode.sh [wpa] [index] [SSID_name] [passphrase]"
	# echo "\t/rom/fhshell/wlan/set_authmode.sh [wpa2] [index] [SSID_name] [passphrase]"
	# echo "\t/rom/fhshell/wlan/set_authmode.sh [open] [index] [SSID_name]"
# fi

# exit 0
