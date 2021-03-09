({
    openDoor : function(component, event, helper) {
        
        let doorOpen = component.get('v.doorOpen');
        component.set('v.doorOpen', !doorOpen);
        
    },
    
    submitPlatformEvent : function(component, event, helper) {
        
        var vibration = component.get('v.vibrationValue');
        var extTemp = component.get('v.externalTempValue');
        var intTemp = component.get('v.internalTempValue');
        var doorOpen = component.get('v.doorOpen');
        var voltage = component.get('v.voltageValue');
        
        console.log(vibration, intTemp, extTemp, voltage, doorOpen);
        
        var action = component.get('c.submitNewEvent');
        
        action.setParams({
            'coolerId' : component.get('v.selectedCooler'),
            'vibration' : vibration,
            'extTemp' : extTemp,
            'intTemp' : intTemp,
            'voltage' : voltage,
            'doorOpen' : doorOpen
        });
        
        action.setCallback(this, function(result){
            if(result.getState() === 'SUCCESS'){
                var res = result.getReturnValue(); 
                console.log('res', res);
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
    
    doInit : function(component, event, helper) {
        var action = component.get('c.fetchCoolerAssets');
        
        action.setCallback(this, function(result){
            if(result.getState() === 'SUCCESS'){
                var res = result.getReturnValue();  
                
                component.set('v.coolers', res);
            } else {
                console.log('There was an error in the platform event submission process');
            }
        });
        
        $A.enqueueAction(action);
    },
    selectCooler : function(component, event, helper) {
        
        var cooler = component.find("coolerSelect").get('v.value');
        console.log('cooler selected: ', cooler);
        component.set('v.selectedCooler', cooler);
        
    }
})