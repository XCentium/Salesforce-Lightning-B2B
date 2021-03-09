({
    GetGuestUser : function(component, event) {
        var isGuestUserMethod = component.get("c.isGuestUser");
        isGuestUserMethod.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.isGuestUser", a.getReturnValue());
        });
        $A.enqueueAction(isGuestUserMethod);
    },
	GetZone : function(component, event){
        var getZones = component.get("c.getCurrentCommunityZones");
        getZones.setCallback(this, function(a){
            console.log('got zones');
            component.set("v.zoneIdNames", a.getReturnValue());
        });
        $A.enqueueAction(getZones);
    }
})