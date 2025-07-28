var isIE7 = false;
var lastSubMenuName, lastSubSecondMenuName, lastSubThirdMenuName;
var lastMainMenuName;
var mainMenuJsonObject = {
	"home" : {"mainDivId":"home_main_div", "hasChildMenu":false, "src": "/cgi-bin/luci/admin/home", "title":"首页", "selectClass": "first_menu_primary_select"},
	"device" : {"mainDivId":"device_main_div", "hasChildMenu":true, "src": "/cgi-bin/luci/admin/main/device", "title":"终端设备", "selectClass": "first_menu_primary_select"},
	"wifi" : {"mainDivId":"wifi_main_div", "hasChildMenu":true, "title":"WiFi设置", "selectClass": "first_menu_primary_select"},
	"storage" : {"mainDivId":"storage_main_div", "hasChildMenu":true, "title":"存储管理", "selectClass": "first_menu_primary_select"},
	"setting" : {"mainDivId":"setting_main_div", "hasChildMenu":true, "title":"高级设置", "selectClass": "first_menu_primary_select"},
	"help" : {"mainDivId":"help_main_div", "hasChildMenu":false, "src": "/cgi-bin/luci/admin/help", "title":"帮助中心", "selectClass": "first_menu_more_select"},
	"appdownload" : {"mainDivId":"appdownload_main_div", "hasChildMenu":false, "src": "/cgi-bin/luci/admin/download", "title":"APP下载", "selectClass": "first_menu_more_select"}
};
var subMenuJsonObject = {
	"device": {
		"childMenuPosition": "top",
		"secondmenus":[
			{"name": "pc", "title":"有线终端管理", "src": "/cgi-bin/luci/admin/device/pc"},
			{"name": "wifi", "title":"无线终端管理", "src": "/cgi-bin/luci/admin/device/wifi"},
			{"name": "itv", "title":"iTV管理", "src": "/cgi-bin/luci/admin/device/itv"},
			{"name": "phone", "title":"电话", "src": "/cgi-bin/luci/admin/device/phone"},
			{"name": "blacklist", "title":"设备黑名单", "src": "/cgi-bin/luci/admin/device/black"}
		]
	},
	"wifi": {
		"childMenuPosition": "top",
		"secondmenus":[
			{"name": "base", "title":"基本设置", "src": "/cgi-bin/luci/admin/wifi/base"},
			{"name": "advance", "title":"个性化设置", "src": "/cgi-bin/luci/admin/wifi/advance"}
		]
	},
	"storage": {
		"childMenuPosition": "top",
		"secondmenus":[
			{"name": "status", "title":"存储状态", "src": "/cgi-bin/luci/admin/storage/status"},
			{"name": "settings", "title":"存储设置", "src": "/cgi-bin/luci/admin/storage/settings"}
		]
	},
	"setting": {
		"childMenuPosition": "left",
		"secondmenus":[
			{"name": "gateway_status", "title":"网关状态", "src": "/cgi-bin/luci/admin/settings/status"},
			{"name": "gateway_info", "title":"网关信息", "src": "/cgi-bin/luci/admin/settings/info"},
			{"name": "network", "title":"局域网设置", "src": "/cgi-bin/luci/admin/settings/lan"},
			{"name": "portmap", "title":"端口映射", 
				"thirdmenus": [
					{"name":"portmap_config", "title":"端口映射", "src": "/cgi-bin/luci/admin/settings/portmap_config"},
					{"name":"portmap_list", "title":"映射列表", "src": "/cgi-bin/luci/admin/settings/portmap_list"}
				]
			},
			{"name": "user", "title":"修改登录信息", "src": "/cgi-bin/luci/admin/settings/user"},
			{"name": "restore", "title":"重置恢复", "src": "/cgi-bin/luci/admin/settings/restore"}
		]
	}
};

function changeMainMenu(element)
{
	var name = element.id.split("_")[2];
	if ( name == "home" )
	{
		$("#home_main_div").show();
		$("#main_body_div").hide();
	}
	else
	{
		$("#home_main_div").hide();
		$("#main_body_div").show();
	}
	change_first_menu_bg(name);
	change_first_menu_arrow(name);
	changeMainMenuForIframe(name);

}

