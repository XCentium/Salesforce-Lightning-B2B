({
	offerAccept : function(component, event, helper) {
        component.set("v.offered", true);
        component.set("v.accepted", true);
        component.set("v.offeredIcon", "utility:success");
        component.set("v.footer", "Accepted");       
        helper.successIcon(component);

        
		
	},
    offerReject : function(component, event, helper) {
        component.set("v.offered", true);
        component.set("v.accepted", false);
        component.set("v.offeredIcon", "utility:clear");
        component.set("v.footer", "No Thanks");
        helper.failIcon(component);
        
		
	}
    
    
})