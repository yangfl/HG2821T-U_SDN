#!/bin/sh
#set_calibration.sh wlan0

#path of iwpriv
COMMON_CONF=/etc/fh_common.conf
WLAN_BIN=`grep "APP_PATH_WLAN" $COMMON_CONF | cut -d = -f 2`
IWPRIV_CMD=$WLAN_BIN/iwpriv

#path of wlan log
DEBUG_LOG=/var/wlan/log

IWPRIV () {
	echo "$IWPRIV_CMD $@" >> $DEBUG_LOG
	$IWPRIV_CMD "$@"
}

CONFIG_DIR=/data/calibration/wlan0

if [ ! -e $CONFIG_DIR ]; then
	echo "not found $CONFIG_DIR"
	exit 1
fi

if [ -f $CONFIG_DIR/11n_ther ]; then
	POWER_THER=`cat $CONFIG_DIR/11n_ther`
	if [ "$POWER_THER" != "" ]; then
		IWPRIV $1 set_mib ther=$POWER_THER
	fi
fi

if [ -f $CONFIG_DIR/reg_domain ]; then
	POWER_REG_DOMAIN=`cat $CONFIG_DIR/reg_domain`
	if [ "$POWER_REG_DOMAIN" != "" ]; then
		IWPRIV $1 set_mib regdomain=$POWER_REG_DOMAIN
	fi
fi

if [ -f $CONFIG_DIR/tx_power_cck_a ]; then
	POWER_CCK_A=`cat $CONFIG_DIR/tx_power_cck_a`
	if [ "$POWER_CCK_A" != "" ]; then
		IWPRIV $1 set_mib pwrlevelCCK_A=$POWER_CCK_A
	fi
fi

if [ -f $CONFIG_DIR/tx_power_cck_b ]; then
	POWER_CCK_B=`cat $CONFIG_DIR/tx_power_cck_b`
	if [ "$POWER_CCK_B" != "" ]; then
		IWPRIV $1 set_mib pwrlevelCCK_B=$POWER_CCK_B
	fi
fi

if [ -f $CONFIG_DIR/tx_power_ht40_1s_a ]; then
	POWER_HT40_1S_A=`cat $CONFIG_DIR/tx_power_ht40_1s_a`
	if [ "$POWER_HT40_1S_A" != "" ]; then
		IWPRIV $1 set_mib pwrlevelHT40_1S_A=$POWER_HT40_1S_A
	fi
fi

if [ -f $CONFIG_DIR/tx_power_ht40_1s_b ]; then
	POWER_HT40_1S_B=`cat $CONFIG_DIR/tx_power_ht40_1s_b`
	if [ "$POWER_HT40_1S_B" != "" ]; then
		IWPRIV $1 set_mib pwrlevelHT40_1S_B=$POWER_HT40_1S_B
	fi
fi

if [ -f $CONFIG_DIR/tx_power_diff_ht40_2s ]; then
	POWER_DIFF_HT40_2S=`cat $CONFIG_DIR/tx_power_diff_ht40_2s`
	if [ "$POWER_DIFF_HT40_2S" != "" ]; then
		IWPRIV $1 set_mib pwrdiffHT40_2S=$POWER_DIFF_HT40_2S
	fi
fi

if [ -f $CONFIG_DIR/tx_power_diff_ht20 ]; then
	POWER_DIFF_HT20=`cat $CONFIG_DIR/tx_power_diff_ht20`
	if [ "$POWER_DIFF_HT20" != "" ]; then
		IWPRIV $1 set_mib pwrdiffHT20=$POWER_DIFF_HT20
	fi
fi

if [ -f $CONFIG_DIR/tx_power_diff_ofdm ]; then
	POWER_DIFF_OFDM=`cat $CONFIG_DIR/tx_power_diff_ofdm`
	if [ "$POWER_DIFF_OFDM" != "" ]; then
		IWPRIV $1 set_mib pwrdiffOFDM=$POWER_DIFF_OFDM
	fi
fi

exit 0
