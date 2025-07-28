function enableAll()
{
	// confirm("确认开启所有？");
	cleanPopWindowContentFromIframe();
	
	//填充内容
	$("#pop_window_title", window.parent.document).html("开启提醒");
	$("#pop_window_icon", window.parent.document).html('<div class="pop_window_icon_help"></div>');
	$("#pop_window_message", window.parent.document).html("您开启所有端口映射。");
	
	//更改确认操作函数
	var eid = parent.document.getElementById("confirm");
	if ( isIE7Browser() )
	{
		eid.onclick = function() { realEnableAll() };
	}
	else
	{
		eid.setAttribute("onclick","document.getElementById('setting_iframe').contentWindow.realEnableAll()");
	}
	showOrHidePopWindowFromIframe("show");
}
function disableAll()
{
	// confirm("确认关闭所有？");
	cleanPopWindowContentFromIframe();
	
	//填充内容
	$("#pop_window_title", window.parent.document).html("关闭提醒");
	$("#pop_window_icon", window.parent.document).html('<div class="pop_window_icon_help"></div>');
	$("#pop_window_message", window.parent.document).html("您将关闭所有端口映射。");
	
	//更改确认操作函数
	var eid = parent.document.getElementById("confirm");
	if ( isIE7Browser() )
	{
		eid.onclick = function() { realDisableAll() };
	}
	else
	{
		eid.setAttribute("onclick","document.getElementById('setting_iframe').contentWindow.realDisableAll()");
	}
	showOrHidePopWindowFromIframe("show");
}

function deleteAll()
{
	// confirm("确认删除所有？");
	cleanPopWindowContentFromIframe();
	
	//填充内容
	$("#pop_window_title", window.parent.document).html("删除提醒");
	$("#pop_window_icon", window.parent.document).html('<div class="pop_window_icon_help"></div>');
	$("#pop_window_message", window.parent.document).html("您将删除列表中的所有信息，删除后不可恢复。");
	
	//更改确认操作函数
	var eid = parent.document.getElementById("confirm");
	if ( isIE7Browser() )
	{
		eid.onclick = function() { realDeleteAll() };
	}
	else
	{
		eid.setAttribute("onclick","document.getElementById('setting_iframe').contentWindow.realDeleteAll()");
	}
	showOrHidePopWindowFromIframe("show");
}
