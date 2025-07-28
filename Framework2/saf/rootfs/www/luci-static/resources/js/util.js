var WEB_POLL_INTERVAL=5;

window.console = window.console || (function(){   
    var c = {}; c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile   
    = c.clear = c.exception = c.trace = c.assert = function(){};   
    return c;   
})();  

function isIE7Browser()
{
	if(navigator.appName == "Microsoft Internet Explorer" && navigator.appVersion.match(/7./i)=="7.") 
	{ 
		return true;
	}
	else
	{
		return false;
	}
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


function createInput(id, name, placeholder, maxlength, type, value)
{
	var inputObj = "<input ";
	if ( id != "" && id != "undefined" )
	{
		inputObj += "id='" + id + "' ";
	}
	if ( name != "" && name != "undefined" )
	{
		inputObj += "name='" + name + "' ";
	}
	if ( placeholder != "" && placeholder != "undefined" )
	{
		inputObj += "placeholder='" + placeholder + "' ";
	}
	if ( maxlength != "" && maxlength != "undefined" )
	{
		inputObj += "maxlength='" + maxlength + "' ";
	}
	inputObj += "type='" + type + "' ";
	inputObj += "value='" + value + "' ";
	inputObj += ">";
	return inputObj;
}

function inputBindFocus()
{
	$("input[type='password'], .password_content input[type='text']").bind("focusin", function(){
		$(this).parent().eq(0).addClass("password_content_focus");
		if ( !$(this).next().hasClass("password_switch_eyeon") )
		{
		$(this).next().addClass("password_switch_focus");
		}
	});
	$("input[type='password'], .password_content input[type='text']").bind("focusout", function(){
		$(this).parent().eq(0).removeClass("password_content_focus");
		$(this).next().removeClass("password_switch_focus");
	});
}

function customSwitchInit()
{
	$(".switch_content").bind("click", function(){
		if($(this).hasClass("switch_content_on")){
			$(this).removeClass("switch_content_on");
			$(this).addClass("switch_content_off");
			$(this).children("span").html("OFF&nbsp;");
			$("#" + $(this).attr("id") + "_value").val(0);
		}else{
			$(this).addClass("switch_content_on");
			$(this).removeClass("switch_content_off");
			$(this).children("span").html("&nbsp;ON");
			$("#" + $(this).attr("id") + "_value").val(1);
		}
		console.log($("#" + $(this).attr("id") + "_value").val());
	});
}
function customSelectInit()
{
	$(".select-arrow").click(function(){
		$(this).parent().addClass("select-open");
  	});

	//如果鼠标向下滑动，则不隐藏
	$(".dropdown-select").bind("mouseleave", 
			function(e) 
			{ 
				var w = $(this).width(); 
				var h = $(this).height(); 
				var x = (e.pageX - this.offsetLeft - (w / 2)) * (w > h ? (h / w) : 1); 
				var y = (e.pageY - this.offsetTop - (h / 2)) * (h > w ? (w / h) : 1); 
				var direction = Math.round((((Math.atan2(y, x) * (180 / Math.PI)) + 180) / 90) + 3) % 4; 
				if(direction != 2)
				{	
					$(this).removeClass("select-open");
				}
	}); 

	$(".dropdown-menu-select").mouseleave(function(){
    	$(this).parent().removeClass("select-open");
	});

	$(".dropdown-menu-select li").click(function(){
		$(this).parent().siblings("label").first().text($(this).text());
		$("#" + $(this).parent().attr("id") + "_value").val($(this).attr("livalue"));
		$(this).parent().parent().removeClass("select-open");;
	});
}
function customPasswordInit()
{
	inputBindFocus();
	$(".password_switch").bind("click", function(){
		if( $(this).css("background-image").indexOf("eye_close") > -1 )
		{
			$(this).removeClass("password_switch_unfocus");
			$(this).removeClass("password_switch_focus");
			$(this).addClass("password_switch_eyeon");
		}
		else
		{
			$(this).removeClass("password_switch_eyeon");
			$(this).addClass("password_switch_unfocus");
		}
		
		if( 9 > judedNavation() )
		{
			var $pwdInput = $(this).parent(".password_content").find("input");
			if($pwdInput.attr("type").indexOf("password") != -1){
				var inputStr = createInput($pwdInput.attr("id"), $pwdInput.attr("name"), $pwdInput.attr("placeholder"), $pwdInput.attr("maxlength"), "text", $pwdInput.val());
				$pwdInput.replaceWith($(inputStr));
			}else{
				var inputStr = createInput($pwdInput.attr("id"), $pwdInput.attr("name"), $pwdInput.attr("placeholder"), $pwdInput.attr("maxlength"), "password", $pwdInput.val());
				$pwdInput.replaceWith($(inputStr));
			}
		}
		else
		{
			var $pwd_input = $(this).parent(".password_content").find("input");
			if($pwd_input.attr("type") == "password"){
				$pwd_input[0].type = "text";
			}else if($pwd_input.attr("type") == "text"){
				$pwd_input[0].type = "password";
			}else{
				$pwd_input[0].type = "password";
			}
		}
		inputBindFocus();
	});
}
function customScrollBar(ele)
{
	$(ele).niceScroll({  
		cursorcolor:"#38b992",
		cursoropacitymin:1,
		cursoropacitymax:1,
		touchbehavior:false,
		cursorwidth:"5px",
		cursorborder:"0",
		cursorborderradius:"5px",
		disableoutline:true
	});
}
function isHexaDigit(digit) {
   var hexVals = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                           "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f");
   var len = hexVals.length;
   var i = 0;
   var ret = false;

   for ( i = 0; i < len; i++ )
      if ( digit == hexVals[i] ) break;

   if ( i < len )
      ret = true;

   return ret;
}

function isValidKey(val, size) {
   var ret = false;
   var len = val.length;
   var dbSize = size * 2;

   if ( len == size )
      ret = true;
   else if ( len == dbSize ) {
      for ( i = 0; i < dbSize; i++ )
         if ( isHexaDigit(val.charAt(i)) == false )
            break;
      if ( i == dbSize )
         ret = true;
   } else
      ret = false;

   return ret;
}


