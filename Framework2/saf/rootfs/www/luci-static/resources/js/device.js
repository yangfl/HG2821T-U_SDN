var queryString;
var specifiedIp = "";
function getSpecifiedIp()
{
	queryString = location.search;
	if (queryString != '' && queryString != undefined )
	{
		specifiedIp = queryString.substring(queryString.indexOf("=")+1, queryString.length);
	}else{
		specifiedIp = "";
	}
}

function checkType(deviceSystem)
{
	var sys = deviceSystem.toUpperCase();
	if((sys.indexOf("MAC") != -1) || (sys.indexOf("IOS") != -1)){
		return "macbook";
	}else if (sys.indexOf("WIN") != -1){
		return "windows";
	}else if (sys.indexOf("AND") != -1){
		return "android";
	}else
		return "unknown";
}

function addBgClassByCheckIp(deviceIp)
{
	if(specifiedIp != ""){
		if(deviceIp == specifiedIp){
			return "tr-bg-selected";
		}else{
			return "";
		}
	}else{
		return "";
	}
}

var bgFlag = 0;

function addTrBg(flag)
{
	if(flag == 1){
		return "tr-bg";
	}else{
		return "";
	}
}

function generateDeviceSetting(device, index)
{
	var htmlObj = "";

	var trClass = "";
	var tmpname = "";
	
	var strMac = device.mac;
	if (strMac.length == 12)
		var mac = strMac.substring(0,2) + ":" + strMac.substring(2,4) + ":" + strMac.substring(4,6) + ":" + strMac.substring(6,8) + ":" + strMac.substring(8,10) + ":" + strMac.substring(10,12);
	else
		var mac = strMac;

  if(specifiedIp != "")
	  trClass = addBgClassByCheckIp(device.ip);
	
	if((trClass == "") && (bgFlag == 1))
	{
		trClass = "tr-bg";
	}

	if((trClass != "") && (trClass != undefined)){
		htmlObj += "<tr class='" + trClass + "'>";	
	}else{
		htmlObj += "<tr>";
	}
	
	htmlObj += "<td>";
	htmlObj += "<div><img src='/luci-static/resources/image/" + checkType(device.system) + ".png'/></div>";
	htmlObj += "<div>";
	htmlObj += "<label class='label-desc'>IP&#58&nbsp;</label><label class='label-content'>" + device.ip + "</label><br/>";
	htmlObj += "<label class='label-desc'>MAC&#58&nbsp;</label><label class='label-content'>"+ mac.toUpperCase() + "</label>";
	htmlObj += "</div>";
	htmlObj += "</td>";
	htmlObj += "<td>";
	htmlObj += "<label class='label-desc'>上行&#58</label><label class='label-content'>&nbsp;"+ getNetworkRate(parseInt(device.upSpeed), 1) +"b/s</label><br/>";
	htmlObj += "<label class='label-desc'>下行&#58</label><label class='label-content'>&nbsp;"+ getNetworkRate(parseInt(device.downSpeed), 1) +"b/s</label>";
	htmlObj += "</td>";
	htmlObj += "<td class='restriction-td'>";
	if (device.restrict)
	{
		htmlObj +='<div class="rate_limit switch_content device_switch switch_content_on" id="restriction_switch_'+ index + '">';
		htmlObj +='<input type="hidden" id="restriction_switch_' + index + '_value" value="1" /><span>&nbsp;ON</span></div>';	
	}
	else
	{
		htmlObj +='<div class="rate_limit switch_content device_switch switch_content_off" id="restriction_switch_'+ index + '">';
		htmlObj +='<input type="hidden" id="restriction_switch_' + index + '_value" value="0" /><span>OFF&nbsp;</span></div>';
	}
	htmlObj += "</td>";
	htmlObj += "<td class='restriction-td'>";
	htmlObj +='<div class="rate_limit switch_content device_switch switch_content_off" id="black_switch_'+ index + '">';
	htmlObj +='<input type="hidden" id="black_switch_' + index + '_value" value="0" /><span>OFF&nbsp;</span></div>';
	htmlObj += "</td>";
	htmlObj += "</tr>";
	$("tbody").append(htmlObj);
	if(bgFlag == 0){
		bgFlag = 1;
	}else{
		bgFlag = 0;
	}
}

