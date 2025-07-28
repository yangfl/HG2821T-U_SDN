//javascript for login.html
var isEmpty = false;
var setloidOK = 0;
var stime = 0;
var lanip = "";

$(document).ready(function(){
	//change the stylesheet of login
	showAnimateLine();
	//检查是否第一次登陆，并给出对应的提示

	$("#step1_tip").css("display", "");
	showAnimateTip("step1_tip");

	$(".login-block input").focusin(function(){
	  $(this).parent(".login-block").addClass("login-block-focused");
	});
	$(".login-block input").focusout(function(){
	  $(this).parent(".login-block").removeClass("login-block-focused");
	});

	//当浏览器窗口高度小于一定时，固定container高度
	$(window).resize(function(){
		var browserHeight =$(window).height();
		if(browserHeight <= 500){
			$(".login_bg").css("height","500px");

		}else{
			$(".login_bg").css("height","100%");
		}
	    //console.log(browserHeight);
	    
	});

	$(".pwd-show-switch").bind("click", function(){
 		if($(this).attr("class").indexOf("filled") != -1){
 			if(9 > judedNavation()){
 				var $pwdInput = $(this).parent(".password_block").find("input");
 				if($pwdInput.attr("type").indexOf("password") != -1){
 					var inputStr = createInput($pwdInput.attr("id"), $pwdInput.attr("name"), "password", "text", $pwdInput.val(),  $pwdInput.attr("class"));
 					$pwdInput.replaceWith($(inputStr));
 					$(this).addClass("open");
 				}else{
 					var inputStr = createInput($pwdInput.attr("id"), $pwdInput.attr("name"), "password", "password", $pwdInput.val(),  $pwdInput.attr("class"));
 					$pwdInput.replaceWith($(inputStr));
 					$(this).removeClass("open");
 				}
 			}else{
 				var $pwd_input = $(this).parent(".password_block").find("input");
		 		if($pwd_input.attr("type") == "password"){
		 			$pwd_input[0].type = "text";
		 			$(this).addClass("open");
		 		}else if($pwd_input.attr("type") == "text"){
					$pwd_input[0].type = "password";
					$(this).removeClass("open");
		 		}else{
		 			$pwd_input[0].type = "password";
		 			$(this).removeClass("open");
	 			}
 			}
 		}
	});

	var beacon = "WPA/WPA2";
	var ssid = "";
	$("#btn_login_step_1").click(function(){
			if ($("#loid").val() == "")
			{
				if ( $("#loid").parent().parent().children().length > 3)
				  	$("#loid").parent().parent().children(":last").remove();			
				$("#loid").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">宽带识别码不能为空！</font></div>");
				return false;
			}
			
			(new XHR()).get('/cgi-bin/luci/admin/regWifiSsid',null,
			function(x,json)
			{
				$("#login_WIFI_SSID").val(json.ssid);
				$("#btn_login_step_2").removeAttr("disabled");
				$(".conf-content").children(":first").find("span").text("天翼网关"+json.productCls);
				$("#conf-status").text("网关正在设置中");
				beacon = json.bType;
				ssid = json.ssid;
				lanip = json.lanIp;
			});	
			
	  		$("#login_setup_1_div").css("display", "none");
			$("#login_setup_2_div").css("display", "");
			showAnimateTip("step2_tip");
		});
		
	$("#btn_login_step_2").click(function(){
	  	  $("#login_setup_1_div").css("display", "none");	
		
			var loid = $("#loid").val();
			var loidPwd = $("#loidPwd").val();
			var wifiSsid = $("#login_WIFI_SSID").val();
			var wifiPwd = $("#login_WIFI_password").val();
			var ch = "";
			
			if ((ssid != wifiSsid) || (wifiPwd.length > 0))
			{
				if ((wifiSsid.length == 0) || (wifiSsid.length > 32))
				{
					if ( $("#login_WIFI_SSID").parent().parent().children().length > 3)
					  	$("#login_WIFI_SSID").parent().parent().children(":last").remove();			
					$("#login_WIFI_SSID").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">WiFi名称长度须在1到32个字符之间</font></div>");				
					return false;
				}
				
				for(var i = 0; i < wifiSsid.length; i++)
				{
					ch = wifiSsid.charAt(i);
					if (!( (ch == '-') || ((ch >= 0) && (ch <= 9)) || ((ch >= 'a') && (ch <= 'z')) || (ch == '_') || ((ch >= 'A')&&(ch <= 'Z')) || (ch=='@')) ) /* 0-9,a-z,A-Z,-,_,@ */
					{
						if ( $("#login_WIFI_SSID").parent().parent().children().length > 3)
						  	$("#login_WIFI_SSID").parent().parent().children(":last").remove();			
						$("#login_WIFI_SSID").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">WiFi名称格式错误，请输入0-9, a-z, A-Z, '-', '_'或'@'</font></div>");				
						
						return false;
					}
				}						
	
				if (beacon == "Basic")
				{
					if ((((wifiPwd.length == 26) || (wifiPwd.length == 10)) && isValidHexKey(wifiPwd, wifiPwd.length)) || (wifiPwd.length == 13) || (wifiPwd.length == 5))
					{
						;
					}
					else
					{				
						if ( $("#login_WIFI_SSID").parent().parent().children().length > 3)
						  	$("#login_WIFI_SSID").parent().parent().children(":last").remove();			
						$("#login_WIFI_SSID").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">无线当前认证方式要求密码输入5个或13个ASCII字符，或者10个或26个十六进制数字</font></div>");				
						return false;	
					}			
				}
				else if (((beacon == "WPA") || (beacon == "WPA2") || (beacon == "WPA/WPA2")) && ((wifiPwd.length < 8) || (wifiPwd.length > 32) || !isValidWPAKey(wifiPwd)))
				{
					if ( $("#login_WIFI_SSID").parent().parent().children().length > 3)
					  	$("#login_WIFI_SSID").parent().parent().children(":last").remove();			
					$("#login_WIFI_SSID").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">无线当前认证方式要求密码应该在8到32个字符之间且不能包含如空格，回车等特殊字符</font></div>");				
					return false;				
				}
		    }
			
			$("#login_setup_2_div").css("display", "none");
			(new XHR()).post('/cgi-bin/luci/admin/settings/setLoid',{ loidvalue: $("#loid").val(), loidpassword : $("#loidPwd").val(), wifissid : $("#login_WIFI_SSID").val(), wifipassword : wifiPwd},
			function(x)
			{
					var retinfo = eval("("+x.responseText+")");
					if(retinfo.retVal == 0)
					{					
						setloidOK = 1;
						stime = 0;

						(new XHR()).post('/cgi-bin/luci/admin/settings/registerLoid',null,
						function(x)
						{
							console.log("registerLoid return");
						});
					}
					else
					{
						setloidOK = 2;
						if (parseInt(retinfo.retVal) > 0)
							stime = parseInt(retinfo.retVal);
						else
							stime = 0;
					}
			});	
			
	        if ( navigator.appName == "Microsoft Internet Explorer" 
				&& ( navigator.appVersion.match(/8./i)=="8." || navigator.appVersion.match(/7./i)=="7."))
	        {
	           $("#login_conf_div").css("display", "");
	        }
	        else
	        {
	           $("#login_conf_div").delay(100).fadeIn(400);
			   roundFadeOut();
			}
			fillConfProcess();				 	
		});	
});

