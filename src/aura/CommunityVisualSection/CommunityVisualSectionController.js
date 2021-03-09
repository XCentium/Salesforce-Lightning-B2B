({
	myAction : function(component, event, helper) {
		var pref = window.location.pathname.split('/')[1];
		component.set("v.prefix", pref);
        console.log();
	},
    GotoURL : function(component, event, helper) {
        var url = component.get('v.Link1');
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": url 
        });
        eUrl.fire();
    }
})