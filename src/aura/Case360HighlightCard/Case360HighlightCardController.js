({
    
    doInit : function(component, event, helper) {
        var action = component.get('c.getContact');
        var caseId = component.get('v.recordId');
        
        action.setParams( {caseId : caseId} ); 
                
        action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    
                  component.set("v.contact", response.getReturnValue());
                  console.log(response.getReturnValue());
                  
                  
                }
                else {
                  console.log("Failed with state" + state);
                }
          })
          $A.enqueueAction(action);
        
    },
    viewContact : function(component, event, helper) {
        console.log('nav to trip');
        var contactId = component.get("v.contact.Id");
        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": contactId
              
            });
            navEvt.fire();
   }
})