function showAnimateTip(id)
{
	$("#"+id).animate({
	   left: 0 
	}, 500);
}

function showAnimateLine()
{
	var speed=6;
    function Marquee(){
      if(document.getElementById("line2").offsetWidth-document.getElementById("line").scrollLeft<=0)
        document.getElementById("line").scrollLeft-=document.getElementById("line1").offsetWidth;
      else{
        document.getElementById("line").scrollLeft++;
      }
    }
   	setInterval(Marquee,speed);
}

 function roundFadeOut(){
 	$(".round-bg").fadeOut(1500);
 	setTimeout("roundFadeIn()", 2000);
 }

function roundFadeIn(){
 	$(".round-bg").fadeIn(1500);
 	setTimeout("roundFadeOut()", 2000);
}

var intervalSet;
var process = 0;

function getBusinessByResult(business)
{
	var bname = "";
	var detailname = business.split("+");
	var flg = false;
	
	for (var i = 0; i < detailname.length; i++)
	{
		if (detailname[i].toUpperCase() == "INTERNET")
		{
			if (bname.length == 0)
				bname += "上网";
			else
				bname += "，上网";
		}	
		else if (detailname[i].toUpperCase() == "VOIP")
		{
			if (bname.length == 0)
				bname += "语音";
			else
				bname += "，语音";
		}	
		else if ((detailname[i].toUpperCase() == "IPTV") || (detailname[i].toUpperCase() == "ITV"))
		{
			if (bname.length == 0)
				bname += "iTV";
			else
				bname += "，iTV";
		}
		else if (detailname[i].length > 0)
		{
			if (!flg)
			{
				if (bname.length == 0)
					bname += "其它";
				else
					bname += "，其它";
					
				flg = true;
			}						
		}																				
	}
	
	return bname;
}