function isValidHexKey(val, size) {
   var ret = false;
   if (val.length == size) {
      for ( i = 0; i < val.length; i++ ) {
         if ( isHexaDigit(val.charAt(i)) == false ) {
            break;
         }
      }
      if ( i == val.length ) {
         ret = true;
      }
   }

   return ret;
}


function isNameUnsafe(compareChar) {
   var unsafeString = "\"<>%\\^[]`\+\$\,='#&@.: \t";
	
   if ( unsafeString.indexOf(compareChar) == -1 && compareChar.charCodeAt(0) > 32
        && compareChar.charCodeAt(0) < 123 )
      return false; // found no unsafe chars, return false
   else
      return true;
}   

// Check if a name valid
function isValidName(name) {
   var i = 0;	
   
   for ( i = 0; i < name.length; i++ ) {
      if ( isNameUnsafe(name.charAt(i)) == true )
         return false;
   }

   return true;
}

// same as is isNameUnsafe but allow spaces
function isCharUnsafe(compareChar) {
   var unsafeString = "\"<>%\\^[]`\+\$\,=#&@:\t";
	
   if ( unsafeString.indexOf(compareChar) == -1 && compareChar.charCodeAt(0) >= 32
        && compareChar.charCodeAt(0) < 123 )
      return false; // found no unsafe chars, return false
   else
      return true;
}   

// Check filename valid
function isValidFileName(name) {
   var i = 0;
   var ch = "";

   for ( i = 0; i < name.length; i++ ) {
   	  ch = name.charAt(i);
      if ( isCharUnsafe(name.charAt(i)) && ((ch.charCodeAt(0) < 0x4e00) || (ch.charCodeAt(0) > 0x9fa5)))
         return false;
   }

   return true;
}

function isValidNameWSpace(name) {
   var i = 0;	
   
   for ( i = 0; i < name.length; i++ ) {
      if ( isCharUnsafe(name.charAt(i)) == true )
         return false;
   }

   return true;
}

function isSameSubNet(lan1Ip, lan1Mask, lan2Ip, lan2Mask) {

   var count = 0;
   
   lan1a = lan1Ip.split('.');
   lan1m = lan1Mask.split('.');
   lan2a = lan2Ip.split('.');
   lan2m = lan2Mask.split('.');

   for (i = 0; i < 4; i++) {
      l1a_n = parseInt(lan1a[i]);
      l1m_n = parseInt(lan1m[i]);
      l2a_n = parseInt(lan2a[i]);
      l2m_n = parseInt(lan2m[i]);
      if ((l1a_n & l1m_n) == (l2a_n & l2m_n))
         count++;
   }
   if (count == 4)
      return true;
   else
      return false;
}

function isSameSubNetVer2(srcaddr1, mask, endsrcaddr1, mask)
{
  pArray1 = srcaddr1.split(".");
  pArray2 = endsrcaddr1.split(".");
  if( (pArray1[0] == pArray2[0]) && (pArray1[1] == pArray2[1]) && (pArray1[2] == pArray2[2]))
  {
  	return true;
  }
  else {
  	return false;
  }
}


function isValidIpAddress(address) {

   ipParts = address.split('/');
   if (ipParts.length > 2) return false;
   if (ipParts.length == 2) {
      num = parseInt(ipParts[1]);
      if (num <= 0 || num > 32)
         return false;
   }
   if (ipParts[0] == '0.0.0.0' ||
       ipParts[0] == '255.255.255.255' )
      return false;

   addrParts = ipParts[0].split('.');
   if ( addrParts.length != 4 ) return false;
        
   for (i = 0; i < 4; i++) {
      if (isNaN(addrParts[i]) || addrParts[i] =="")
         return false;
      num = parseInt(addrParts[i]);
      if ( num < 0 || num > 255 )
         return false;
   }
   return true;
}

function isValidIpv6PrefixAddress(address) {
	var i = 0, num = 0, space=0;
	
	addrParts = address.split(':');
	if (addrParts.length < 3 || addrParts.length > 8)
		return false;
	for (i = 0; i < addrParts.length; i++) 
	{
		if ( addrParts[i] != "" && isValidHexKey(addrParts[i], addrParts[i].length) )
			num = parseInt(addrParts[i], 16);
		else
		{
			space++;
			if(space>1 && (i + 1) != addrParts.length)
			return false;
			continue;
		}
		if ( i == 0 ) 
		{
			if ( (num & 0xf000) == 0xf000 )
				return false;   //can not be link-local, site-local or multicast address
		}

		if ( num > 0xffff || num < 0 )
			return false;
	}
	return true;
}

function isValidIpv6AddressRegexp(str)  
{  
	if(null == str.match(/:/g))
		return false;
		
	return str.match(/:/g).length<=7  
	&&/::/.test(str)  
	?/^([\da-f]{1,4}(:|::)){1,6}[\da-f]{1,4}$/i.test(str)  
	:/^([\da-f]{1,4}:){7}[\da-f]{1,4}$/i.test(str);  
}

function isIPv6(str)  
{  
	return str.match(/:/g).length<=7  
	&&/::/.test(str)  
	?/^([\da-f]{1,4}(:|::)){1,6}[\da-f]{1,4}$/i.test(str)  
	:/^([\da-f]{1,4}:){7}[\da-f]{1,4}$/i.test(str);  
}

function isValidIpv6PrefixAddressV2(prefix)
{
	return /([0-9a-fA-F]{1,4}:){1,4}:\/64/.test(prefix);
}

