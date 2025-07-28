//javascript for login.html
var isEmpty = true;
var gLoginFlag = 0;
var bType = BrowserType();
var jumpage = false;

$(document).ready(function(){
	if (window != top)
		top.location.href = "/cgi-bin/luci";
	
	//change the stylesheet of login
	if ((bType != "IE8") && !jumpage)
	{
		console.log("Current broswer is " + bType);
		showAnimateLine();
	}
	showAnimateTip("login_tip");

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
	    console.log(browserHeight)
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

function checkPassword()
{
	if ($("#login_password").val().length < 5)
	{
		if ( $("#login_username").parent().parent().children().length > 2)
		  	$("#login_username").parent().parent().children(":last").remove();
	    $("#login_username").parent().parent().children(":last").after("<div><font face=\"宋体\" style=\"font-size: 14px; color:#aaa\">密码长度必须大于等于五个字符</font></div>");

		return false;
	}

	$("#login_username").val("useradmin");

	return true;
}
