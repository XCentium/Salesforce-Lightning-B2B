({
	init : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.getFeaturesbyOrg(component, event, helper); 
		helper.getContent(component, event, helper);
        helper.getPartners(component, event, helper);
        helper.getResources(component, event, helper);
        helper.getCustomizations(component, event, helper);
        helper.getPersonas(component, event, helper);
        helper.getAnnouncements(component, event, helper);
        helper.getVideos(component, event, helper);
	},
    goToScript: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Scripts');
    },
    goToPartner: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Partners');
    },
    goToResource: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Resources');
    },
    goToCustomizations: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Customizations');
    },
    goToVideo: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Videos');
    },
    goToPersona: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Personas');
    },
    goToAnnouncement: function(component, event, helper) {
        component.set("v.SearchPhrase",'');
        component.set("v.SearchType",'This Page');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'News');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('scriptModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    toScript : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    toURL : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    toContent : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Demo_Content__c/' + whichOne + '/view');
    },
    SearchChanged : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
})