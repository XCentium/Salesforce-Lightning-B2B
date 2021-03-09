({
	goToURL : function(component, event, helper) {
        if(component.get("v.TrailheadProfileURL") != ''){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": component.get("v.TrailheadProfileURL")
            });
            urlEvent.fire();
        }
    }
})