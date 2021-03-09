({
	closeModal : function(component, event, helper) {
		component.destroy();
	},
    
    goToFullHelp: function(component, event, helper) {

    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url": "/lightning/n/"+component.get('v.prefix')+"Pricer_Home"
    });

    urlEvent.fire();
	}
})