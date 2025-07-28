var isIE7 = false;
var listMaxShowNumStorage = 4;
var listMaxShowNum = 6;
var currentMaxShowNum;
var leftHideNum = 0;
var rightHideNum = 0;
var currentListType;
var devListObjs;
var wifiOnOff = true;
var wifiBoth = false;
var hasGotten = false;
var pcCnt = 0;
var wifiCnt = 0;
var usbCnt = 0;

function showDeviceInfo(eObj,isMouseOver)
{
    var name = eObj.id.split("_")[1];
	if (!hasGotten || (name == "wifi") && !wifiOnOff)
	{
		return;
	}

	clearTimeout(activeTimeout);				
	activeTimeout = setTimeout("Timeout()", 300000);
	
	if ( isMouseOver )
	{
		// console.log("Mouse Over on " + name);
		
		$("#device_wifi_logo_div").removeClass("device_wifi_logo_div_shadow");
		$("#device_pc_logo_div").removeClass("device_pc_logo_div_shadow");
		$("#device_itv_logo_div").removeClass("device_itv_logo_div_shadow");
		$("#device_phone_logo_div").removeClass("device_phone_logo_div_shadow");
		$("#device_storage_logo_div").removeClass("device_storage_logo_div_shadow");
		
		$("#device_detail_div").show();
		$("#device_" + name + "_detail_div").removeClass("visibility_hidden");
		if (name == "wifi")
		{
			if (wifiBoth)
			{
				$("#device_wifi_detail_div").removeClass("device_detail");
				$("#device_wifi_detail_div").addClass("device_detail_wl");
			}
			else
			{
				$("#device_wifi_detail_div").removeClass("device_detail_wl");
				$("#device_wifi_detail_div").addClass("device_detail");	
			}
		}

		$("#device_" + name + "_detail_div").addClass("device_detail_" + name);
		$("#device_" + name + "_logo_div").addClass("device_" + name + "_logo_div_mouseover");
		
		//隐藏device list
		$("#device_list_div").hide();
		$("#device_info_div").show();
	}
	else
	{
		// console.log("Mouse Off on " + name);
		
		$("#device_detail_div").hide();
		$("#device_" + name + "_detail_div").addClass("visibility_hidden");		
		$("#device_" + name + "_detail_div").removeClass("device_detail_" + name);
		$("#device_" + name + "_logo_div").removeClass("device_" + name + "_logo_div_mouseover");
	}
}

function showDeviceList(eObj)
{
	// device_wifi_logo_div
	var name = eObj.id.split("_")[1];
	if (((name == "wifi") && (wifiCnt == 0)) || ((name == "pc") && (pcCnt == 0)) || ((name == "storage") && (usbCnt == 0)))
	{
		return;
	}
	
	clearTimeout(activeTimeout);				
	activeTimeout = setTimeout("Timeout()", 300000);
	
	// console.log("Click on " + name);
	
	//增加选中效果
	$("#device_" + name + "_logo_div").addClass("device_" + name + "_logo_div_shadow");
	
	//背景图片处理
	var leftWidth = eObj.offsetLeft;
	//IE7单独处理
	if ( isIE7 )
	{
		leftWidth += eObj.parentElement.offsetLeft;
	}
	$("#device_list_div").css("background-position", leftWidth + 330);
	
	//左侧宽度
	leftWidth = eObj.parentElement.offsetLeft;
	$("#device_list_left_div").css("margin-left", leftWidth);
	
	//构建内容
	constructDeviceList(name, false, false);
	
	$("#device_info_div").hide();
	$("#device_detail_div").hide();
	// $("#device_list_div").show();
	$("#device_list_div").fadeIn("slow");
	
	
}


function deviceListMouseOver()
{
	// console.log("deviceListMouseOver");
}
function deviceListMouseOut()
{
	// console.log("deviceListMouseOut");
}

