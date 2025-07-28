COMMON_CONF=/etc/fh_common.conf
Province=`grep "area_code=" /data/tr069_control.conf | cut -d = -f 2 `
Carrier=`grep "Carrier=" $COMMON_CONF | cut -d = -f 2 `               
#echo "$Province $Carrier"                                             
Province=$Province                                     
Carrier=$Carrier         
export Province                 
export Carrier                  
echo $Province > /proc/fh_ver_info/Province
echo $Carrier > /proc/fh_ver_info/carrier  
