#!/bin/sh

#only for high-power to low-power, low-power to high-power can not use this script

RT30xxEEPROM_HIGH=/data/RT30xxEEPROM_HIGH.bin

if [ -f ${RT30xxEEPROM_HIGH} ]; then
	echo "${RT30xxEEPROM_HIGH} is exist!"
	exit 1
fi

mount -o remount,rw /data

cp -f /data/RT30xxEEPROM.bin /data/RT30xxEEPROM_HIGH.bin
cp -f /data/RT30xxEEPROM_5.bin /data/RT30xxEEPROM_5_HIGH.bin

iwpriv ra0 e2p A0=C2 
iwpriv ra0 e2p A1=C2 
iwpriv ra0 e2p A2=C2 
iwpriv ra0 e2p A3=C2 
iwpriv ra0 e2p A4=C2 
iwpriv ra0 e2p A5=C2 
iwpriv ra0 e2p A6=00 
iwpriv ra0 e2p A7=C2 
iwpriv ra0 e2p A8=00 
iwpriv ra0 e2p A9=C2 
iwpriv ra0 e2p AA=C2 
iwpriv ra0 e2p AB=C1 
iwpriv ra0 e2p AC=00 
iwpriv ra0 e2p AD=81
iwpriv ra0 set efuseBufferModeWriteBack=1
cp -f /data/RT30xxEEPROM.bin /data/RT30xxEEPROM_LOW.bin

iwpriv rai0 e2p A6=00
iwpriv rai0 e2p A7=00
iwpriv rai0 e2p A8=00
iwpriv rai0 e2p A9=00
iwpriv rai0 e2p AA=00
iwpriv rai0 e2p AB=00
iwpriv rai0 e2p AC=00
iwpriv rai0 e2p AD=00
iwpriv rai0 e2p B2=00
iwpriv rai0 e2p B3=00
iwpriv rai0 e2p B4=00
iwpriv rai0 e2p B5=00
iwpriv rai0 e2p BE=82
iwpriv rai0 set efuseBufferModeWriteBack=1
cp -f /data/RT30xxEEPROM_5.bin /data/RT30xxEEPROM_5_LOW.bin

mount -r -o remount /data