function isValidIpv6PrefixAddress(address) {
	var i = 0, num = 0, space=0;
	
	addrParts = address.split(':');
	if (addrParts.length < 3 || addrParts.length > 8)
		return false;
	for (i = 0; i < addrParts.length; i++) 
	{
		if ( addrParts[i] != "" && isValidHexKey(addrParts[i], addrParts[i].length) )
			num = parseInt(addrParts[i], 16);
		else
		{
			space++;
			if(space>1 && (i + 1) != addrParts.length)
			return false;
			continue;
		}
		if ( i == 0 ) 
		{
			if ( (num & 0xf000) == 0xf000 )
				return false;   //can not be link-local, site-local or multicast address
		}

		if ( num > 0xffff || num < 0 )
			return false;
	}
	return true;
}

function isValidIpAddress6(address) {

   ipParts = address.split('/');
   if (ipParts.length > 2) return false;
   if (ipParts.length == 2) {
      num = parseInt(ipParts[1]);
      if (num <= 0 || num > 128)
         return false;
   }

   addrParts = ipParts[0].split(':');
   if (addrParts.length < 3 || addrParts.length > 8)
      return false;
   for (i = 0; i < addrParts.length; i++) {
      if ( addrParts[i] != "" )
         num = parseInt(addrParts[i], 16);
      if ( i == 0 ) {
//         if ( (num & 0xf000) == 0xf000 )
//            return false;	//can not be link-local, site-local or multicast address
      }
      else if ( (i + 1) == addrParts.length) {
         if ( num == 0 || num == 1)
            return false;	//can not be unspecified or loopback address
      }
      if ( num != 0 )
         break;
   }
   return true;
}

function isValidPrefixLength(prefixLen) {
   var num;

   num = parseInt(prefixLen);
   if (isNaN(num) || num <= 0 || num > 128)
      return false;
   return true;
}

function areSamePrefix(addr1, addr2) {
   var i, j;
   var a = [0, 0, 0, 0, 0, 0, 0, 0];
   var b = [0, 0, 0, 0, 0, 0, 0, 0];

   addr1Parts = addr1.split(':');
   if (addr1Parts.length < 3 || addr1Parts.length > 8)
      return false;
   addr2Parts = addr2.split(':');
   if (addr2Parts.length < 3 || addr2Parts.length > 8)
      return false;
   j = 0;
   for (i = 0; i < addr1Parts.length; i++) {
      if ( addr1Parts[i] == "" ) {
		 if ((i != 0) && (i+1 != addr1Parts.length)) {
			j = j + (8 - addr1Parts.length + 1);
		 }
		 else {
		    j++;
		 }
	  }
	  else {
         a[j] = parseInt(addr1Parts[i], 16);
		 j++;
	  }
   }
   j = 0;
   for (i = 0; i < addr2Parts.length; i++) {
      if ( addr2Parts[i] == "" ) {
		 if ((i != 0) && (i+1 != addr2Parts.length)) {
			j = j + (8 - addr2Parts.length + 1);
		 }
		 else {
		    j++;
		 }
	  }
	  else {
         b[j] = parseInt(addr2Parts[i], 16);
		 j++;
	  }
   }
   //only compare 64 bit prefix
   for (i = 0; i < 4; i++) {
      if (a[i] != b[i]) {
	     return false;
	  }
   }
   return true;
}

function getLeftMostZeroBitPos(num) {
   var i = 0;
   var numArr = [128, 64, 32, 16, 8, 4, 2, 1];

   for ( i = 0; i < numArr.length; i++ )
      if ( (num & numArr[i]) == 0 )
         return i;

   return numArr.length;
}

function getRightMostOneBitPos(num) {
   var i = 0;
   var numArr = [1, 2, 4, 8, 16, 32, 64, 128];

   for ( i = 0; i < numArr.length; i++ )
      if ( ((num & numArr[i]) >> i) == 1 )
         return (numArr.length - i - 1);

   return -1;
}

function isValidSubnetMask(mask) {
   var i = 0, num = 0;
   var zeroBitPos = 0, oneBitPos = 0;
   var zeroBitExisted = false;

   if ( mask == '0.0.0.0' )
      return false;

   maskParts = mask.split('.');
   if ( maskParts.length != 4 ) return false;

   for (i = 0; i < 4; i++) {
      if ( isNaN(maskParts[i]) == true )
         return false;
      num = parseInt(maskParts[i]);
      if ( num < 0 || num > 255 )
         return false;
      if ( zeroBitExisted == true && num != 0 )
         return false;
      zeroBitPos = getLeftMostZeroBitPos(num);
      oneBitPos = getRightMostOneBitPos(num);
      if ( zeroBitPos < oneBitPos )
         return false;
      if ( zeroBitPos < 8 )
         zeroBitExisted = true;
   }

   return true;
}

function isBroadcastIp(ipAddress, subnetMask)
{
	 var maskLenNum = 0;
	 tmpMask = subnetMask.split('.');
	 tmpIp = ipAddress.split('.');

	 if((parseInt(tmpIp[0]) > 223) || ( 127 == parseInt(tmpIp[0])))
	 {
		 return true;
	 }

	 for(maskLenNum = 0; maskLenNum < 4; maskLenNum++)
	 {
		 if(parseInt(tmpMask[maskLenNum]) < 255)
			break;
	 }

	 tmpNum0 = parseInt(tmpIp[maskLenNum]);
	 tmpNum1 = 255 - parseInt(tmpMask[maskLenNum]);
	 tmpNum2 = tmpNum0 & tmpNum1;
	 if((tmpNum2 != 0) && (tmpNum2 != tmpNum1))
	 {
		 return false;
	 }

	 if(maskLenNum == 3)
	 {
		 return true;
	 }
	 else if(maskLenNum == 2)
	 {
		 if(((tmpIp[3] == 0)&&(tmpNum2 == 0))||
			 ((tmpIp[3] == 255)&&(tmpNum2 == tmpNum1)))
		 {
			 return true;
		 }
	 }
	 else if(maskLenNum == 1)
	 {
		 if(((tmpNum2 == 0)&&(tmpIp[3] == 0)&&(tmpIp[2] == 0)) ||
			 ((tmpNum2 == tmpNum1)&&(tmpIp[3] == 255)&&(tmpIp[2] == 255)))
		 {
			 return true;
		 }
	 }
	 else if(maskLenNum == 0)
	 {
		 if(((tmpNum2 == 0)&&(tmpIp[3] == 0)&&(tmpIp[2] == 0)&&(tmpIp[1] == 0)) ||
			 ((tmpNum2 == tmpNum1)&&(tmpIp[3] == 255)&&(tmpIp[2] == 255) &&(tmpIp[1] == 255)))
		 {
			 return true;
		 }
	 }

	 return false;

}

