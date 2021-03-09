({
	onReceiveNotification: function (component, message) {
        console.log("Notification Recieved");
        // Extract notification from platform event
        const newNotification = {
          time: $A.localizationService.formatDateTime(
            message.data.payload.CreatedDate, 'HH:mm'),
          message: message.data.payload.Message__c
        };
        
        /* Set Status and Message */
        	component.set("v.EventRecieved",true);
            if( (message.data.payload.Voltage_Level__c > component.get("v.VoltageCriticalSetting")) && (message.data.payload.Voltage_Level__c <= component.get("v.VoltageWarningSetting")) ){
                component.set("v.Message", 'Low Voltage Warning');
                component.set("v.Status", 'yellow');
            }else if(message.data.payload.Voltage_Level__c <= component.get("v.VoltageCriticalSetting")){
                component.set("v.Message", 'Critical Low Voltage');
                component.set("v.Status", 'red');
            }else if( (message.data.payload.Internal_Temperature__c > component.get("v.TempWarningSetting")) && (message.data.payload.Internal_Temperature__c < component.get("v.TempCriticalSetting")) ){
                component.set("v.Message", 'Temperature Warning');
                component.set("v.Status", 'yellow');
            }else if(message.data.payload.Internal_Temperature__c > component.get("v.TempCriticalSetting")){
                component.set("v.Message", 'Critical Temperature');
                component.set("v.Status", 'red');
            }else if( (message.data.payload.Vibration__c > component.get("v.VibrationWarningSetting")) && (message.data.payload.Vibration__c < component.get("v.VibrationCriticalSetting")) ){
                component.set("v.Message", 'Vibration Warning');
                component.set("v.Status", 'yellow');
            }else if(message.data.payload.Vibration__c >= component.get("v.VibrationCriticalSetting")){
                console.log("Vibration Level: " + message.data.payload.Vibration__c);
                component.set("v.Message", 'High Vibration'); 
                component.set("v.Status", 'red');
            }else if(message.data.payload.AlpinePreInventory__c < 20){
                component.set("v.Message", 'Low Inventory');
                component.set("v.Status", 'yellow');
            }else if(message.data.payload.AlpinePostInventory__c < 20){
                component.set("v.Message", 'Low Inventory');
                component.set("v.Status", 'yellow');
            }else if(message.data.payload.AlpineDuringInventory__c < 20){
                component.set("v.Message", 'Low Inventory');
                component.set("v.Status", 'yellow');
            }else{
                component.set("v.Message", 'Working');
                component.set("v.Status", 'green');
            }
        
        // Save notification in history
        const notifications = component.get('v.notifications');
        notifications.push(newNotification);
        component.set('v.notifications', notifications);
        
        console.log("Notification: " + component.get("v.notifications"));
        // Display notification in a toast
        this.displayToast(component, 'info', newNotification.message);
      },
      // Displays the given toast message.
      displayToast: function (component, type, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
          type: type,
          message: message
        });
        toastEvent.fire();
      }
})