({
	GotoURL : function(component, event, helper) {
        var url = component.get('v.ButtonLink');
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": url 
        });
        eUrl.fire();
    }
})