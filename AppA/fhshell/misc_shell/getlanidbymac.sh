#!/bin/sh
rm /var/getlanidbymac.conf 2>/dev/null 
. /etc/net_interface.conf
if [ $# != "1" ]; then
    #echo "Input parameter fault" >> /var/getlanidbymac.log
    echo INTERFACEID=-1 > /var/getlanidbymac.conf
    #/usr/bin/setcfgx /var/getlanidbymac.conf INTERFACEID -1
    exit 0
fi
MAC=$1

brctl showmacs br0 > /var/getlanidbymac.temp
while read line; do
  MAC_TEMP=`echo $line | awk '{print $2}'`
  if [ "$MAC_TEMP" == "$MAC" ]; then
     NUM=`echo $line | awk '{print $1}'`
     IS_MAC_FOUND=1
     break
  fi
done < /var/getlanidbymac.temp

if [ "$IS_MAC_FOUND" == "1" ]; then
    brctl showstp br0 | grep "${LAN1_INTERFACE:0:$((${#LAN1_INTERFACE}-1))}\|${SSID1_INTERFACE:0:$((${#SSID1_INTERFACE}-1))}" > /var/getlanidbymac1.temp
    COUNT=-1                                             
    while read line; do
       COUNT=`echo $line | awk '{print $2}'`
       if [ "$COUNT" == "(${NUM})" ]; then
           INTERFACE=`echo $line | awk '{print $1}'`
           break                        
       fi                      
    done < /var/getlanidbymac1.temp                    
else                                              
    #echo "MAC not found" >> /var/getlanidbymac.log  
    #/usr/bin/setcfgx /var/getlanidbymac.conf INTERFACEID -1    
    echo INTERFACEID=-1 > /var/getlanidbymac.conf
    exit 0                                        
fi                     

if [ "$INTERFACE" != "" ]; then                         
    case $INTERFACE in                                  
        $LAN1_INTERFACE)                                         
        OUTPUT=1                                        
        ;;                                              
        $LAN2_INTERFACE)                                         
        OUTPUT=2                                        
        ;;                                              
        $LAN3_INTERFACE)                                     
        OUTPUT=3                                        
        ;;                                              
        $LAN4_INTERFACE)                                         
        OUTPUT=4                                        
        ;;                                              
        $SSID1_INTERFACE)                                          
        OUTPUT=5                                        
        ;;                                              
        $SSID2_INTERFACE)                                          
        OUTPUT=6                                        
        ;;                                              
        $SSID3_INTERFACE)      
        OUTPUT=7                                        
        ;;                                              
        $SSID4_INTERFACE)                                          
        OUTPUT=8                                        
        ;;                                              
        *)                                          
        break                                           
        ;;                                              
    esac                                                
else                                                    
    #echo "Interface not found" >> /var/getlanidbymac.log
    #/usr/bin/setcfgx /var/getlanidbymac.conf INTERFACEID -1
    echo INTERFACEID=-1 > /var/getlanidbymac.conf
    exit 0
fi                                                      
 

                                                       
if [ "$OUTPUT" != "" ]; then
    #/usr/bin/setcfgx /var/getlanidbymac.conf INTERFACEID ${OUTPUT}
    echo INTERFACEID=${OUTPUT} > /var/getlanidbymac.conf
else
   #echo "interface not found" >> /var/getlanidbymac.log
    echo INTERFACEID=-1 > /var/getlanidbymac.conf
   #/usr/bin/setcfgx /var/getlanidbymac.conf INTERFACEID -1
fi            


 