function cleanPopWindowContent()
{
	$("#pop_window_icon").html('');
	$("#pop_window_title").html('');
	$("#pop_window_message").html('');
	//$("#pop_window_option").html('');
}
function showOrHidePopWindow(action)
{
	if ( action == "show" )
	{
		$("#pop_window_div").show();
		$("#pop_window_content_div").show();
	}
	else
	{
		$("#pop_window_div").hide();
		$("#pop_window_content_div").hide();
	}
}

function cleanPopWindowContentFromIframe()
{
	$("#pop_window_icon", window.parent.document).html('');
	$("#pop_window_title", window.parent.document).html('');
	$("#pop_window_message", window.parent.document).html('');
}

function showOrHidePopWindowFromIframe(action)
{
	if ( action == "show" )
	{
		$("#pop_window_div", window.parent.document).show();
				$("#pop_window_content_div", window.parent.document).show();
	}
	else
	{
		$("#pop_window_div", window.parent.document).hide();
		$("#pop_window_content_div", window.parent.document).hide();
	}
}

function doConfirm()
{
	showOrHidePopWindow("hide");
}
function doCancel()
{
	showOrHidePopWindow("hide");
} 
function changeMainMenuForIframe(newMainMenuName)
{
	var lastMenuObj = eval("mainMenuJsonObject." + lastMainMenuName);
	//1.先对上次显示的菜单做处理
	if ( lastMainMenuName != undefined && lastMenuObj != undefined && lastMainMenuName != name )
	{
		//1.1 隐藏div
		if (lastMenuObj.mainDivId != undefined)
		{
			document.getElementById(lastMenuObj.mainDivId).style.display = 'none';
		}
		//1.2 清除iframe内容
		if (document.getElementById(lastMainMenuName + "_iframe") != undefined)
		{
			document.getElementById(lastMainMenuName + "_iframe").src = '';
		}
	}
	
	var newMenuObj = eval("mainMenuJsonObject." + newMainMenuName);
	if (newMenuObj != undefined)   
	{
		//2.再对即将显示的菜单做处理
		//2.1 显示div
		if (newMenuObj.mainDivId != undefined)
			document.getElementById(newMenuObj.mainDivId).style.display = '';
		//2.2 对二、三级菜单处理，设置相应iframe的src
		if (newMenuObj.hasChildMenu != undefined && newMenuObj.hasChildMenu)
		{
			//如有二级菜单，则模拟首次点击
			var subMenuObj = eval("subMenuJsonObject." + newMainMenuName);
			if (subMenuObj != undefined)
			{
            		//2.1 关闭div  setting_main_div
		        if ((newMenuObj.mainDivId == 'setting_main_div') || (newMenuObj.mainDivId == 'storage_main_div') ||(newMenuObj.mainDivId == 'wifi_main_div'))
                {
			      document.getElementById(newMenuObj.mainDivId).style.display = 'none';
                  $("#first_menu_select_arrow_div").css('display','none');
            
                }
				changeSubSecondMenu(newMainMenuName, subMenuObj.secondmenus[0].name);
		        if ((newMenuObj.mainDivId == 'setting_main_div') || (newMenuObj.mainDivId == 'storage_main_div') ||(newMenuObj.mainDivId == 'wifi_main_div'))
                {
 
                   setTimeout(function(){
                     document.getElementById(newMenuObj.mainDivId).style.display = '';
                     $("#first_menu_select_arrow_div").css('display',''); 
                   },250);
                }  
			}
		}
		else if (newMenuObj.src != undefined)
		{
			document.getElementById(newMainMenuName + "_iframe").src = newMenuObj.src;
		}
	}
	//2.3 更新lastMainMenuName
	lastMainMenuName = newMainMenuName;
}

function change_first_menu_bg(name)
{
	var new_obj = eval("mainMenuJsonObject." + name);
	var last_obj = eval("mainMenuJsonObject." + lastMainMenuName);
	
	if ( last_obj != undefined )
	{
		$("#first_menu_" + lastMainMenuName).removeClass("first_menu_primary_select");
		$("#first_menu_" + lastMainMenuName).removeClass("first_menu_more_select");
		$("#first_menu_select_arrow_div").removeClass("first_menu_" + lastMainMenuName + "_select_arrow");
	}
	if ( new_obj != undefined )
	{
		$("#first_menu_" + name).addClass(new_obj.selectClass);
	}
}
function change_first_menu_arrow(name)
{
	var new_obj = eval("mainMenuJsonObject." + name);

	if ( new_obj != undefined )
	{
                var selectLeftWidth = $("#first_menu_" + name ).offset().left;
		var arrowWidth = $("#first_menu_select_arrow_div").width();
		var selectWidth = $("#first_menu_" + name).width();
		var leftWidth = parseInt(selectLeftWidth + (selectWidth-arrowWidth)/2);
		
		
		if ( isIE7 )
		{
			var logWidth = $("#tianyi_logo_div").width();
			var logLeftWidth = document.getElementById("tianyi_logo_div" ).parentElement.offsetLeft;
			leftWidth += logWidth + logLeftWidth;
		}
		$("#first_menu_select_arrow_div").css("margin-left", leftWidth);
		$("#first_menu_select_arrow_div").addClass("first_menu_" + name + "_select_arrow");
	}
}