function fillConfProcess()
{
	console.log("fill configuration process...");
	intervalSet = setInterval("fillNum()", 700);
}
var intervalReg;
var itmsFailFunc;
function fillNum(){
	if(setloidOK == 0 ){  //setloid还没有返回
		if(process < 10){
				$("#conf_process").text(process);
				$(".conf-notice").children(":first").text("正在提交配置信息");
			}
	}
	else{  	//setloid已经返回
		if(setloidOK == 1){ //setloid成功，开始注册
			clearInterval(intervalSet);
			$("#conf_process").text(10);	
			$(".conf-notice").children(":first").text("提交配置信息成功");
			intervalReg = setInterval("fillRegNum()", 3000);	
		}
		else{  //setloid 失败    
			clearInterval(intervalSet);
			$("#refresh_notice").hide();
			if (stime == 0)
			{
				$("#conf_process").text(10);
				$(".conf-notice").children(":first").text("配置信息提交失败");
		  }
		  else
		  	$(".conf-notice").children(":first").text("当前被禁止注册，请等待"+stime+"秒后重试");
			//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 5000);	
		}
	}
	console.log("process="+process);
	process++;
}

var countTimes = 0;
var itmsPercent = 0;
var curRes = 0;
var timeoutFlg = false;
function fillRegNum(){
		console.log("try to check loid = " + countTimes);
	  $.ajax({type: 'GET', url : 'http://' + lanip + '/cgi-bin/luci/admin/settings/regProcess', data: null, dataType: 'jsonp', jsonp: 'callback', jsonpCallback: 'checkLoidStatus', 
	  	success:function(data)
	  	{
	  		console.log("displayLoidStatus");
	  		displayLoidStatus(data);
	  	},
			error:function(){
				console.log("fail");
			}
	  	});
	}

function checkLoidStatus(x)
{
	console.log("checkLoidStatus");
}
	
