({
    getContactInfo: function(component,event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getContactInfo");
        console.log("Record ID: " + recordId);
        action.setParams({
            caseId : recordId
        });
        action.setCallback(this, function(response){
            console.log("Fired");
            var state = response.getState();
            console.log("State:  "+ state );
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(JSON.stringify(resp));
                console.log(response.getReturnValue()[0]);
                component.set("v.contactId",response.getReturnValue()[0].Id);
                component.set("v.glutenFree",response.getReturnValue()[0].Gluten_Free__c);
                component.set("v.kosher",response.getReturnValue()[0].Kosher__c);
                component.set("v.vegetarian",response.getReturnValue()[0].Vegetarian__c);
                component.set("v.vegan",response.getReturnValue()[0].Vegan__c);
                component.set("v.crohns",response.getReturnValue()[0].Crohns__c);
                component.set("v.lowFat",response.getReturnValue()[0].Low_Fat__c);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updateContact: function(component,event) {
        var eventSource= event.getSource();
        var eventSourceId= eventSource.getLocalId();
        var eventSourceVal= eventSource.get("v.value");
        var contactId= component.get("v.contactId");
        var action = component.get('c.updateContact');
        action.setParams({
            "contactId": contactId,
            "var" : eventSourceId,
            "status" : eventSourceVal
        });
        
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state= actionResult.getState();
            if(state=='SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "The customer preference has been updated successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
})