function constructSubMenuHTML(name)
{
	var subMenuObj = eval("subMenuJsonObject." + name);
	
	if (subMenuObj != undefined)
	{
		var dynamicConfigSubMenuHTML = "";
		if ( subMenuObj.childMenuPosition == "top" )
		{
			dynamicConfigSubMenuHTML += "<div class='sub_second_menu_top_blank'></div>";
		}
		for (var i=0; i<subMenuObj.secondmenus.length; i++) //二级菜单
		{
			var partSecondMenuHTML = "";
	
			partSecondMenuHTML += "<div id='sub_second_menu_" + name + "_" + subMenuObj.secondmenus[i].name + "' class='sub_second_menu_" + subMenuObj.childMenuPosition + "_second' onclick='changeSubSecondMenu(\"" + name + "\", \"" + subMenuObj.secondmenus[i].name + "\")'>";
			partSecondMenuHTML += subMenuObj.secondmenus[i].title;
			partSecondMenuHTML += "</div>";

			var partThirdMenuHTML = "";
			//二级菜单在左侧时构建三级菜单
			if ( subMenuObj.childMenuPosition == "left"
				&& subMenuObj.secondmenus[i].thirdmenus != undefined
				&& subMenuObj.secondmenus[i].thirdmenus.length > 0)
			{
				partThirdMenuHTML += "<div id='sub_third_menu_" + name + "_" + subMenuObj.secondmenus[i].name + "' style='display: none;'>";
				for (var j=0; j<subMenuObj.secondmenus[i].thirdmenus.length; j++)
				{
					partThirdMenuHTML += "<div id='sub_third_menu_" + name + "_" + subMenuObj.secondmenus[i].name + "_" + subMenuObj.secondmenus[i].thirdmenus[j].name + "' class='sub_second_menu_left_third' onclick='changeSubThirdMenu(\"" + name + "\", \"" + subMenuObj.secondmenus[i].name + "\", \"" + subMenuObj.secondmenus[i].thirdmenus[j].name + "\")'>";
					partThirdMenuHTML += subMenuObj.secondmenus[i].thirdmenus[j].title;
					partThirdMenuHTML += "</div>";
				}
					partThirdMenuHTML += "<div class='sub_third_menu_left_blank'></div>";
				partThirdMenuHTML += "</div>";
			}
			dynamicConfigSubMenuHTML += partSecondMenuHTML;
			dynamicConfigSubMenuHTML += partThirdMenuHTML;
		}
		$("#" + name + "_sub_second_menu_div_" +subMenuObj.childMenuPosition).html(dynamicConfigSubMenuHTML);
	}
}

