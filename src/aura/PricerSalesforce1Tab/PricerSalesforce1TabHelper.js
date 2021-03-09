({
	createRec : function(component,parentType) {
        var remoteAct = component.get("c.createNewParentRec");
        remoteAct.setParams({
            accountId : component.get("v.accountId"),
            parentType : parentType
            
        });
        var self = this;
        remoteAct.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                //console.log("Load Lines retrieval fired - Success");
                console.log(actionResult.getReturnValue());
                var recId = actionResult.getReturnValue();
                component.set('v.recordId',recId);
                component.set('v.sObjectName',parentType);
                component.set('v.currentStep',4);

            } 
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                    var errors = actionResult.getError();
                    console.log(errors);
            }

        });
        $A.enqueueAction(remoteAct);
    }
})