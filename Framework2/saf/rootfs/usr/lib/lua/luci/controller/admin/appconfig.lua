-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.appconfig", package.seeall)

function index()
	entry({"admin", "appconfig"}, alias("admin", "appconfig", "mall"), nil, 190).index = true
	
	entry({"admin", "appconfig", "mall"},
		template("admin_appconfig/main_app_mall"),
		nil, 10).leaf = true
		
	entry({"admin", "appconfig", "getMallUrl"}, call("get_mall_url")).leaf = true

	local sgwconfig = require "sgwconfig"
	local appconfig = sgwconfig:get("getAppConfig")
	for i = 1, appconfig.appCnt
	do 
	    local str = string.format("%d", i)
		entry({"admin", "appconfig", appconfig["app"..str].name},
			template("admin_appconfig/main_app_"..appconfig["app"..str].name),
			nil, 10 * (i + 1)).leaf = true		
	end
	
	entry({"admin", "appconfig", "getAppParas"}, call("get_app_paras")).leaf = true
	
	entry({"admin", "appconfig", "setAppParas"}, call("set_app_paras")).leaf = true
end

function get_mall_url()
	local info = sgwconfig:get("getMallUrl")

	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function sz_T2S(_t)  
    local szRet = "{"  
    function doT2S(_i, _v)  
        if "number" == type(_i) then  
            szRet = szRet .. "[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_T2S(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. '"' .. _i .. '" : '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. sz_T2S(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)
    szRet = szRet .. '"" : ""}'   
    return szRet  
end 

function get_app_paras()
	local info = sgwconfig:get("getAppParas", luci.http.formvalue("config"))
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(info)
end

function set_app_paras()
	sgwconfig:set("setAppParas", sz_T2S(luci.http.formvalue(nil)))
	
	luci.http.redirect(luci.dispatcher.build_url("admin/appconfig/"..luci.http.formvalue("config")))
end