({
    connectCometd : function(component) {
        let helper = this;
        
        // Configure CometD
        let cometdUrl = window.location.protocol+'//'+window.location.hostname+(window.location.port ? (':' + window.location.port) : '')+'/cometd/40.0/';
        let cometd = component.get('v.cometd');
        cometd.configure({
            url: cometdUrl,
            requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
            appendMessageTypeToURL : false,
            stickyReconnect: false,
            logLevel: 'info'
        });
        cometd.websocketEnabled = false;
        
        cometd.addListener('/meta/connect', function(message) {
            if(!message.successful) {
                
                //if(reconnect && reconnect!==undefined && reconnect != null) {
                if(message.error.includes('403')) {
                    console.log('Connection Error', JSON.stringify(message, null, 2 ));
                }
            }
            if(message.successful) {
                console.log('Connection Error', JSON.stringify(message, null, 2 ));
            }
        });
        
        // Establish CometD connection
        console.log('Connecting to CometD: '+ cometdUrl);
        
        cometd.handshake(function(handshakeReply) {
            console.log('handshakeReply',JSON.stringify(handshakeReply, null, 2 ));
            if (handshakeReply.successful) {
                console.log('Connected to CometD.');
                // Subscribe to platform event
                let subscriptions = component.get('v.cometdSubscriptions');
                let newSubscription = null;
                if(subscriptions.length == 0){
                    newSubscription = cometd.subscribe('/event/Notification__e', function(platformEvent) {
                        console.log('Platform event received: '+ JSON.stringify(platformEvent));
                        helper.onReceiveNotification(component, platformEvent);
                    });
                }
                
                console.log('newSubscription', JSON.stringify(newSubscription, null, 2));
                
                // Save subscription for later
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
            }
            else {
                console.error('Failed to connected to CometD.');
            }
        });
    },
    
    disconnectCometd : function(component) {
        let cometd = component.get('v.cometd');
        
        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            let subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function (subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);
        
        // Disconnect CometD
        cometd.disconnect();
        console.log('CometD disconnected.');
    },
    
    onReceiveNotification : function(component, platformEvent) {
        let helper = this;
        
        // Extract notification from platform event
        let newNotification = {
            time : $A.localizationService.formatDateTime(
                platformEvent.data.payload.CreatedDate, 'h:mm a'),
            message : platformEvent.data.payload.Message__c
        };
        
        // Save notification in history
        let notifications = component.get('v.notifications');
        notifications.push(newNotification);
        component.set('v.notifications', notifications);
        
        // Display notification in a toast if not muted
        if (!component.get('v.isMuted'))
            helper.displayToast(component, 'info', newNotification.message);
    },
    
    displayToast : function(component, type, message) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})