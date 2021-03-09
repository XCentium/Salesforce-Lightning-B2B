({
	goToURL : function(component, event, helper) {
        if(component.get("v.CaptionActionURL") != ''){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": component.get("v.CaptionActionURL")
            });
            urlEvent.fire();
        }
    }
})