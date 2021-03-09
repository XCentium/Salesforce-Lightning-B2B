({
    doInit: function(component, event, helper) {
        console.log("Init");
        var action = component.get("c.getProdPrefUpdate");
        action.setParams({
            recid : component.get("v.recordId"),
            ProdName: component.get("v.Product")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var myType = component.get("v.TendernessOrRipeness");
                var resp = response.getReturnValue();
				console.log(JSON.stringify(resp));
                if(myType == 'Tenderness'){
                    if (resp != undefined && resp.length != 0) {
                        component.set("v.val",response.getReturnValue()[0].Tenderness__c);
                		component.set("v.img",response.getReturnValue()[0].Product__r.purl__c);
                    }else{
                        component.set("v.val",0);
                    }
                }else if(myType == 'Ripeness'){
                    if (resp != undefined && resp.length != 0) {
                        component.set("v.val",response.getReturnValue()[0].Ripeness__c);
                		component.set("v.img",response.getReturnValue()[0].Product__r.purl__c);
                    }else{
                        component.set("v.val",0);
                    }
                }else{
                    component.set("v.val",0);
                    component.set("v.img",'');
                } 
                
            }else{
                console.log("error")
            }
        });
        $A.enqueueAction(action);
    },
    
    updateVal: function(component, event, helper) {
        var action = component.get("c.updateProdPrefUpdate");
        action.setParams({
            recid : component.get("v.recordId"),
            ProdName: component.get("v.Product"),
            val: component.get("v.val"),
            Filtertype: component.get("v.TendernessOrRipeness") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var myType = component.get("v.TendernessOrRipeness");
                var resp = response.getReturnValue();

                if(myType == 'Tenderness'){
                    component.set("v.val",response.getReturnValue()[0].Tenderness__c);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Successfully updated value to " + component.get("v.val")
                    });
                    toastEvent.fire();
                }else if(myType == 'Ripeness'){
                    component.set("v.val",response.getReturnValue()[0].Ripeness__c);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Successfully updated value to " + component.get("v.val")
                    });
                    toastEvent.fire();
                }else{
                    console.log("error");
                }
            }else{
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Could not update or create a record. Contact your administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        
        
    }
})