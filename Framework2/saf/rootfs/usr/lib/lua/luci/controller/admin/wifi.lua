-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>

-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.wifi", package.seeall)

function index()
	entry({"admin", "wifi"}, alias("admin", "wifi", "base"), nil, 60).index = true
	
	entry({"admin", "wifi", "base"},
		template("admin_wifi/main_wifi_base"),
		nil, 10).leaf = true

	entry({"admin", "wifi", "base_settings"},
		call("get_base_settings")).leaf = true
		
	entry({"admin", "wifi", "wifiBasic"},
		post("set_base_settings")).leaf = true					
		
	entry({"admin", "wifi", "advance"},
		template("admin_wifi/main_wifi_advance"),
		nil, 20).leaf = true

	entry({"admin", "wifi", "adv_settings"},
		call("get_adv_settings")).leaf = true

	entry({"admin", "wifi", "wifiAdv"},
		post("set_adv_settings")).leaf = true			
end

function get_base_settings()
	local info = sgwconfig:get("wifiBasic")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)	
end

function set_base_settings()
	local tbl

	tbl = {wifi_onoff = luci.http.formvalue("wifi_onoff"),
		   wifi_dualBand = luci.http.formvalue("dualBand"),
		   wifi_2G_enbl = luci.http.formvalue("wifi_2G_switch"), 
	       wifi_2G_ssid = luci.http.formvalue("wifi_2G_SSID"),
	       wifi_2G_strength = luci.http.formvalue("wifi_2G_strength"),
	       wifi_2G_auth = luci.http.formvalue("wifi_2G_auth"), 
	       wifi_2G_passwd = luci.http.formvalue("wifi_2G_password"), 
	       wifi_5G_enbl = luci.http.formvalue("wifi_5G_switch"), 
	       wifi_5G_ssid = luci.http.formvalue("wifi_5G_SSID"),
	       wifi_5G_strength = luci.http.formvalue("wifi_5G_strength"),
	       wifi_5G_auth = luci.http.formvalue("wifi_5G_auth"), 
	       wifi_5G_passwd = luci.http.formvalue("wifi_5G_password")}

	sgwconfig:set("wifiBasic", tbl)
	luci.http.redirect(luci.dispatcher.build_url("admin/wifi/base"))
end

function get_adv_settings()
	local info = sgwconfig:get("wifiAdv")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)	
end

function set_adv_settings()
	local tbl
	tbl = {wifi_timing = luci.http.formvalue("wifi_timing_switch"), 
	       start_time = luci.http.formvalue("wifi_start_time"), 
	       end_time = luci.http.formvalue("wifi_end_time")}

	sgwconfig:set("wifiAdv", tbl)
	luci.http.redirect(luci.dispatcher.build_url("admin/wifi/advance"))
end