function isValidPortRange(port) {
   var fromport = 0;
   var toport = 100;

   portrange = port.split(':');
   if ( portrange.length < 1 || portrange.length > 2 ) {
       return false;
   }
   if ( isNaN(portrange[0]) )
       return false;
   fromport = parseInt(portrange[0]);
   
   if ( portrange.length > 1 ) {
       if ( isNaN(portrange[1]) )
          return false;
       toport = parseInt(portrange[1]);
       if ( toport <= fromport )
           return false;      
   }
   
   if ( fromport < 1 || fromport > 65535 || toport < 1 || toport > 65535 )
       return false;
   
   return true;
}

function isValidNatPort(port) {
   var fromport = 0;
   var toport = 100;

   portrange = port.split('-');
   if ( portrange.length < 1 || portrange.length > 2 ) {
       return false;
   }
   if ( isNaN(portrange[0]) )
       return false;
   fromport = parseInt(portrange[0]);

   if ( portrange.length > 1 ) {
       if ( isNaN(portrange[1]) )
          return false;
       toport = parseInt(portrange[1]);
       if ( toport <= fromport )
           return false;
   }

   if ( fromport < 1 || fromport > 65535 || toport < 1 || toport > 65535 )
       return false;

   return true;
}

function isValidMacAddress(address) {
   var c = '';
   var num = 0;
   var i = 0, j = 0;
   var zeros = 0;

   addrParts = address.split(':');
   if ( addrParts.length != 6 ) return false;

   for (i = 0; i < 6; i++) {
      if ( addrParts[i] == '' )
         return false;
      for ( j = 0; j < addrParts[i].length; j++ ) {
         c = addrParts[i].toLowerCase().charAt(j);
         if ( (c >= '0' && c <= '9') ||
              (c >= 'a' && c <= 'f') )
            continue;
         else
            return false;
      }

      num = parseInt(addrParts[i], 16);
      if ( num == NaN || num < 0 || num > 255 )
         return false;
      if ( num == 0 )
         zeros++;
   }
   if (zeros == 6)
      return false;
      
   if ( parseInt(addrParts[0], 16) & 1 )	  
      return false;

   return true;
}

function isValidMacMask(mask) {
   var c = '';
   var num = 0;
   var i = 0, j = 0;
   var zeros = 0;
   var zeroBitPos = 0, oneBitPos = 0;
   var zeroBitExisted = false;

   maskParts = mask.split(':');
   if ( maskParts.length != 6 ) return false;

   for (i = 0; i < 6; i++) {
      if ( maskParts[i] == '' )
         return false;
      for ( j = 0; j < maskParts[i].length; j++ ) {
         c = maskParts[i].toLowerCase().charAt(j);
         if ( (c >= '0' && c <= '9') ||
              (c >= 'a' && c <= 'f') )
            continue;
         else
            return false;
      }

      num = parseInt(maskParts[i], 16);
      if ( num == NaN || num < 0 || num > 255 )
         return false;
      if ( zeroBitExisted == true && num != 0 )
         return false;
      if ( num == 0 )
         zeros++;
      zeroBitPos = getLeftMostZeroBitPos(num);
      oneBitPos = getRightMostOneBitPos(num);
      if ( zeroBitPos < oneBitPos )
         return false;
      if ( zeroBitPos < 8 )
         zeroBitExisted = true;
   }
   if (zeros == 6)
      return false;

   return true;
}

var hexVals = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
              "A", "B", "C", "D", "E", "F");
var unsafeString = "\"<>%\\^[]`\+\$\,'#&";
// deleted these chars from the include list ";", "/", "?", ":", "@", "=", "&" and #
// so that we could analyze actual URLs

function isUnsafe(compareChar)
// this function checks to see if a char is URL unsafe.
// Returns bool result. True = unsafe, False = safe
{
   if ( unsafeString.indexOf(compareChar) == -1 && compareChar.charCodeAt(0) > 32
        && compareChar.charCodeAt(0) < 123 )
      return false; // found no unsafe chars, return false
   else
      return true;
}

function decToHex(num, radix)
// part of the hex-ifying functionality
{
   var hexString = "";
   while ( num >= radix ) {
      temp = num % radix;
      num = Math.floor(num / radix);
      hexString += hexVals[temp];
   }
   hexString += hexVals[num];
   return reversal(hexString);
}

function reversal(s)
// part of the hex-ifying functionality
{
   var len = s.length;
   var trans = "";
   for (i = 0; i < len; i++)
      trans = trans + s.substring(len-i-1, len-i);
   s = trans;
   return s;
}

function convert(val)
// this converts a given char to url hex form
{
   return  "%" + decToHex(val.charCodeAt(0), 16);
}


function encodeUrl(val)
{
   var len     = val.length;
   var i       = 0;
   var newStr  = "";
   var original = val;

   for ( i = 0; i < len; i++ ) {
      if ( val.substring(i,i+1).charCodeAt(0) < 255 ) {
         // hack to eliminate the rest of unicode from this
         if (isUnsafe(val.substring(i,i+1)) == false)
            newStr = newStr + val.substring(i,i+1);
         else
            newStr = newStr + convert(val.substring(i,i+1));
      } else {
         // woopsie! restore.
         alert ("Found a non-ISO-8859-1 character at position: " + (i+1) + ",\nPlease eliminate before continuing.");
         newStr = original;
         // short-circuit the loop and exit
         i = len;
      }
   }

   return newStr;
}

var markStrChars = "\"'";

