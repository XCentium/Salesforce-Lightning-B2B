({
    getAsset : function(component) {
        var action = component.get("c.getAsset");
        
        action.setParams({ recordId : component.get('v.recordId'), objectType : component.get('v.objectType')  });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var assetObj = response.getReturnValue();
                component.set('v.thisAsset', assetObj);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                       if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message); 
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})