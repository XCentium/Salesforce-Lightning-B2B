({
	doInit : function(component, evt, hlp) {
        let usr = component.get('c.getUser');
        usr.setCallback(this,function(res){
            component.set('v.userName',res.getReturnValue());
        });
        $A.enqueueAction(usr);
        
        var action = component.get("c.getContactRecord");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Contact",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    toggleModal : function(cmp, evt, hlp) {
        let modal = cmp.find('modal');
        let backdrop = cmp.find('backdrop');
        $A.util.toggleClass(modal, 'slds-fade-in-open');
        $A.util.toggleClass(backdrop, 'slds-backdrop_open');
    },
})