// Checks to see if a char is used to mark begining and ending of string.
// Returns bool result. True = special, False = not special
function isMarkStrChar(compareChar)
{
   if ( markStrChars.indexOf(compareChar) == -1 )
      return false; // found no marked string chars, return false
   else
      return true;
}

// use backslash in front one of the escape codes to process
// marked string characters.
// Returns new process string
function processMarkStrChars(str) {
   var i = 0;
   var retStr = '';

   for ( i = 0; i < str.length; i++ ) {
      if ( isMarkStrChar(str.charAt(i)) == true )
         retStr += '\\';
      retStr += str.charAt(i);
   }

   return retStr;
}

// Web page manipulation functions

function showhide(element, sh)
{
    var status;
    if (sh == 1) {
        status = "block";
    }
    else {
        status = "none";
    }
    
	if (document.getElementById)
	{
		// standard
		document.getElementById(element).style.display = status;
	}
	else if (document.all)
	{
		// old IE
		document.all[element].style.display = status;
	}
	else if (document.layers)
	{
		// Netscape 4
		document.layers[element].display = status;
	}
}

// Load / submit functions

function getSelect(item)
{
	var idx;
	if (item.options.length > 0) {
	    idx = item.selectedIndex;
	    return item.options[idx].value;
	}
	else {
		return '';
    }
}

function setSelect(item, value)
{
	for (i=0; i<item.options.length; i++) {
        if (item.options[i].value == value) {
        	item.selectedIndex = i;
        	break;
        }
    }
}

function setCheck(item, value)
{
    if ( value == '1' ) {
         item.checked = true;
    } else {
         item.checked = false;
    }
}

function setDisable(item, value)
{
    if ( value == 1 || value == '1' ) {
         item.disabled = true;
    } else {
         item.disabled = false;
    }     
}

function submitText(item)
{
	return '&' + item.name + '=' + item.value;
}

function submitSelect(item)
{
	return '&' + item.name + '=' + getSelect(item);
}


function submitCheck(item)
{
	var val;
	if (item.checked == true) {
		val = 1;
	} 
	else {
		val = 0;
	}
	return '&' + item.name + '=' + val;
}

function isInValidDhcpPool(lan1StartIp, lan1EndIp,lan2StartIp, lan2EndIp )
{
   lan1addrEnd = lan1EndIp.split('.');
   lan1addrStart = lan1StartIp.split('.');
   lan2addrEnd = lan2EndIp.split('.');
   lan2addrStart = lan2StartIp.split('.');
   E1 = parseInt(lan1addrEnd[3]) + 1;
   S1 = parseInt(lan1addrStart[3]) + 1;
   E2 = parseInt(lan2addrEnd[3]) + 1;
   S2 = parseInt(lan2addrStart[3]) + 1;

   if (E1 > S2 && E1 < E2)
       return false;
   if (S1 > S2 && S1 < E2)
       return false;
   if (S2 > S1 && S2 < E1)
       return false;
   if (E2 > S1 && E2 < E1)
       return false;
   return true;
}

function isValidIpAddress_dhcpDevice(address){
   var i = 0;

   if ( address == '255.255.255.255' )
      return false;

   addrParts = address.split('.');
   if ( addrParts.length != 4 ) return false;
   for (i = 0; i < 4; i++) {
      if (isNaN(addrParts[i]) || addrParts[i] =="")
         return false;
      num = parseInt(addrParts[i]);
      if ( num < 0 || num > 255 )
         return false;
   }
   return true;
}

function isValidDigit(digit) {
   var hexVals = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
   var len = hexVals.length;
   var i = 0;
   var ret = false;

   for ( i = 0; i < len; i++ )
      if ( digit == hexVals[i] ) break;

   if ( i < len )
      ret = true;

   return ret;
}

function isValidServerPort(val){
   var ret = false;
   var max = 65535;
   var min = 0;
   var i = 0;

   if((val.length > 1) &&(val.charAt(0) == '0'))
   {
			return false;
   }

   for(i;i<val.length;i++)
   {
      if ( isValidDigit(val.charAt(i)) == false )
        break;
   }
   if ( i == val.length )
   {
       ret = true;
   }

   if(ret == true)
   {
   	   if (( val <= max) &&( val >= min))
	         ret = true;
	     else
	        ret = false;
   }

   return ret;
}

function isValidValue(val)
{
   var ret = false;
   var min = 0;
   var i=0;

   if((val.length > 1) &&(val.charAt(0) == '0'))
   {
			return false;
   }

   for(i;i<val.length;i++)
   {
      if ( isValidDigit(val.charAt(i)) == false )
        break;
   }
   if ( i == val.length )
   {
       ret = true;
   }

   if(ret == true)
   {
        if (val > min)
        {
            ret = true;
        }
        else
        {
            ret = false;
        }
   }
   return ret;
}

function isNumber( val )
{
	var len = val.length;
	var sign = 0;
	
	for( var i = 0; i < len; ++i )
	{
		if( ( val.charAt(i) == '-' ) && ( sign == 0 ) )
		{
			sign = 1;
			continue;
		}
		
		if( ( val.charAt(i) > '9' ) 
		    || ( val.charAt(i) < '0' ) )
		{
			return false;
		}
		sign = 1;
	}
	
	return true;
}

function IsNotDigit(fData)
{
     var i;

	 for(i = 0; i < fData.length; i++) 
	 {
		if (!(fData.charAt(i) >= '0' && fData.charAt(i) <= '9'))
			return true;
	 }
	
	 return false;
}

function isValidNetMask(address) {

   ipParts = address.split('/');
   if (ipParts.length > 2) return false;
   if (ipParts.length == 2) {
      num = parseInt(ipParts[1]);
      if (num <= 0 || num > 32)
         return false;
   }

   if (ipParts[0] == '0.0.0.0' ||
       ipParts[0] == '255.255.255.255' )
      return false;

   addrParts = ipParts[0].split('.');
   if ( addrParts.length != 4 ) return false;
   for (i = 0; i < 4; i++) {
      if (isNaN(addrParts[i]) || addrParts[i] =="")
         return false;
      num = parseInt(addrParts[i]);
      if ( num < 0 || num > 255 )
         return false;
   }
   return true;
}


