function enable_disable_wifi(id, enbl)
{
	if (enbl)
	{
		$(".wifi_" + id +"G_item").css("display", "");
		$("#" + id +"G_security").css("background-color", $("#wifi_" + id +"G_SSID").css("background-color"));
		$("#wifi_" + id +"G_password").parent().css("background-color", $("#wifi_" + id +"G_SSID").css("background-color"));
	}
	else
	{
		$(".wifi_" + id +"G_item").css("display", "none");
		$("#" + id +"G_security").css("background-color", $("#wifi_" + id +"G_SSID").css("background-color"));
		$("#wifi_" + id +"G_password").parent().css("background-color", $("#wifi_" + id +"G_SSID").css("background-color"));		
	}
}

$(document).ready(function(){
	customSwitchInit();

    $("#onoff_switch").click(function(){
    	if($(this).hasClass("switch_content_on")){
    		$(".wifi_item").show();
			if (parseInt($("#toggle_switch_value").val()) == 1)
			{
				if ($("#2G_wifi_security_list_value").val() == "Open")
					$("#wifi_2G_password").parent().parent().parent().hide();
				
				$(".wifi_onoff").show();
			}
			else
			{
				if (parseInt($("#wifi_2G_switch_value").val()) == 0)
					$(".wifi_2G_item").hide();
				else if ($("#2G_wifi_security_list_value").val() == "Open")
					$("#wifi_2G_password").parent().parent().parent().hide();

				if (parseInt($("#dualBand").val()) == 0)
					$(".wifi_5G").hide();
				else
				{
					if (parseInt($("#wifi_5G_switch_value").val()) == 0)
						$(".wifi_5G_item").hide();
					else if ($("#5G_wifi_security_list_value").val() == "Open")
						$("#wifi_5G_password").parent().parent().parent().hide();
				}
			}
    	} else
    		$(".wifi_item:not(.wifi_onoff)").hide();
    });	

	$("#wifi_2G_switch").bind("click", function(){
		if($(this).hasClass("switch_content_on"))
			enable_disable_wifi("2", true);
		else
			enable_disable_wifi("2", false);
	});

	$("#wifi_5G_switch").bind("click", function(){
		if($(this).hasClass("switch_content_on"))
			enable_disable_wifi("5", true);
		else
			enable_disable_wifi("5", false);
	});

	customSelectInit();
	//passowrd

	$("input[type='password']").bind("focusin", function(){
		$(this).parent().eq(0).addClass("wifi-password-focus");
	});
	$("input[type='password']").bind("focusout", function(){
		$(this).parent().eq(0).removeClass("wifi-password-focus");
	});

	$("input[type='text']").bind("focusin", function(){
		if(judedNavation() < 9){
			$(this).css("border", "1px solid #39ba93");
		}
	});
	$("input[type='text']").bind("focusout", function(){
		if(judedNavation() < 9){
			$(this).css("border", "1px solid #dbdbdb");
		}
	});

	$(".dropdown-menu-select li").click(function(){
			if ($(this).parent().siblings("label").first().text() == "Open")
				$(this).parent().parent().parent().parent().next().hide();
			else
				$(this).parent().parent().parent().parent().next().show();
		});

	customPasswordInit();
});

