({
    // Uses the eventHub static resource library to subscribe to 
    // the event defined by the subscription arguement.
    subscribe: function(component, subscription) {
        console.log('Subscribing to ' + subscription.eventName);
        var sessionId = component.get('v.sessionId');

        // Subscribe to the event using the static resource singleton
        eventHub.subscribe(
            sessionId, 
            subscription.parentComponent, 
            subscription.eventName, 
            subscription.callback,
            component.get('v.showHistorical')
        );
    },
    
    // Performs all the event subscriptions queued up in the 
    // subscriptions attribute.
    subscribeAll: function(component) {
        console.log('Subscribing to all events');
        var helper = this;
        
        var subscriptions = component.get('v.subscriptions');
        subscriptions.forEach (function(subscription) {
            helper.subscribe(component, subscription); 
        }); 
    }
})