function isValidIpAddress_dhcpDevice(address){
   var i = 0;

   if ( address == '255.255.255.255' )
      return false;

   addrParts = address.split('.');
   if ( addrParts.length != 4 ) return false;
   for (i = 0; i < 4; i++) {
      if (IsNotDigit(addrParts[i]) || addrParts[i] =="")
         return false;
      
      num = parseInt(addrParts[i]);
      if (i == 0 && num == 0)
      {
          return false;
      }
      if ( num < 0 || num >= 255 )
         return false;
   }
   if(parseInt(addrParts[3]) == 0)
   	return false;
   return true;
}

function isValidPrefixAddress(address) {
   var i = 0, num = 0;
   var space=0;
   addrParts = address.split(':');
   if (addrParts.length < 3 || addrParts.length > 8)
      return false;
   for (i = 0; i < addrParts.length; i++) {
      if ( addrParts[i] != "" && isValidHexKey(addrParts[i],addrParts[i].length) )
         num = parseInt(addrParts[i], 16);
	  else
	   {
		  space++;
		  if(space>1 && (i + 1) != addrParts.length)
		  return false;
		  continue;
	   }
      if ( i == 0 ) {
         if ( (num & 0xf000) == 0xf000 )
            return false;	
      }
      if ( num > 0xffff || num < 0 )
         return false;
   }
   return true;
}

/*Get row numbers from valueslsit whose delimiter is rowD*/
function numOfRow(valuelist, rowDelimiter){
	if(typeof(rowD) == 'undefined')
		rowD= '|';

	var numR = 0;
	if(valuelist != ''){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}
		numR = tnodes.length - 2; // not include parameter name line/row
		return numR;
	}

	return numR;
}

function numOfRow_New(valuelist, rowDelimiter){
	if(typeof(rowD) == 'undefined')
		rowD= '|';

	var numR = 0;
	if(valuelist != ''){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}
		numR = tnodes.length - 1; // not include parameter name line/row
		return numR;
	}

	return numR;
}

/*Get column numbers from valueslsit whose row's delimiter is rowD and colum's delimiter is colD*/
function numOfCol(valuelist, rowD, colD){
	if(typeof(rowD) == 'undefined')
		rowD = '|';
	if(typeof(colD) == 'undefined')
		colD = '/';
	
	var numC = 0;
	if(valuelist != ''){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}
		if (tnodes.length > 0){
			if (colD != ''){
				var tdata = tnodes[0].split(colD);// only need check row[0]'s column number
				numC = tdata.length - 1;
			}
		}
		return numC;
	}
	return numC;
}

function getParamNum( valuelist, colNum, rowD, colD ){
	var i;     
	if(valuelist != ''){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}

		var row = numOfRow(valuelist, rowD);
		var names = tnodes[row].split(colD);
		for ( i = 0; i < names.length; i++ ){
			if ( names[i] == colNum ){
				return i;
			}
		}
	}
	return -1;
}

/*Get specific parameter value from valueslsit whose row's delimiter is rowD and colum's is colD and rowid is rowNum & colid is colNum */
function getValueFromList(valuelist, colNum, rowNum, rowD, colD){
	if(typeof(rowD) == 'undefined')
		rowD = '|';
	if(typeof(colD) == 'undefined')
		colD = '/';
	if(typeof(rowNum) == 'undefined')
		rowNum = 0;

	var n;
	if ( isNaN(colNum) ) 
		n = getParamNum(valuelist, colNum, rowD, colD);		
	else
		n = colNum;
      
	var mName = new Array();
	if(valuelist != '' && n != -1){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}

		var tdata = tnodes[rowNum].split(colD);
		(tdata[n]) ? mName = tdata[n]: mName = '';
         
		return mName;
	}
	return mName;
}

/*Get colid is colNum's paramer values from valueslsit whose row's delimiter is rowD and colum's is colD */
function getColFromList(valuelist, colNum, rowD, colD){
	if(typeof(rowD) == 'undefined')
		rowD = '|';
	if(typeof(colD) == 'undefined')
		colD = '/';

	var n;
	if ( isNaN(colNum) ) 
		n = getParamNum(valuelist, colNum, rowD, colD);
	else
		n = colNum;

	var mName = new Array();
	if(valuelist != ''){
		if (rowD != ''){
			var tnodes = valuelist.split(rowD);
		}else{
			var tnodes = valuelist;
		}
		for ( i = 0; i < tnodes.length -1; i++ ){ 
			var tdata = tnodes[i].split(colD);
			(tdata[n]) ? mName[i] = tdata[n]: mName[i] = '';
		}
		return mName;
	}
	return mName;
}



function getIpMaskBit(mask) {
   var i = 0, num = 0;
   var oneBitPos = 0;
   
   if ( isValidSubnetMask(mask) == false)
	 return -1;

   maskParts = mask.split('.');
   for (i = 0; i < 4; i++) {
      num = parseInt(maskParts[i]);
      oneBitPos = getRightMostOneBitPos(num);
	if(oneBitPos < 7){
		return i*8 + oneBitPos + 1;
	}
   }
   return 32;
}

function markDscpToName(mark){
   var i;
   var dscpMarkDesc = new Array ('auto', 'default', 'AF13', 'AF12', 'AF11', 'CS1',
                           'AF23', 'AF22', 'F21', 'S2',
                           'AF33', 'AF32', 'AF31', 'CS3',
                           'AF43', 'AF42', 'AF41', 'CS4',
                           'EF', 'CS5', 'CS6', 'CS7', '');
   var dscpMarkValues = new Array(-2, 0x00, 0x38, 0x30, 0x28, 0x20,
                             0x58, 0x50, 0x48, 0x40,
                             0x78, 0x70, 0x68, 0x60,
                             0x98, 0x90, 0x88, 0x80,
                             0xB8, 0xA0, 0xC0, 0xE0);
   if(mark == -1)
   	return '';
   for (i = 0; dscpMarkDesc[i] != ''; i++)
   {
      if (mark == dscpMarkValues[i])
         return dscpMarkDesc[i];
   }
   return dscpMarkDesc[0];
}

 function String_Replace(expression, find, replacewith, start) {
  var index = expression.indexOf(find, start);
  if (index == -1)
   return expression;

  var findLen = find.length;
  var newexp = "";
  newexp = expression.substring(0, index)+(replacewith)+(expression.substring(index+findLen));

  return String_Replace(newexp, find, replacewith, index+1+findLen);
 }
 

