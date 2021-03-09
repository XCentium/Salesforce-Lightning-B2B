({
	goToURL : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
           'url': component.get("v.URL")
       });
       urlEvent.fire();

	}
})