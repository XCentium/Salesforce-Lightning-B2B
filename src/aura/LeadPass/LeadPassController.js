({

    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
    doInit : function(component, event, helper) {
        helper.loadRecords(component,event);
    },

    loadRecords : function(component, event, helper) {
        helper.loadRecords(component,event);
    },
    
    //updateEvent called by updateLead event handler  
    updateEvent : function(component, event, helper) {
        helper.upsertLead(component, event, event.getParam("record"));
	},
    
    pageChange: function(component, event, helper) {
		var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = direction === "previous" ? (page - 1) : (page + 1);
        helper.pageChange(component, page);
	},

    showHideMenu : function(component, event) {
    	var cmpTarget = component.find('dropdownMenu');
       	var menuState = component.get('v.menuState');
        if(menuState === "Collapsed"){//changed from == to ===
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