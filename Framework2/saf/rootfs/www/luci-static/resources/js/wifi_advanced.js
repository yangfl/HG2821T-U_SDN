function constructSelectList( eid )
{
	var dynamicHTML = "";
	if ( eid == "wifi_start_hour" || eid == "wifi_end_hour" )
	{
		for ( var i=23; i>=0; i-- )
		{
			if ( i >= 10 )
			{
				dynamicHTML += "<li livalue=" + i + ">" + i + "</li>";
			}
			else
			{
				dynamicHTML += "<li livalue=0" + i + ">0" + i + "</li>";
			}
		}
	}
	if ( eid == "wifi_start_minute" || eid == "wifi_end_minute" )
	{
		for ( var i=59; i>=0; i-- )
		{
			if ( i >= 10 )
			{
				dynamicHTML += "<li livalue=" + i + ">" + i + "</li>";
			}
			else
			{
				dynamicHTML += "<li livalue=0" + i + ">0" + i + "</li>";
			}
		}
	}
	$("#" + eid).html(dynamicHTML);
}
$(document).ready(function(){
	customSwitchInit();
	$("#wifi_timing_switch").bind("click", function(){
		if($(this).hasClass("switch_content_on"))
		{
			$(".timing_settings").css("display", "");
		}
		else
		{
			$(".timing_settings").css("display", "none");
		}
	});

	constructSelectList("wifi_start_hour");
	constructSelectList("wifi_end_hour");
	constructSelectList("wifi_start_minute");
	constructSelectList("wifi_end_minute");
	
	customScrollBar("#wifi_start_hour");
	customScrollBar("#wifi_start_minute");
	customScrollBar("#wifi_end_hour");
	customScrollBar("#wifi_end_minute");
	
	customSelectInit();
});

