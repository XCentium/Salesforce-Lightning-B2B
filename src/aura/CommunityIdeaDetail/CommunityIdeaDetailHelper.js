({
	GetGuestUser : function(component, event) {
        var isGuestUserMethod = component.get("c.isGuestUser");
        isGuestUserMethod.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.isGuest", a.getReturnValue());
        });
        $A.enqueueAction(isGuestUserMethod);
    }
})