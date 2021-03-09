({
    //Component Name: News_Announcements display name "Recent News"
    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : March 25, 2016
    doInit : function(component, event, helper) {
        helper.loadNewsChannelNames(component);
        helper.loadnumDocsByChannel(component);//get number of records per News Channel
        //if more link has been clicked check for channel name in the URL
        var newsURL = window.location.href;
      	if (newsURL.indexOf('channel/') != -1) {
            var selectedChannel = decodeURI(newsURL.substr(newsURL.indexOf('channel/') + 8));
            component.set("v.selectedNewsChannel",selectedChannel);
            helper.loadNewsChannelRecordsByChannel(component, event);
        }else{
            //get news records by first news channel name
            helper.loadFirstNewsChannelRecords(component, event);
        }
    },   
    displayNewsChannelRecords: function(component, event, helper){
        //changed from event.target.value to event.target.getAttribute('data-value') to render with Locker Service Enabled
        component.set("v.selectedNewsChannel",event.target.getAttribute('data-value'));
        component.set("v.encodedSelectedNewsChannel",encodeURIComponent(event.target.getAttribute('data-value')));
        helper.loadNewsChannelRecordsByChannel(component); // get news records by selected news channel name
    },
 	showHideMenu : function(component, event) {
    	var cmpTarget = component.find('newsMenu');
       	var menuState = component.get('v.menuState');
        if(menuState === "Collapsed"){
            $A.util.addClass(cmpTarget, 'slds-is-open');
            component.set('v.menuState','Expanded');
        }else{
            $A.util.removeClass(cmpTarget, 'slds-is-open');
			component.set('v.menuState','Collapsed');
        } 
    },
    /** formController.js **/
    waiting : function(component, event, helper) {
    	component.set("v.wait", "updating...");
	},
	doneWaiting : function(component, event, helper) {
    	component.set("v.wait", "");
	},
})