function displayLoidStatus(x)
{
	    console.log("result = " + x.result + ", msg = " + x.msg);
	    curRes = parseInt(x.result)
			switch (curRes)
			{
				case 200:
					clearInterval(intervalReg);
					$("#conf_process").text(100);
					$("#conf-status").text("网关设置完成");
					$("#refresh_notice").hide();
					var business_name = x.msg.split("=");
					var bname = getBusinessByResult(business_name[3]);
					var bnum = parseInt(business_name[2].split("&")[0]);
					var dnum = "多";
					if (bnum == 0)
						dnum = "零";
					else if (bnum == 1)
						dnum = "一";
					else if (bnum == 2)
						dnum = "两";
					else if (bnum == 3)
						dnum = "三";
					
					if (bnum > 0)						
						$(".conf-notice").children(":first").text("ITMS平台业务数据下发成功，共下发了" + bname + dnum +"个业务，欢迎使用天翼网关");
					else
						$(".conf-notice").children(":first").text("ITMS平台业务数据下发成功，欢迎使用天翼网关");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
					break;
				case 201:
					var procNum = x.msg.split("=");
					var num = parseInt(procNum[2]);	
					if ((num != 20) && (itmsPercent != num))
					{
						timeoutFlg = false;
						clearInterval(itmsFailFunc);
					    itmsFailFunc = setTimeout("itmsFailTimeout()", 180000);
					}
					
					if (!timeoutFlg)
					{					  
						itmsPercent = num;
						if(num == 20)
							$(".conf-notice").children(":first").text("正在注册OLT");
						else if(num == 30)
							$(".conf-notice").children(":first").text("注册OLT成功,正在获取管理IP");
						else if(num == 40)
							$(".conf-notice").children(":first").text("已获得管理IP，正在连接ITMS");
					}
						
					$("#conf_process").text(num);
					break;
        		case 202:
					var split_array = x.msg.split("=");				
					var pctStr = split_array[2];	
					var procNum = pctStr.split("&");				
					var num = parseInt(procNum[0]);
					
					if(num == 50)
						$(".conf-notice").children(":first").text("注册ITMS成功，等待ITMS平台下发业务数据");
					else if (num >= 60 && num <= 99)
					{
						var bname = getBusinessByResult(split_array[3]);
					    $(".conf-notice").children(":first").text("ITMS平台正在下发" + bname +"业务数据,请勿断电或拔光纤");
					}
					
					$("#conf_process").text(num);
					break;
			  	case 203:
					clearInterval(intervalReg);
					$("#conf_process").text(100);
					$("#refresh_notice").hide();
					var business_name = x.msg.split("=");
					var bname = getBusinessByResult(business_name[3]);
					var bnum = parseInt(business_name[2].split("&")[0]);
					var dnum = "多";
					if (bnum == 0)
						dnum = "零";
					else if (bnum == 1)
						dnum = "一";
					else if (bnum == 2)
						dnum = "两";
					else if (bnum == 3)
						dnum = "三";
					
					if (bnum > 0)													
					    $(".conf-notice").children(":first").text("ITMS平台业务数据下发成功，共下发了" + bname + dnum +"个业务，天翼网关需要重启，请等待…");
					else
						  $(".conf-notice").children(":first").text("ITMS平台业务数据下发成功，天翼网关需要重启，请等待…");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);
					break;
			  	case 204:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$(".conf-notice").children(":first").text("ITMS下发业务异常！请联系客户经理或拨打10000");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);
					break;
				case 402:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf_process").text(100);
					$("#conf-status").text("网关设置完成");					
					$(".conf-notice").children(":first").text("已经在ITMS注册成功，无需再注册");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);
					break;								
				case 403:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf-status").text("网关设置超时");
					$(".conf-notice").children(":first").text("在ITMS上注册超时！请检查线路后重试，如无法解决请联系客户经理或拨打10000");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
					break;
				case 404:
				case 406:
				case 408:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf-status").text("网关设置失败");
					$(".conf-notice").children(":first").text("在ITMS上注册失败！请检查宽带识别码和密码是否正确，如无法解决请联系客户经理或拨打10000");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
					break;
				case 405:
				case 407:
				case 409:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf-status").text("网关设置失败");
					$(".conf-notice").children(":first").text("在ITMS上注册失败！请3分钟后重试，如无法解决请联系客户经理或拨打10000");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
					break;
				case 410:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf-status").text("网关设置失败");
					$(".conf-notice").children(":first").text("在OLT上注册失败，请检查光纤是否已正常连接、宽带识别码和密码是否正确，如无法解决请联系客户经理或拨打10000");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
					break;
				case 500:
					clearInterval(intervalReg);
					$("#refresh_notice").hide();
					$("#conf-status").text("网关设置失败");
					$(".conf-notice").children(":first").text("未知原因导致注册失败");
					console.log(location.host);
					//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 5000);	
					break;
				default:
					console.log("Get process failed.");
					break;
			}
			
			if (curRes != 201)
				clearInterval(itmsFailFunc);			
		
		countTimes++;
		if(countTimes > 200){           //超时时间10分钟
			clearInterval(intervalReg);
			$("#refresh_notice").hide();
			$("#conf-status").text("网关设置超时");
			$(".conf-notice").children(":first").text("注册超时，请检查线路后重试，如无法解决请联系客户经理或拨打10000");
			console.log(location.host);
			//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);	
		}
}

function itmsFailTimeout()
{
	timeoutFlg = true;
	clearInterval(intervalReg);
	$("#refresh_notice").hide();
	$("#conf-status").text("网关设置超时");
	$(".conf-notice").children(":first").text("到ITMS的通道不通，请联系客户经理或拨打10000");
	//setTimeout("window.location.href='" + location.protocol + "//" + location.host + "'", 8000);
}

function judedNavation()
{
	if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.match(/6./i)=="6."){ 
		return 6;
	} 
	else if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.match(/7./i)=="7."){ 
		return 7;
	} 
	else if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.match(/8./i)=="8."){ 
		return 8;
	} 
	else if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.match(/9./i)=="9."){ 
		return 9;
	}
	else{
		return 10;
	}
}


function createInput(id, name, placeholder, type, value, classname)
{
	var inputObj = "<input ";
	inputObj += "id='" + id + "' ";
	inputObj += "class='" + classname + "' ";
	inputObj += "name='" + name + "' ";
	inputObj += "placeholder='" + placeholder + "' ";
	inputObj += "type='" + type + "' ";
	inputObj += "value='" + value + "' ";
	inputObj += ">";
	return inputObj;
}
