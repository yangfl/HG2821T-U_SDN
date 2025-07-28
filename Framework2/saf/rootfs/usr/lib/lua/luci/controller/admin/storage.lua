-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>

-- Licensed to the public under the Apache License 2.0.
module("luci.controller.admin.storage", package.seeall)

function index()
	entry({"admin", "storage"}, alias("admin", "storage", "status"), nil, 70).index = true
	
	entry({"admin", "storage", "status"},
		template("admin_storage/main_storage"),
		nil, 10).leaf = true
		
	entry({"admin", "storage", "getUsbDevs"}, call("get_devices_info")).leaf = true

	entry({"admin", "storage", "modifyUsbLabel"}, post("modify_usb_label")).leaf = true
		
	entry({"admin", "storage", "settings"},
		template("admin_storage/main_storage_settings"),
		nil, 20).leaf = true

	entry({"admin", "storage", "getFiles"}, call("get_file_lists")).leaf = true
	
	entry({"admin", "storage", "getSelectedUsb"}, call("get_selected_usb")).leaf = true

	entry({"admin", "storage", "openFolder"}, call("open_folder")).leaf = true

	entry({"admin", "storage", "newFolder"}, call("new_folder")).leaf = true

	entry({"admin", "storage", "deleteFiles"}, call("delete_files")).leaf = true

	entry({"admin", "storage", "rename"}, call("rename_file")).leaf = true

	entry({"admin", "storage", "getDiagFolders"}, call("get_diag_folders")).leaf = true  
	
 	entry({"admin", "storage", "copyMove"}, call("copy_move_files")).leaf = true

 	entry({"admin", "storage", "getProgress"}, call("copy_move_progress")).leaf = true

 	entry({"admin", "storage", "usbFormat"}, call("usb_dev_format")).leaf = true
end

function get_devices_info()
	local devs = sgwconfig:get("usbDevices")

	luci.http.prepare_content("application/json")
	luci.http.write_json(devs)
end

function modify_usb_label()
	local tbl = {instno = luci.http.formvalue("instno"),
				 newLabel = luci.http.formvalue("newLabel")}
				 
	local ret = sgwconfig:set("usbModifyLabel", tbl)
	
	luci.http.prepare_content("application/json")
	local rv = {setRes=ret}
	luci.http.write_json(rv)
end

function get_file_lists()
	local files = sgwconfig:get("fileLists", luci.http.formvalue("usbdev"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function get_selected_usb()
	local files = sgwconfig:get("selectedUsb", luci.http.formvalue("usbdev"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function open_folder()
	local files = sgwconfig:get("subFiles", luci.http.formvalue("path"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function new_folder()
	local files = sgwconfig:get("newFolder", luci.http.formvalue("path"), luci.http.formvalue("diag"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function delete_files()
	local files = sgwconfig:get("deleteFiles", luci.http.formvalue("path"), luci.http.formvalue("fileLists"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function rename_file()
	local files = sgwconfig:get("renameFile", luci.http.formvalue("oldName"), luci.http.formvalue("newName"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function get_diag_folders()
	local folders = sgwconfig:get("getDiagFolders", luci.http.formvalue("path"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(folders)
end

function copy_move_files()
	local files = sgwconfig:get("copyMove", luci.http.formvalue("opstr"), luci.http.formvalue("fileLists"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end

function copy_move_progress()
	local progress = sgwconfig:get("copyProgress", luci.http.formvalue("transId"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(progress)
end

function usb_dev_format()
	local files = sgwconfig:get("usbFormat", luci.http.formvalue("usbdev"))

	luci.http.prepare_content("application/json")
	luci.http.write_json(files)
end