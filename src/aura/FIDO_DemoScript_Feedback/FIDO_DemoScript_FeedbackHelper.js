({
    showSpinner : function (component, event) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideSpinner : function (component, event) {
       var spinner = component.find("spinner");
       $A.util.removeClass(spinner, "slds-show");
       $A.util.addClass(spinner, "slds-hide");
    },
    saveFeedBackJS : function (component, event,helper){
        var callout = component.get("c.emailContentFeedback");
        callout.setParams({
            title: component.get("v.title"),
            reasonAttr: component.get("v.value"),
            unlineDescAttr: component.get("v.unlikeDescription"),
            email: component.get("v.owneremail")
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Success Sending");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Feedback saved successfully.",
                    "type": "success" 
                });
                toastEvent.fire();
                component.set("v.value","");
                component.set("v.unlikeDescription","");
                
                var feedback = component.find("feedback");
                $A.util.addClass(feedback, "slds-hide");
        		$A.util.removeClass(feedback, "slds-show");
                
                var thankyou = component.find("Thankyou");
                $A.util.addClass(thankyou, "slds-show");
        		$A.util.removeClass(thankyou, "slds-hide");
            }else{
                console.log("Error Sending");
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(callout);
    }
})