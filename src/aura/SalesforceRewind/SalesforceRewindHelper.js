({
    // Client-side function that invokes the subscribe method on the empApi component.
    subscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi');
        // Get the channel from the attribute.
        const channel = component.get('v.channel');
        // Subscription option to get only new events.
        const replayId = -1;
        // Callback function to be passed in the subscribe call. After an event is received, this callback prints the event
        // payload to the console. A helper method displays the message in the console app.
        const callback = function (message) {
            console.log('Event Received : ' + JSON.stringify(message));
            if(component.get('v.isRecording')) {
                helper.getRewindRecords(component);
            }
            
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('Subscribed to channel ' + channel);
            component.set('v.subscription', newSubscription);
        }));
    },
    // Client-side function that invokes the unsubscribe method on the empApi component.
    unsubscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi');
        // Get the channel from the component attribute.
        const channel = component.get('v.subscription').channel;
        // Callback function to be passed in the unsubscribe call.
        const callback = function (message) {
            console.log('Unsubscribed from channel ' + message.channel);
        };
        // Unsubscribe from the channel using the subscription object.        
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    },
    
    //Client-side function to retrieve Custom Setting
    getCustomSetting: function (component) {
        var action = component.get('c.getRecording');
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                console.log('Custom Setting Value = ' + response.getReturnValue());
                
                component.set('v.isRecording', response.getReturnValue());                
            }
            else
                console.error(response);
        });
        
        $A.enqueueAction(action);
    },
    
    getRewindRecords : function(component) {
        var action = component.get('c.getRewindRecords');
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                //console.log(response.getReturnValue());
                component.set('v.notifications', response.getReturnValue());                
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
    },
    
    setRecording : function(component, parameter) {
        var action = component.get('c.setRecording');
        action.setParams({ value : parameter });
        
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                console.log('Custom Setting Value = ' + response.getReturnValue());
                component.set('v.isRecording', response.getReturnValue());               
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
    },
    onDelete : function(component, event, helper) {
        var tabindex = event.getSource().get("v.tabindex");
        var notifications = component.get("v.notifications");
        var recordId = notifications[tabindex].Id;
        
        var action = component.get('c.deleteARecord');
        action.setParams({ recordId : recordId });
        
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                //console.log(response.getReturnValue());
                
                component.set('v.notifications', response.getReturnValue());                
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
    },
    onDeleteAll : function(component, event, helper) {
        var action = component.get('c.deleteAllRecords');
        
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                //console.log(response.getReturnValue());
                
                component.set('v.notifications', response.getReturnValue());                
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
    },
    onRewind : function(component, event, helper) {
        var tabindex = event.getSource().get("v.tabindex");
        var notifications = component.get("v.notifications");
        var recordId = notifications[tabindex].Id;
        
        var action = component.get('c.rewindARecord');
        action.setParams({ recordId : recordId });
        
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                console.log(response.getReturnValue());
                
                notifications[tabindex].Status__c = response.getReturnValue().Status__c;
                if(response.getReturnValue().Error__c)
                    notifications[tabindex].Error__c = response.getReturnValue().Error__c;                
                component.set('v.notifications', notifications);
                
                $A.get('e.force:refreshView').fire();
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
    },
    
    onRewindAll : function(component, event, helper) {
        var notifications = component.get("v.notifications");
        var action = component.get('c.rewindARecord');
        
        for (var i = notifications.length; i > 0; i--) {            
            if(notifications[i-1].Status__c == 'Done') {
                action.setParams({ recordId : notifications[i-1].Id });                
                action.setCallback(this, function(response) {
                    if (component.isValid() && response.getState() === 'SUCCESS') {
                        console.log(response.getReturnValue());
                        
                        notifications[i-1].Status__c = response.getReturnValue().Status__c;
                        if(response.getReturnValue().Error__c)
                            notifications[i-1].Error__c = response.getReturnValue().Error__c;                
                        component.set('v.notifications', notifications);
                        
                        $A.get('e.force:refreshView').fire();
                        helper.onRewindAll(component, event, helper);
                    }
                    else
                        console.error(response);
                });
                $A.enqueueAction(action);
                break;
            }           
        }
    },
})