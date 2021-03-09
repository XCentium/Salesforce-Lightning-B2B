({
    GetInventoryList : function(component, event, helper) {
        /* Get Asset Details */
        var callback = component.get("c.getAssetDetails");
        callback.setParams({
            RecId : component.get("v.recordId"),
        });
		callback.setCallback(this, function(response) {
            console.log(response);
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Asset",response.getReturnValue());
            }
        });
        $A.enqueueAction(callback);
        
        
        var action = component.get("c.getInventoryProducts");
        action.setParams({
            RecId : component.get("v.recordId"),
        });
		action.setCallback(this, function(response) {
            console.log(response);
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ProdList",response.getReturnValue());
                console.log("Inventory: " + JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },
    openDoor : function(component, event, helper) {
        let doorOpen = component.get('v.doorOpen');
        component.set('v.doorOpen', !doorOpen);
        
    },
    onSelectchange : function(component, event, helper) {
        var val = component.find("inventoryPicklist").get("v.value");
        component.set("v.InventorySelected",val);
        console.log("Value set to: "+ val);
    },
    submitPlatformEvent : function(component, event, helper) {
        
        var vibration = component.get('v.vibrationValue');
        var extTemp = component.get('v.externalTempValue');
        var intTemp = component.get('v.internalTempValue');
        var doorOpen = component.get('v.doorOpen');
        var voltage = component.get('v.voltageValue');
        
        var pre = component.get('v.AlpinePreInventory');
        var during = component.get('v.AlpineDuringInventory');
        var post = component.get('v.AlpinePostInventory');
        
        var invSelected = component.get('v.InventorySelected');
        var invRemoved = component.get('v.InventoryRemoved');
        
        console.log(
            ' Vibration: ' + vibration +
            ' Internal Temp: ' + intTemp + 
            ' External Temp: '+ extTemp+ 
            ' Voltage: ' + voltage + 
            ' Pre Level: ' + pre +
            ' During Level: ' + during +
            ' Post Level: ' + post +
            ' Inventory Item Selected: ' + invSelected +
            ' Inventory Removed: ' + invRemoved +
            ' Is the door open? ' + doorOpen
        );
        
        var action = component.get('c.submitNewEvent');
        
        action.setParams({
            'coolerId' : component.get('v.recordId'),
            'vibration' : vibration,
            'extTemp' : extTemp,
            'intTemp' : intTemp,
            'voltage' : voltage,
            'doorOpen' : doorOpen,
            'preLevel' : pre,
            'duringLevel' : during,
            'postLevel' : post,
            
        });
        
        action.setCallback(this, function(result){
            if(result.getState() === 'SUCCESS'){
                var res = result.getReturnValue();  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The event has been inserted successfully."
                });
                toastEvent.fire();              
            } else {
                console.log('There was an error in the platform event submission process');
            }
        });
        
        $A.enqueueAction(action);
        
    },
})