#!/bin/sh
killall internet_led_ctrl_itmsV4
while true
do
	for led in pon los wlan voip1 voip2 wps usb sim internet sim_conf power_led
		do
		led_ctrl set $led on
		done
	sleep 1
	for led in pon los wlan voip1 voip2 wps usb sim internet sim_conf power_led
		do
		led_ctrl set $led off
		done
	sleep 1
done