function changeSubSecondMenu(newSubMenuName, newSubSecondMenuName, params)
{
	var newSubMenuJsonObj = eval("subMenuJsonObject." + newSubMenuName);
	var lastSubMenuJsonObj = eval("subMenuJsonObject." + lastSubMenuName);
	var lastSecondMenuObj, newSecondMenuObj;
	
	if (lastSubMenuJsonObj != undefined)
	{
		if (lastSubSecondMenuName != undefined)
		{
			for (var j=0; j<lastSubMenuJsonObj.secondmenus.length; j++)
			{
				if (lastSubSecondMenuName == lastSubMenuJsonObj.secondmenus[j].name)
				{
					lastSecondMenuObj = lastSubMenuJsonObj.secondmenus[j];
					//清除样式
					$("#sub_second_menu_" + lastSubMenuName + "_" + lastSubSecondMenuName).removeClass("sub_second_menu_" + lastSubMenuJsonObj.childMenuPosition + "_second_select");
					
					//如果有3级菜单，则隐藏
					if (lastSecondMenuObj.thirdmenus != undefined && lastSecondMenuObj.thirdmenus.length > 0)
					{
						document.getElementById("sub_third_menu_" + lastSubMenuName + "_" + lastSubSecondMenuName).style.display = "none";
						//清除3级菜单样式
						var lastThirdMenuElement = document.getElementById("sub_third_menu_" + newSubMenuName + "_" + lastSubSecondMenuName + "_" + lastSubThirdMenuName);
						if (lastThirdMenuElement != undefined)
						{
							$("#sub_third_menu_" + lastSubMenuName + "_" + lastSubSecondMenuName + "_" + lastSubThirdMenuName).removeClass("sub_second_menu_" + lastSubMenuJsonObj.childMenuPosition + "_third_select");
						}
					}
					break;
				}
			}
		}
	}

	for (var i=0; i<newSubMenuJsonObj.secondmenus.length; i++)
	{
		if (newSubSecondMenuName == newSubMenuJsonObj.secondmenus[i].name)
		{
			newSecondMenuObj = newSubMenuJsonObj.secondmenus[i];
			break;
		}
	}
	//设置样式
	$("#sub_second_menu_" + newSubMenuName + "_" + newSubSecondMenuName).addClass("sub_second_menu_" + newSubMenuJsonObj.childMenuPosition + "_second_select");
	
	//如果有3级菜单则显示，并模拟首次点击
	if (newSecondMenuObj.thirdmenus != undefined && newSecondMenuObj.thirdmenus.length > 0)
	{
		//alert("has third");
		changeSubThirdMenu(newSubMenuName, newSubSecondMenuName, newSecondMenuObj.thirdmenus[0].name, params);
		document.getElementById("sub_third_menu_" + newSubMenuName + "_" + newSubSecondMenuName).style.display = "";
	}
	else //如果没有3级菜单，更新iframe内容
	{
		// console.log('params ' + params);
		if ( params == '' || params == undefined)
		{
			document.getElementById(newSubMenuName + "_iframe").src = newSecondMenuObj.src;
		}
		else
		{
			document.getElementById(newSubMenuName + "_iframe").src = newSecondMenuObj.src + '?' + params;
		}
	}
	//更新lastSubSecondMenuName lastSubMenuName
	lastSubSecondMenuName = newSubSecondMenuName;
	lastSubMenuName = newSubMenuName;
}

function changeSubThirdMenu(newSubMenuName, newSubSecondMenuName, newSubThirdMenuName, params)
{
	var subMenuJsonObj = eval("subMenuJsonObject." + newSubMenuName);
	var newThirdMenuObj;
	
	for (var i=0; i<subMenuJsonObj.secondmenus.length; i++)
	{
		if (newSubSecondMenuName == subMenuJsonObj.secondmenus[i].name
			&& subMenuJsonObj.secondmenus[i].thirdmenus != undefined 
			&& subMenuJsonObj.secondmenus[i].thirdmenus.length)
		{
			for (var j=0; j<subMenuJsonObj.secondmenus[i].thirdmenus.length; j++)
			{
				if (newSubThirdMenuName == subMenuJsonObj.secondmenus[i].thirdmenus[j].name)
				{
					newThirdMenuObj = subMenuJsonObj.secondmenus[i].thirdmenus[j];
					break;
				}
			}
			break;
		}
	}
	
	var lastThirdMenuElement = document.getElementById("sub_third_menu_" + newSubMenuName + "_" + lastSubSecondMenuName + "_" + lastSubThirdMenuName);
	//清除上一个被点击元素的样式
	if (lastThirdMenuElement != undefined)
	{
		$("#sub_third_menu_" + newSubMenuName + "_" + lastSubSecondMenuName + "_" + lastSubThirdMenuName).removeClass("sub_second_menu_" + subMenuJsonObj.childMenuPosition + "_third_select");
	}
	//设置新元素的样式
	$("#sub_third_menu_" + newSubMenuName + "_" + newSubSecondMenuName + "_" + newSubThirdMenuName).addClass("sub_second_menu_" + subMenuJsonObj.childMenuPosition + "_third_select");
	//更新iframe内容
	// console.log('params ' + params);
	if ( params == '' || params == undefined)
	{
		document.getElementById(newSubMenuName + "_iframe").src = newThirdMenuObj.src;
	}
	else
	{
		document.getElementById(newSubMenuName + "_iframe").src = newThirdMenuObj.src + '?' + params;
	}
	
	lastSubThirdMenuName = newSubThirdMenuName;
}

