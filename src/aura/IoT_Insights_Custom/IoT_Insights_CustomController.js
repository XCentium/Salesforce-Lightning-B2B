({
    onInit : function(component, event, helper) {
        /* Get Asset Information */
        var action = component.get("c.getAssetDetails");
        action.setParams({
            rId : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();  
                for(var i = 0; i < res.length; i++){
                    component.set("v.VoltageWarningSetting",res[i].Voltage_Low__c);
                    component.set("v.VoltageCriticalSetting",res[i].Voltage_Critical__c);
                    component.set("v.VibrationWarningSetting",res[i].Vibration_Warning__c);
                    component.set("v.VibrationCriticalSetting",res[i].Vibration_Excessive__c);
                    component.set("v.TempWarningSetting",res[i].Temperature_Warning__c);
                    component.set("v.TempCriticalSetting",res[i].Temperature_Critical__c);
                }
            }
        });
        $A.enqueueAction(action);
        
        const empApi = component.find('empApi');
        const channel='/event/Cooler_IoT_Event__e';
        const replayId = -1;
        const callback = function (message) {
          console.log('Event Received : ' + JSON.stringify(message));
          component.set("v.eventDetails", message.data.payload);
          helper.onReceiveNotification(component, message);
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
          console.log('Subscribed to channel ' + channel);
          component.set('v.subscription', newSubscription);
        }));
    },  
})