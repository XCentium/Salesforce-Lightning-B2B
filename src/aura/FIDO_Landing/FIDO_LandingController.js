({
	init: function(component, event, helper){
        helper.getIndustry(component, event, helper);
        helper.getNews(component, event, helper);
        helper.getPersonas(component, event, helper);
        helper.getBrands(component, event, helper);
        helper.getPartners(component, event, helper);
        helper.getCustomizations(component, event, helper);
        helper.getResources(component, event, helper);
        helper.getScripts(component, event, helper);
	},
    onOrgIdChange: function(component, event, helper){
        helper.getNews(component, event, helper);
	},
    ScreenChoiceChange : function(component, event, helper) {
        var screen = component.get("v.ScreenChoice");
	},
    rerender : function(component,event, helper) {
       this.superRerender();
    },
    toAllNews : function(component,event,helper) {
        component.set("v.ScreenChoice","Updates");
    },
    toSingleNews : function(component,event, helper) {
        component.set("v.ScreenChoice","Updates");
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    toAllBrands : function(component,event, helper) {
        component.set("v.ScreenChoice","Brand");
    },
    toSingleBrand : function(component,event, helper) {
        component.set("v.ScreenChoice","Brand");
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    toAllPersonas : function(component, event,helper) {
        component.set("v.ScreenChoice","Brand");
    },
    toSinglePersona : function(component, event,helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        console.log("rec: " + whichOne);
        component.set("v.ScreenChoice","Personas");
    },
    toAllScripts : function(component, event,helper) {
        component.set("v.ScreenChoice","Scripts");
    },
    toSingleScript : function(component, event,helper) {
        component.set("v.ScreenChoice","Scripts");
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    toAllPartners : function(component,event, helper) {
        component.set("v.ScreenChoice","Partners");
    },
    toSinglePartner : function(component, event,helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice","Partners");
    },
    toSingleScript : function(component, event,helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice","Scripts");
    },
    toAllCustomizations : function(component,event, helper) {
        component.set("v.ScreenChoice","Customizations");
    },
    toSingleCustomization : function(component, event,helper) {
        component.set("v.ScreenChoice","Customizations");
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    toAllResources : function(component, event,helper) {
        component.set("v.ScreenChoice","Resources");
    },
    toSingleResource : function(component, event,helper) {
        component.set("v.ScreenChoice","Resources");
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    toAllContacts : function(component,event, helper) {
        component.set("v.ScreenChoice","Resources");
    },
    GlobalSearch : function(component,event, helper) {
        component.set("v.ScreenChoice",'Search'); 
    },
})