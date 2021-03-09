({
    init: function(component, event, helper){
        /*Get Org Identifier to determine which IDO this is */
        helper.showSpinner(component);
        helper.getOrgIndentifier(component, event, helper);
        if(component.get('v.Industry') != ''){
            if(component.get('v.IndustryName') == ''){
                helper.SetIndustryName(component, event, helper);
            }
        }
    },
    setPage: function(component, event, helper) {
        var url = window.location.pathname;
        var recid = component.get("v.recid");
        var ind = component.get("v.Industry");
        component.set("v.recid",'');
        
        var whichOne = event.currentTarget.id;
        component.set("v.ScreenChoice",whichOne);
        if(whichOne != 'Search'){
            component.set("v.SearchPhrase",'');
        }
        component.set("v.Filter",'');
        component.set("v.SearchType",'This Page');
    },
    GlobalSearch: function(component, event, helper) {
        var stype = component.get("v.SearchType");
        var recid = component.get("v.recid");
        if(recid != ''){
            component.set("v.SearchType",'All'); 
        }
        if(stype == 'All' || recid != ''){
            component.set("v.ScreenChoice",'Search'); 
        }
    },
    ShareableURL: function(component, event, helper) {
        var RecordId = component.get("v.recid");
        var ind = component.get("v.Industry");
        var page = component.get("v.ScreenChoice");
        if(RecordId != ''){
            component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=' + page + '&recid=' + RecordId);
        }else{
            component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=' + page);
        }
        var cmpTarget = component.find('ShareModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
        /*window.open('/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=' + page);*/
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('ShareModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed'); 
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    updateSettings: function(component, event, helper) {
        if(component.get("v.Industry") != ''){
            component.set("v.MenuOpenClose",'open');
            component.set("v.CompetedTotal",0);
            component.set("v.CompetedTotalPercent",0); 
            
            var industry = component.get("v.Industry");
            var endpoint = '/api/settings?industry__c=' + industry;
            var callout = component.get("c.getCalloutResponseContents");
            callout.setParams({
                endpoint: endpoint
            });
            callout.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.Settings",JSON.parse(response.getReturnValue()));
                    var setupPage = JSON.parse(response.getReturnValue());
                    component.set("v.HideSetupPage",setupPage[0].hide_setup_page__c );
                    component.set("v.ScreenChoice",setupPage[0].initial_page__c );
                }
            });
            $A.enqueueAction(callout);
        }else{
            
        }
    },
    IndustryChange  : function(component, event, helper) {
        helper.getSettings(component, event, helper);
        component.set("v.MenuOpenClose",'open');
        component.set("v.CompetedTotal",0);
        component.set("v.CompetedTotalPercent",0);
    },
    OpenMenu : function(component, event, helper) {
        component.set("v.MenuOpenClose",'open');
    },
    ChangeIndustry : function(component, event, helper) {
        component.set("v.Industry",'');
        component.set("v.IndustryName",'');
        component.set("v.ScreenChoice",'Industry');
    },
    MobileNavSelect : function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
        if(menuValue == 'Welcome'){
            component.set("v.ScreenChoice",'Welcome'); 
        }else if(menuValue == 'Updates'){
            component.set("v.ScreenChoice",'Updates'); 
        }else if(menuValue == 'Brand'){
            component.set("v.ScreenChoice",'Brand'); 
        }else if(menuValue == 'Personas'){
            component.set("v.ScreenChoice",'Personas'); 
        }else if(menuValue == 'Scripts'){
            component.set("v.ScreenChoice",'Scripts'); 
        }else if(menuValue == 'Partners'){
            component.set("v.ScreenChoice",'Partners'); 
        }else if(menuValue == 'Features'){
            component.set("v.ScreenChoice",'Features'); 
        }else if(menuValue == 'Customizations'){
            component.set("v.ScreenChoice",'Customizations'); 
        }else if(menuValue == 'Videos'){
            component.set("v.ScreenChoice",'Videos'); 
        }else if(menuValue == 'Resources'){
            component.set("v.ScreenChoice",'Resources'); 
        }else if(menuValue == 'Contact'){
            component.set("v.ScreenChoice",'Contact'); 
        }
    },
    searchSelect : function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
        if(menuValue == 'All'){
            component.set("v.ScreenChoice",'Search'); 
        }
    }
})