function SsidisIncludeInvalidChar(val) {
   var len = val.length;

   for ( i = 0; i < len; i++ )
   {
      if( val.charAt(i) == '&' )
      {
         return false;
      }
   }

   return true;
}

function isPppNameUnsafe(compareChar) {
   var unsafeString = "\"\\`\,=' \t";
	
   if ( unsafeString.indexOf(compareChar) == -1 && compareChar.charCodeAt(0) > 32
        && compareChar.charCodeAt(0) < 123 )
      return false; // found no unsafe chars, return false
   else
      return true;
}   

// Check if a ppp name or password valid
function isValidPppName(pppname) {
   var i = 0;	
   
   for ( i = 0; i < pppname.length; i++ ) {
      if ( isPppNameUnsafe(pppname.charAt(i)) == true )
         return false;
   }

   return true;
}

function Resizeiframe()
{
  getElById('mainFrameid').style.height=531; 
  var mainbody = mainFrame.document.body.scrollHeight;
  var trmainbody = getElById('trmain').clientHeight;
  var mainbodyoffset = getElById('mainFrameid').offsetHeight;
  var end = mainbody;
  if (end < (trmainbody-31))
    end = trmainbody-31;
  getElById('mainFrameid').style.height=end;  //must be id
}

function parseValueList(valueList, rowD, colD){
    if(valueList == '')
         return 'undefined';	 
	if(typeof(rowD) == 'undefined')
		rowD = '/';
	if(typeof(colD) == 'undefined')
		colD = '|';
	var rowArray = valueList.split(rowD), rowsNum = rowArray.length; 
	var valuesArray = new Array();
	for ( var i = 0; i != rowsNum; i++ ){
	    valuesArray[i] = rowArray[i].split(colD)
	}

	return valuesArray;
}

function getValueIndexFromValues(valuesArray, name ){
    if( valuesArray.length == 0)
	    return NaN;
		
	var rowLength = valuesArray.length, colLength = valuesArray[rowLength-1].length;
	for (var index=0; index != colLength; index ++){
	    if(name == valuesArray[rowLength-1][index])
		    return index;
	}

	return NaN;
}

function setElementAttr(elementArr, statuArr, attrName){
    for(var i=0; i != elementArr.length; i++)
	    $(elementArr[i]).attr(attrName, statuArr[i])
}

function setElementCss(elementArr, cssArry, cssName){
    for(var i=0; i != elementArr.length; i++)
	    $(elementArr[i]).css(cssName, cssArry[i])
}

function setElementsDisabled(elementArr, statusArr){
    for(var i=0; i != elementArr.length; i++)
	{
		document.getElementById(elementArr[i]).disabled = statusArr[i];
	}
}

function isInValidNumRange(num, floor, top){
    if( isNaN(num) || num < floor || num > top)
	    return false;
	return true;
}

function isValidPort(port){
    return isInValidNumRange(port, 0, 65535);
}

function isNullString(checkText){
    if(checkText == null || checkText == "" || checkText.length == 0)
        return true;
    else
        return false;
}

function submitCheckbox(elementId){
	if($(elementId).is(':checked'))
		return 1;
	else
		return 0;
}

function submitCheckboxJs(elementId){
	if(true == document.getElementById(elementId).checked)
		return 1;
	else
		return 0;
}

function Entry(key, value){
	this.key = key;
	this.value = value;
}

function setCheckbox(elementId, status){
    if(status == '1' || status == true)
	    $(elementId).attr("checked", true);
	else
		 $(elementId).attr("checked", false);
}

/*function isValidIpAddress(ipAddress)
{
    var urlPat=/(?:(?:http[s]?|ftp):\/\/)?[^\/\.]+?\.[^\.\\\/]+?\.\w{2,}$/i;
    var matchArray=ipAddress.match(urlPat);
    
    var pattIp = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])(\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])){3}$/;
    var iptest = pattIp.test(ipAddress);
 
    if(matchArray != null || iptest == true ){
       return true;
    } else {
       return false;
   } 
}*/

function isValidNetIpAddress(address) {
   var i = 0;

   if ( address == '0.0.0.0' ||
        address == '127.0.0.1'||
        address == '255.255.255.255' )
      return false;

   addrParts = address.split('.');
   if ( addrParts.length != 4 ) return false;
   for (i = 0; i < 4; i++) {
      if (isNaN(addrParts[i]) || addrParts[i] =="")
         return false;
      num = parseInt(addrParts[i]);
      if ( isNaN(num)|| num < 0 || num > 255 )
         return false;
   }

   if (parseInt(addrParts[0]) < 1 || parseInt(addrParts[0]) > 223)
   	return false;
   
   
   return true;
}

function isValidIpAddressRange(startAddr, endAddr){

   if ( !isValidIpAddress(startAddr) || !isValidIpAddress(endAddr) )
      return false;

   var i;
   var startAddrParts = startAddr.split('.');
   var endAddrParts = endAddr.split('.');

   for ( i = 0; i < 4; i++ ){
      if ( parseInt(startAddrParts[i]) < parseInt(endAddrParts[i]) )
         return true;
      else if ( parseInt(startAddrParts[i]) > parseInt(endAddrParts[i]) )
         return false;
   }

   return false;
}

