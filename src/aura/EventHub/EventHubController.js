({
    
    // Invoked by afterScriptsLoaded event, indicating
    // That CometD and the eventHub static resources
    // are loaded.
    onJSLoaded: function(component, event, helper) {
       // console.log('onJSLoaded');
        
        // Retrieve the sessionId from the server       
        var action = component.get("c.getSessionId");
        action.setCallback(this, function(response) {
            var sessionId = response.getReturnValue();
            component.set('v.sessionId', sessionId);
            
            // Perform any queued subscribes.
            helper.subscribeAll(component);
        });
        
        $A.enqueueAction(action);
    },
    
    // It is possible (likely) a Lightning Component on the page
    // will attempt to subscribe to a platform event before the
    // eventHub JavaScript static resource has loaded.
    // If the scripts have already loaded (indicated by sessionId
    // being truthy), the subscription is performed directly.
    // If not, it is queued in the subscriptions attribute and performed
    // by onJSLoaded later.
    doSubscribe: function(component, event, helper) {
       // console.log('doSubscribe');
        
        // Get the parameters from the aura method
        var params = event.getParam('arguments');
        if (params) {
            var sub = {"parentComponent" : params.component,
                       "eventName" : params.eventName,
                       "callback" : params.callback};
            
			var sessionId = component.get("v.sessionId");
        	if (!sessionId) {
            	// JavaScript has not yet loaded.
            	// Add to queue
            	var subscriptions = component.get("v.subscriptions");
                subscriptions.push(sub);
                component.set("v.subscriptions", subscriptions);
        	} else {
                // JavaScript is loaded.  Rock on.
            	helper.subscribe(component, sub);
        	}
        }        
    }
    
})