function constructDeviceList(listType, toLeft, toRight)
{
	//var jsonObj = eval("devListObjs." + listType);
	var jsonObj;
	var dynamicHTML = "";
	var eid = document.getElementById("device_list_center_div");
	var index;
	var num;
	
	if (listType == "wifi")
		num = devListObjs.wlcount;
	else if (listType == "pc")
		num = devListObjs.wcount;
	else if (listType == "storage")
		num = devListObjs.scount;
	
	console.log("constructDeviceList listType is " + listType + "; toLeft is " + toLeft + "; toRight is " + toRight);
	//计算最大显示个数
	if ( listType == "storage" )
	{
		currentMaxShowNum = listMaxShowNumStorage;
	}
	else
	{
		currentMaxShowNum = listMaxShowNum;
	}
	
	//首次构建
	if ( !toLeft && !toRight)
	{
		// 重置偏移量
		leftHideNum = 0;
		rightHideNum = 0;
		// 记录listType
		currentListType = listType;
		
		//清除arrow样式
		$("#device_list_left_arrow_div").removeClass("device_list_left_arrow");
		$("#device_list_right_arrow_div").removeClass("device_list_right_arrow");
		
		//清除arrow鼠标移动和onclick事件
		document.getElementById("device_list_left_arrow_div").onmouseover = function() {}
		document.getElementById("device_list_right_arrow_div").onmouseover = function() {}
		document.getElementById("device_list_left_arrow_div").onmouseout = function() {}
		document.getElementById("device_list_right_arrow_div").onmouseout = function() {}
		document.getElementById("device_list_left_arrow_div").onclick = function() {}
		document.getElementById("device_list_right_arrow_div").onclick = function() {}
				
		//目标个数大于最大显示个数
		if ( num > currentMaxShowNum && !toLeft && !toRight)
		{
			rightHideNum = num - currentMaxShowNum;
			console.log("No enough space to show all device list");
			$("#device_list_left_arrow_div").addClass("device_list_left_arrow");
			$("#device_list_right_arrow_div").addClass("device_list_right_arrow");
			document.getElementById("device_list_left_arrow_div").onmouseover = function() {listArrowOverOut(this, true);}
			document.getElementById("device_list_right_arrow_div").onmouseover = function() {listArrowOverOut(this, true);}
			document.getElementById("device_list_left_arrow_div").onmouseout = function() {listArrowOverOut(this, false);}
			document.getElementById("device_list_right_arrow_div").onmouseout = function() {listArrowOverOut(this, false);}
			document.getElementById("device_list_left_arrow_div").onclick = function() {listArrowClick(this);}
			document.getElementById("device_list_right_arrow_div").onclick = function() {listArrowClick(this);}
		}
	}
	
	//计算偏移量
	if ( toRight )
	{
		leftHideNum = leftHideNum + 1;
		rightHideNum = rightHideNum - 1;
	}
	if ( toLeft )
	{
		leftHideNum = leftHideNum - 1;
		rightHideNum = rightHideNum + 1;
	}
	//检测偏移量有效性
	if ( leftHideNum > num - currentMaxShowNum )
	{
		leftHideNum = num - currentMaxShowNum;
	}
	if ( leftHideNum < 0 )
	{
		leftHideNum = 0;
	}
	if ( rightHideNum > num - currentMaxShowNum )
	{
		rightHideNum = num - currentMaxShowNum;
	}
	if ( rightHideNum < 0 )
	{
		rightHideNum = 0;
	}
	console.log("leftHideNum " + leftHideNum);
	console.log("rightHideNum " + rightHideNum);
	
	//构建显示设备列表
	if ( listType == "storage" ) //存储的单独处理
	{
		for ( var i=leftHideNum; i < num && i < currentMaxShowNum + leftHideNum; i++)
		{
			jsonObj = eval("devListObjs." + listType + (i + 1));
			var totalSize = getNetworkRate(parseInt(jsonObj.maxSize), 1);
			var usedSize;
			if (totalSize[totalSize.length - 1] == "K")
				usedSize = (parseInt(jsonObj.usedSize) / 1024).toFixed(1);
			else if (totalSize[totalSize.length - 1] == "M")
				usedSize = (parseInt(jsonObj.usedSize) / (1024 * 1024)).toFixed(1);
			else if (totalSize[totalSize.length - 1] == "G")
				usedSize = (parseInt(jsonObj.usedSize) / (1024 * 1024 * 1024)).toFixed(1);
			else if (totalSize[totalSize.length - 1] == "T")
				usedSize = (parseInt(jsonObj.usedSize) / (1024 * 1024 * 1024 * 1024)).toFixed(1); 
	
			var percentage = parseInt((jsonObj.usedSize/jsonObj.maxSize) * 100);
			dynamicHTML += '<div class="device_list_content_div_storage pointer_cursor" onclick="jumpToPage(\'storage\', \'settings\', \'\', \'usbdev=' + jsonObj.usbdev + '\')">';
			dynamicHTML += '<div class="device_list_icon_storage"></div>';
			dynamicHTML += '<div class="device_list_storage_info">';
			dynamicHTML += '<div class="device_list_storage_info_title long_text">' + jsonObj.name + '</div>';
			dynamicHTML += '<div class="device_list_storage_info_bar"><div style="width:' + percentage + '%"></div></div>';
			dynamicHTML += '<div class="device_list_storage_info_size">' + usedSize + '/' + totalSize +'B</div>';
			dynamicHTML += '</div>';
			dynamicHTML += '</div>';
		}
	}
	else
	{
		for ( var i=leftHideNum; i < num && i < currentMaxShowNum + leftHideNum; i++)
		{
			jsonObj = eval("devListObjs." + listType + (i + 1));
			dynamicHTML += '<div class="device_list_content_div">';
			dynamicHTML += '<div id="device_list_' + listType + '_icon_' + i + '"';
			dynamicHTML += ' class="device_list_icon list_' + jsonObj.type.toLowerCase() + '"';
			dynamicHTML += ' onmouseover="showListFloatInfo(this, true)"';
			dynamicHTML += ' onmouseout="showListFloatInfo(this, false)"';
			dynamicHTML += ' onclick="jumpToPage(\'device\', \'' + listType +  '\', \'\', \'ip=' + jsonObj.ip + '\')"';
			dynamicHTML += '></div>';
			dynamicHTML += '</div>';
		}
	}
	$("#device_list_center_div").html(dynamicHTML);
	
}
function listArrowOverOut(eObj, isMouseOver)
{
	// device_list_right_arrow_div
	var position = eObj.id.split('_')[2];
	console.log(position);
	if ( isMouseOver )
	{
		$("#device_list_" + position + "_arrow_div").addClass("device_list_" + position + "_arrow_on");
	}
	else
	{
		$("#device_list_" + position + "_arrow_div").removeClass("device_list_" + position + "_arrow_on");
	}
}

