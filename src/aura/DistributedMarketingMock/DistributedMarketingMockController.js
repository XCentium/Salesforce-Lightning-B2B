({
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    saveModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Saved Successfully.",
            "type" : "success"
        });
        toastEvent.fire();
    },
    openmodal: function(component,event,helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    checkboxChange: function (component, event) {
        var CheckedList = event.getParam('value');
        if(CheckedList != ''){
            component.set("v.disabled", false);
        }else{
            component.set("v.disabled", true);
        }
    },
    personalize: function (component, event) {
        component.set("v.Page","EmailTemplate");
		var hidetarget = component.find('Pendings');
        var showtarget = component.find('PersonalizedMessage');
        $A.util.addClass(hidetarget,'slds-hidden');
        $A.util.removeClass(showtarget, 'slds-hidden'); 
    },
    reset: function (component, event) {
        component.set("v.Page","Start");
        var showtarget = component.find('Pendings');
        var hidetarget = component.find('PersonalizedMessage');
        $A.util.addClass(hidetarget,'slds-hidden');
        $A.util.removeClass(showtarget, 'slds-hidden'); 
    },
})