function confirmPC_Blacklist(blackip)
{
    cleanPopWindowContentFromIframe();
				
    //填充内容
	$("#pop_window_title", window.parent.document).html("确认拉黑");
	$("#pop_window_icon", window.parent.document).html('<div class="pop_window_icon_alert"></div>');
	if (lanip.indexOf(blackip) != -1)
		$("#pop_window_message", window.parent.document).html("您确认将当前设备从网关中拉黑？如果执行该操作，本设备将无法访问网关和英特网，您必须通过另外一台设备连接本网关才能重新将该设备从黑名单中找回。");
	else
	  $("#pop_window_message", window.parent.document).html("您正在进行拉黑操作，该设备拉黑后将从当前列表中直接删除，您可进入设备黑名单中找回它。");
			
	//更改确认操作函数
	var eid = parent.document.getElementById("confirm");
	if ( isIE7Browser() )
	{
		eid.onclick = function() { set_host_black() };
	}
	else
	{
		eid.setAttribute("onclick","document.getElementById('device_iframe').contentWindow.set_host_black()");
	}
	showOrHidePopWindowFromIframe("show");
}

function cancelBlacklist()
{
	cleanPopWindowContentFromIframe();
				
	//填充内容
	$("#pop_window_title", window.parent.document).html("确认撤销拉黑");
	$("#pop_window_icon", window.parent.document).html('<div class="pop_window_icon_alert"></div>');
	$("#pop_window_message", window.parent.document).html("您正在进行撤销拉黑操作，该设备撤销拉黑后将从设备黑名单中直接删除，您可在终端列表中找回它。");
			
	//更改确认操作函数
	var eid = parent.document.getElementById("confirm");
	if ( isIE7Browser() )
	{
		eid.onclick = function() { removeBlack() };
	}
	else
	{
		eid.setAttribute("onclick","document.getElementById('device_iframe').contentWindow.removeBlack()");
	}
	showOrHidePopWindowFromIframe("show");
}

function displayblackhosts(device)
{
	var htmlObj = "";
	var trClass = "";
	

	
	var strMac = device.mac;
	if (strMac.length == 12)
		var mac = strMac.substring(0,2) + ":" + strMac.substring(2,4) + ":" + strMac.substring(4,6) + ":" + strMac.substring(6,8) + ":" + strMac.substring(8,10) + ":" + strMac.substring(10,12);
	else
		var mac = strMac;
		
	if(bgFlag == 1)
		trClass = "tr-bg";		

	if((trClass != "") && (trClass != undefined)){
		htmlObj += "<tr class='" + trClass + "'>";	
	}else{
		htmlObj += "<tr>";
	}
	
	htmlObj += "<td>";
	htmlObj += "<div><img src='/luci-static/resources/image/" + checkType(device.system) + ".png'/></div>";
	htmlObj += "<div>";
	htmlObj += "<label class='label-desc'>IP&#58&nbsp;</label><label class='label-content'>" + device.ip + "</label><br/>";
	htmlObj += "<label class='label-desc'>MAC&#58&nbsp;</label><label class='label-content blackmac'>"+ mac.toUpperCase() + "</label>";
	htmlObj += "</div>";
	htmlObj += "</td>";
    htmlObj += "<td></td><td></td>"; 
	htmlObj += '<td class="restriction-td">';
 	htmlObj += "<span class='switch-button'><a style='color:#39BA93'>撤销拉黑<a/> </span>";
	htmlObj += "</td>";
	htmlObj += "</tr>";
	
	$("tbody").append(htmlObj);
	if(bgFlag == 0){
		bgFlag = 1;
	}else{
		bgFlag = 0;
	}	
}