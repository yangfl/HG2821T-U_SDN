-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>

-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.settings", package.seeall)

function index()
	entry({"admin", "settings"}, alias("admin", "settings", "status"), nil, 80).index = true
	
	entry({"admin", "settings", "status"},
		template("admin_settings/main_gateway_status"),
		nil, 10).leaf = true
		
	entry({"admin", "settings", "gwstatus"}, call("get_gwstatus")).leaf = true	
		
	entry({"admin", "settings", "info"},
		template("admin_settings/main_gateway_info"),
		nil, 20).leaf = true

	entry({"admin", "settings", "gwinfo"}, call("get_gwinfo")).leaf = true		
		
	entry({"admin", "settings", "lan"},
		template("admin_settings/main_network_lan"),
		nil, 40).leaf = true
		
	entry({"admin", "settings", "lanInfo"}, call("get_lan_settings")).leaf = true	
	
	entry({"admin", "settings", "lanSettings"}, post("set_lan_settings")).leaf = true	
		
	entry({"admin", "settings", "portmap_config"},
		template("admin_settings/main_portmap_config"),
		nil, 50).leaf = true
		
	entry({"admin", "settings", "portmap_list"},
		template("admin_settings/main_portmap_list"),
		nil, 60).leaf = true

	entry({"admin", "settings", "pmDisplay"}, call("get_pm_lists")).leaf = true
	
	entry({"admin", "settings", "pmSetSingle"}, post("set_single_pm")).leaf = true
	
	entry({"admin", "settings", "pmSetAll"}, post("set_all_pm")).leaf = true
		
	entry({"admin", "settings", "user"},
		template("admin_settings/main_user"),
		nil, 70).leaf = true
		
	entry({"admin", "settings", "change_passwd"}, post("change_passwd")).leaf = true
		
	entry({"admin", "settings", "restore"},
		template("admin_settings/main_restore"),
		nil, 80).leaf = true	

	entry({"admin", "settings", "setLoid"}, call("set_loid")).leaf = true 

	entry({"admin", "settings", "registerLoid"}, call("register_loid")).leaf = true 

	entry({"admin", "settings", "regProcess"}, call("reg_process")).leaf = true
	
	entry({"admin", "settings", "doRestore"}, post("do_restore")).leaf = true											
end

function get_gwstatus()
	local info = sgwconfig:get("gwStatus")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function get_gwinfo()
	local info = sgwconfig:get("gwInfo", luci.http.formvalue("get"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function change_passwd()
	local tbl
	
	tbl = {old = luci.http.formvalue("old"), 
	       new = luci.http.formvalue("newPasswd")}

	local ret = sgwconfig:set("account", tbl)

	luci.http.prepare_content("application/json")
	local rv = {message=ret}
	luci.http.write_json(rv)		    
end

function get_lan_settings()
	local info = sgwconfig:get("lan")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function set_lan_settings()
	local tbl
	
	tbl = {oldLanIp = luci.http.formvalue("oldLanIp"),
		   lanIp = luci.http.formvalue("lanIp"), 
	       dhcpEnbl = luci.http.formvalue("dhcpEnbl"),
	       poolStart = luci.http.formvalue("poolStart"),
	       poolEnd = luci.http.formvalue("poolEnd"),
	       subnetMask = luci.http.formvalue("subnetMask"),
	       }

	local ret = sgwconfig:set("lan", tbl)
	if ret ~= 2 then
		luci.http.prepare_content("application/json")
		local rv = {message=ret}
		luci.http.write_json(rv)	
	else
		os.execute("/etc/init.d/uhttpd restart >/dev/null 2>&1")
	end
end

function get_pm_lists()
	local info = sgwconfig:get("pmLists")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function set_single_pm()
	local tbl
	if (luci.http.formvalue("op") ~= "add") then
		tbl = {op = luci.http.formvalue("op"), desp = luci.http.formvalue("srvname")}
	else
		tbl = {op = "add", desp = luci.http.formvalue("srvname"), 
		       client = luci.http.formvalue("client"), 
		       protocol = luci.http.formvalue("protocol"), 
		       exPort = luci.http.formvalue("exPort"), 
		       inPort = luci.http.formvalue("inPort")}
	end
	local ret = sgwconfig:set("pmSetSingle", tbl)
	
	luci.http.prepare_content("application/json")
	local rv = {retVal=ret}
	luci.http.write_json(rv)
end

function set_all_pm()
	local tbl = {op = luci.http.formvalue("op")}
	sgwconfig:set("pmSetAll", tbl)
end

function do_restore()
  local ret = sgwconfig:set("restore")
  
	luci.http.prepare_content("application/json")
	local rv = {retVal=ret}
	luci.http.write_json(rv)  
end

function set_loid()	
 	local tbl
	tbl = {
			loid = luci.http.formvalue("loidvalue"), 
			loidPsd = luci.http.formvalue("loidpassword"),	
			wifiSsid = luci.http.formvalue("wifissid"), 
			wifiPsd = luci.http.formvalue("wifipassword")			
		   }
	ret = sgwconfig:set("setloid", tbl);
	local rv = {retVal=ret}
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function register_loid()
  	local ret = sgwconfig:set("registerloid")
  
	luci.http.prepare_content("application/json")
	local rv = {retVal=ret}
	luci.http.write_json(rv)  
end

function reg_process()
  	local info = sgwconfig:get("regProcess")

	luci.http.write(info)
end
