#!/bin/sh
#set_authmode.sh [auth_mode] [index] 
APCFG=/var/wlan/apcfg

echo "$0 $1 $2"

INDEX=`expr $2 - 1`
ENABLE=ENABLE_${INDEX}
SSIDIndex=$2

OrgAuthModeParam=`getcfgx ${APCFG} AuthMode`
OrgEncryTypeParam=`getcfgx ${APCFG} EncrypType`

NewAuthModeParam=""
NewEncryTypeParam=""

SignalAuthParam="OPEN"
SignalEncrypTypeParam="NONE"

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

