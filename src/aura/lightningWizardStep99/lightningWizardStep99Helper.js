({
	fireChangePageEvent : function(type) {
		
        var appEvent = $A.get("e.c:lightningWizardStepChange99");
        appEvent.setParams({
            "type" : type
        });
        appEvent.fire();
	}
})