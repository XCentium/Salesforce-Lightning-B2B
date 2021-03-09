({
    CloseWelcome : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
    },
    GoToBrand : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Brand');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR BRAND');
        component.set("v.BrandCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToPersonas : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Personas');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR PERSONAS');
        component.set("v.PersonaCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToSolutions : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Solutions');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR Solutions');
        component.set("v.SolutionsCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToPartners : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Partners');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR Partners');
        component.set("v.PartnersCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToFeatures : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Features');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR Customizations');
        component.set("v.FeaturesCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToVideos : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Videos');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR VIDEOS');
        component.set("v.VideosCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToResources : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Resources');
        component.set("v.ComponentTitle",'GETTING TO KNOW YOUR Resources');
        component.set("v.ResourcesCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
    GoToSetup : function(component, event, helper) {
        component.set("v.MenuOpenClose",'close');
        component.set("v.ScreenChoice",'Setup');
        component.set("v.ComponentTitle",'Getting to know your Setup Steps');
        component.set("v.SetupCompleted",1);
        helper.calculateWelcome(component, event, helper);
    },
})