function addOption(text,value)
{  
	document.getElementById("linkName").options.add(new Option(text,value));
}
var LanAliasNameArray = new Array();
LanAliasNameArray[0] = new Array("", "", "", "");
LanAliasNameArray[1] = new Array("(千兆口)", "(百兆口)");
LanAliasNameArray[2] = new Array("(悦me)", "(网口2)", "(网口3)", "(网口4)");

function getLanAliasNameArray(deviceType)
{
	if (/HG2[26][15]G/.test(deviceType))
	{
		return LanAliasNameArray[1];
	}
	else if (/HG2[26]8G/.test(deviceType))
	{
		return LanAliasNameArray[2];
	}
		
	return LanAliasNameArray[0];
}

function formatTime(s) 
{
	var t;
	var hour = Math.floor(s/3600);
	var min = Math.floor(s/60) % 60;
	var day = parseInt(hour / 24);

	t = day + ":";
	hour = hour - 24 * day;
	t +=  hour + ":" + min;

	return t;
}

function getNetworkRate(rate, dec)
{
	var str;
	if ((rate / dec) < 1024)
	{
		str = (rate / dec).toFixed(1) + "";
	}
	else if ((rate / (1024 * dec)) < 1024)
	{
		str = (rate / (1024 * dec)).toFixed(1) + "K";	
	}
	else if ((rate / (1024 * 1024 * dec)) < 1024)
	{
		str = (rate / (1024 * 1024 * dec)).toFixed(1) + "M";	
	}
	else if ((rate / (1024 * 1024 * 1024 * dec)) < 1024)
	{
		str = (rate / (1024 * 1024 * 1024 * dec)).toFixed(1) + "G";		
	}
	else if ((rate / (1024 * 1024 * 1024 * 1024 * dec)) < 1024)
	{
		str = (rate / (1024 * 1024 * 1024 * 1024 * dec)).toFixed(1) + "T";		
	}	

	return str;
}

function string2MACFormat(strMac)
{
	if (strMac.length == 12)
		var mac = strMac.substring(0,2) + ":" + strMac.substring(2,4) + ":" + strMac.substring(4,6) + ":" + strMac.substring(6,8) + ":" + strMac.substring(8,10) + ":" + strMac.substring(10,12);
	else
		var mac = strMac;

	return mac;
}

function SsidisIncludeInvalidChar(val) {
   var len = val.length;

   for ( i = 0; i < len; i++ )
   {
      if( val.charAt(i) == '&' )
      {
         return false;
      }
   }

   return true;
}

function isValidNameString( val ){
	var len = val.length; 
	
	for ( i = 0; i < len; i++ )    
	{        
	   if ( ( val.charAt(i) > '~' ) || ( val.charAt(i) < '!' ) )        
	   {            
	     return false;        
	   }    
	}    
	
	return true;
}

function isValidWPAKey(key) 
{ 
	var len = key.length; 
	
	for (i = 0; i < len; i++)    
	{        
	    if ((key.charAt(i) > '~') || (key.charAt(i) < '!' ))        
	    {            
			return false;        
	    }    
	}    
	
	return true;
}

var capsFlg = false;
function detectCapsLock(event, idx, module)
{
	if ((!!window.ActiveXObject || "ActiveXObject" in window) || (navigator.userAgent.indexOf("Edge") > -1)) //IE or Edge
	{
		console.log("IE or Edge broswer");
		return;
	}
	
    var e = event||window.event;

    var keyCode = e.keyCode||e.which; // 按键的keyCode
    var isShift = e.shiftKey ||(keyCode == 16 ) || false ; // shift键是否按住

	if (module == "user")
		$(".save_error").text("");

	if ((keyCode >=   65   && keyCode <=   90 ) || (keyCode >=   97   && keyCode <=   122 ))
		capsFlg = true;
    
	if (((keyCode >=   65   && keyCode <=   90 ) &&   !isShift) // Caps Lock 打开，且没有按住shift键
		|| ((keyCode >=   97   && keyCode <=   122 ) && isShift))// Caps Lock 打开，且按住shift键
		$("#promptText" + idx).css("display", "");
	else
		$("#promptText" + idx).css("display", "none");
}

function keyCapscheck(e, num)				
{				
	if (capsFlg && (e.keyCode == 20))						
	{
		if (num == 1)
			$("#promptText1").css("display", "none");
		else				
		{									
			$("#promptText1").css("display", "none");					
			$("#promptText2").css("display", "none");				
		}					
	}				
}

function BrowserType()
{
	var userAgent = navigator.userAgent; //取得浏览器的userAgent字符串
	var isOpera = userAgent.indexOf("Opera") > -1; //判断是否Opera浏览器
	var isIE = (!!window.ActiveXObject || "ActiveXObject" in window); //判断是否IE浏览器
	var isEdge = userAgent.indexOf("Edge") > -1; //判断是否IE的Edge浏览器
	var isFF = userAgent.indexOf("Firefox") > -1; //判断是否Firefox浏览器
	var isSafari = userAgent.indexOf("Safari") > -1 && userAgent.indexOf("Chrome") == -1; //判断是否Safari浏览器
	var isChrome = userAgent.indexOf("Chrome") > -1 && userAgent.indexOf("Safari") > -1; //判断Chrome浏览器

	if (isIE) 
	{
		var reIE = new RegExp("MSIE (\\d+\\.\\d+);");
		var fIEVersion = parseFloat(RegExp["$1"]);
		if(fIEVersion == 7)
			return "IE7";
		else if(userAgent.indexOf("Trident/4.0") > -1)
			return "IE8";
		else if(userAgent.indexOf("Trident/5.0") > -1)
			return "IE9";
		else if(userAgent.indexOf("Trident/6.0") > -1)
			return "IE10";
		else if(userAgent.indexOf("Trident/7.0") > -1)
			return "IE11";
		else
			return "0";//IE版本过低
	}

	return isEdge ? "Edge" : (isFF ? "Firefox" : (isChrome ? "Chrome" : (isOpera ? "Opera" : (isSafari ? "Safari" : "Undefined"))));
}

