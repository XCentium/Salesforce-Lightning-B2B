({
    redirectFirst : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": component.get("v.FirstLink")
        });
        urlEvent.fire();
    },
    
    redirectSecond : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": component.get("v.SecondLink")
        });
        urlEvent.fire();
    },
    
    redirectThird : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": component.get("v.ThirdLink")
        });
        urlEvent.fire();
    }
})