-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>

-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.device", package.seeall)

function index()
	entry({"admin", "device"}, alias("admin", "device", "pc"), nil, 50).index = true
	
	entry({"admin", "device", "pc"},
		template("admin_device/main_device_pc"),
		nil, 10).leaf = true
		
	entry({"admin", "device", "wifi"},
		template("admin_device/main_device_wifi"),
		nil, 20).leaf = true
		
	entry({"admin", "device", "devInfo"}, call("get_devInfo")).leaf = true
		
	entry({"admin", "device", "hostSettings"}, post("set_lan_host")).leaf = true

	entry({"admin", "device", "itv"},
		template("admin_device/main_device_itv"),
		nil, 30).leaf = true	

	entry({"admin", "device", "phone"},
		template("admin_device/main_device_phone"),
		nil, 40).leaf = true
		
	entry({"admin", "device", "itvVoipReg"}, call("get_itv_voip_reg")).leaf = true

	entry({"admin", "device", "black"},
		template("admin_device/main_device_blacklist"),
		nil, 50).leaf = true

	entry({"admin", "device", "blackHosts"}, call("get_black_hosts")).leaf = true

	entry({"admin", "device", "rmBlackHost"}, call("remove_black_host")).leaf = true	
end

function get_devInfo()
	local info = sgwconfig:get("hostsInfo", luci.http.formvalue("type"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function get_itv_voip_reg()
	local info = sgwconfig:get("itvVoipReg")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function get_black_hosts()
	local info = sgwconfig:get("blackHosts")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function set_lan_host()
	local tbl
	local op = luci.http.formvalue("type")
	if (op == "black") then
		tbl = {type = "black",
		       mac = luci.http.formvalue("mac")}
	else
		tbl = {type = "restrict",
		       mac = luci.http.formvalue("mac"),
		       onOff = luci.http.formvalue("onOff")}		
	end

	local ret = sgwconfig:set("hostSettings", tbl)
	
	luci.http.prepare_content("application/json")
	local rv = {setRes=ret}
	luci.http.write_json(rv)
end

function remove_black_host()
	local tbl = {mac = luci.http.formvalue("mac")}
	local ret = sgwconfig:set("rmBlackHost", tbl)
	
	luci.http.prepare_content("application/json")
	local rv = {setRes=ret}
	luci.http.write_json(rv)	
end