function listArrowClick(eObj)
{
	clearTimeout(activeTimeout);				
	activeTimeout = setTimeout("Timeout()", 300000);
	
	// device_list_right_arrow_div
	var position = eObj.id.split('_')[2];
	console.log(position);
	if ( position == "left" )
	{
		constructDeviceList(currentListType, true, false);
	}
	else if ( position == "right" )
	{
		constructDeviceList(currentListType, false, true);
	}
}

function showListFloatInfo(eObj, isMouseOver)
{
	clearTimeout(activeTimeout);				
	activeTimeout = setTimeout("Timeout()", 300000);
	
	//device_list_wifi_icon_1
	var eid = eObj.id;
	var type = eid.split("_")[2]; 
	var index = eid.split("_")[4]; 
	//var jsonObj = eval("demoDevicesListObj." + type);
	var jsonObj = eval("devListObjs." + type + (parseInt(index) + 1));
	
	var listLeftDivWidth = 260; //在css中定义
	
	if ( isMouseOver )
	{
		// 1. 修改显示样式 device_list_wifi_title_1
		// 1.1 修改图片样式
		$("#device_list_" + type + "_icon_" + index ).addClass("list_" + jsonObj.type.toLowerCase() + "_on");
		// 1.2 修改文字样式
		$("#device_list_" + type + "_title_" + index ).addClass("theme_color");
		
		// 2. 处理要显示的详细信息框
		// 2.1 计算左侧宽度
		var leftWidth = eObj.parentElement.offsetLeft;
		//IE7单独处理
		if ( isIE7 )
		{
			leftWidth += listLeftDivWidth;
			leftWidth += document.getElementById("device_list_left_div").offsetLeft;
		}
		leftWidth += eObj.parentElement.offsetWidth;
		
		// 2.2 填充内容
		var dynamicHTML = "";	

		dynamicHTML += '品牌: <span class="theme_color">' + jsonObj.brand + '</span><br />';
		dynamicHTML += '型号: <span class="theme_color">' + jsonObj.model + '</span><br />';
    	dynamicHTML += '上行: <span class="theme_color">' + getNetworkRate(parseInt(jsonObj.upSpeed), 1) + 'b/s</span><br />';
		dynamicHTML += '下行: <span class="theme_color">' + getNetworkRate(parseInt(jsonObj.downSpeed), 1) + 'b/s</span><br />';
		if ((jsonObj.onlineTime == "") || (parseInt(jsonObj.onlineTime) == 0))
		{
			dynamicHTML += '在线: <span class="theme_color">0分钟</span><br />';
		}
		else
		{
			var tStr = formatTime(parseInt(jsonObj.onlineTime));
			var tUp = tStr.split(":");
			dynamicHTML += '在线: <span class="theme_color">' + tUp[0]+"天"+tUp[1]+"小时"+tUp[2]+"分钟" + '</span><br />';
	    }	
		  
		$("#device_list_float_info_div").html(dynamicHTML);
		
		// 2.3 调整位置
		$("#device_list_float_div").css("margin-left", leftWidth);
		// 2.4 显示内容
		$("#device_list_float_div").show();
	}
	else
	{
		
		$("#device_list_" + type + "_icon_" + index ).removeClass("list_" + jsonObj.type.toLowerCase() + "_on");
		$("#device_list_" + type + "_title_" + index ).removeClass("theme_color");
		$("#device_list_float_div").hide();
	}
}

function jumpToPage(first, second, third, params)
{
	if ( first != '' && first != undefined )
	{
		window.parent.changeMainMenu(window.parent.document.getElementById("first_menu_" + first));
		if ( second != '' && second != undefined )
		{
			window.parent.changeSubSecondMenu(first, second, params);
			if ( third != '' && third != undefined )
			{
				window.parent.changeSubThirdMenu(first, second, third, params);
			}
		}
	}
}

