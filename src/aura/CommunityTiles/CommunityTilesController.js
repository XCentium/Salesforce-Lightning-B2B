({
	myAction : function(component, event, helper) {
		var pref = window.location.pathname.split('/')[1];
		component.set("v.prefix", pref);
        console.log();
	}
})