-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.index", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("admin")
		root.index = true
	end

	local page   = node("admin")
	page.target  = firstchild()
	page.title   = _("Administration")
	page.order   = 10
	page.sysauth = "useradmin"
	page.sysauth_authenticator = "htmlauth"
	page.ucidata = true
	page.index = true

	-- Empty services menu to be populated by addons
  entry({"admin", "main"}, template("main"), nil, 30).leaf = true
  entry({"admin", "getAppConfig"}, call("get_app_config")).leaf = true
  entry({"admin", "home"},template("main_home"),nil, 40).leaf = true
  entry({"admin", "regWifiSsid"}, call("get_wifi_ssid")).leaf = true
  entry({"admin", "allInfo"}, call("get_allInfo")).leaf = true	  
  entry({"admin", "help"}, template("main_help"), nil, 90).leaf = true
  entry({"admin", "download"}, template("main_appdownload"), nil, 100).leaf = true	
  entry({"admin", "reboot"}, post("reboot")).leaf = true
  
  entry({"admin", "logout"}, call("action_logout"), nil, 160)
end

function get_wifi_ssid()
	local info = sgwconfig:get("wifiSsid")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function get_allInfo()
	local info = sgwconfig:get("allInfo")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)	
end

function get_app_config()
	local info = sgwconfig:get("getAppConfig")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function reboot()
   sgwconfig:set("reboot")
end

function action_logout()
	local dsp = require "luci.dispatcher"
	local utl = require "luci.util"
	local sid = dsp.context.authsession

	if sid then
		utl.ubus("session", "destroy", { ubus_rpc_session = sid })

		luci.http.header("Set-Cookie", "sysauth=%s; expires=%s; path=%s/" %{
			sid, 'Thu, 01 Jan 1970 01:00:00 GMT', dsp.build_url()
		})

		local uci = uci.cursor()
		uci:set("luci", "ccache", "loginip", "0.0.0.0")
		uci:set("luci", "ccache", "logined", "0")
		uci:set("luci", "ccache", "loginsess", "0")
		uci:set("luci", "ccache", "lastaccesstime", "0")
		uci:save("luci")		
	end

end

