({
	getAvailableStatus : function(component) {
		var action = component.get("c.getAvailableStatusId");
		action.setCallback(this, function(a) {
			component.set("v.availableStatusId", a.getReturnValue());
		});
		$A.enqueueAction(action);
	},


	getBusyStatus : function(component) {
		var action = component.get("c.getBusyStatusId");
		action.setCallback(this, function(a) {
			component.set("v.busyStatusId", a.getReturnValue());
		});
		$A.enqueueAction(action);
	},


	sendNotification : function(component, status) {
		var message = '';

        if(status == 'Phone - Available') {
            message = 'available';
        } else {
            message = 'busy';
        }

 	   var myArray = [];
 	   myArray.push(message);

 	   var action = component.get("c.publishNotifications");
 	   action.setParams({
 		   "messages": myArray,
 		   "target": 'statusDropdown'
 	   });
 	   action.setCallback(this, function(a) {
 	   });
 	   $A.enqueueAction(action);
   },



   connectCometd: function(component) {
	   try {
		   var helper = this;
		   // Configure CometD
		   var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/40.0/';
		   var cometd = component.get('v.cometd');

		   cometd.configure({
			   url: cometdUrl,
			   requestHeaders: {
				   Authorization: 'OAuth ' + component.get('v.sessionId')
			   },
			   appendMessageTypeToURL: false
		   });
		   cometd.websocketEnabled = false;
		   // Establish CometD connection
		   console.log('Connecting to CometD: ' + cometdUrl);
		   cometd.handshake(function(handshakeReply) {
			   if (handshakeReply.successful) {
				   console.log('Connected to CometD.');
				   // Subscribe to platform event
				   var newSubscription = cometd.subscribe('/event/CTI_Status_Changed__e',
					   function(platformEvent) {
						   helper.statusReceived(component, helper, platformEvent);
					   }
				   );
				   // Save subscription for later
				   var subscriptions = component.get('v.cometdSubscriptions');
				   subscriptions.push(newSubscription);
				   component.set('v.cometdSubscriptions', subscriptions);
			   } else
				   console.error('Failed to connected to CometD.');
		   });
	   } catch(exp) {
		   console.log('exception : ' + exp);
	   }
   },
   disconnectCometd: function(component) {
	   var cometd = component.get('v.cometd');
	   // Unsuscribe all CometD subscriptions
	   cometd.batch(function() {
		   var subscriptions = component.get('v.cometdSubscriptions');
		   subscriptions.forEach(function(subscription) {
			   cometd.unsubscribe(subscription);
		   });
	   });
	   component.set('v.cometdSubscriptions', []);
	   // Disconnect CometD
	   cometd.disconnect();
	   console.log('CometD disconnected.');
   },
   onReceiveNotification: function(component, platformEvent) {
	   var helper = this;
	   // Extract notification from platform event
	   var newNotification = {
		   time: $A.localizationService.formatDateTime(
			   platformEvent.data.payload.CreatedDate, 'HH:mm'),
		   message: platformEvent.data.payload.Status__c
	   };
	   // Save notification in history
	   var notifications = component.get('v.notifications');
	   notifications.push(newNotification);
	   component.set('v.notifications', notifications);
	   // Display notification in a toast if not muted
	   if (!component.get('v.isMuted'))
		   helper.displayToast(component, 'info', newNotification.message);
   },
   displayToast: function(component, type, message) {
	   var toastEvent = $A.get('e.force:showToast');
	   toastEvent.setParams({
		   type: type,
		   message: message
	   });
	   toastEvent.fire();
   },

   statusReceived : function(component, helper, platformEvent) {
	   console.log('statusReceived');
	   var status = platformEvent.data.payload.Status__c;
	   var target = platformEvent.data.payload.Target__c;

	   if(target == 'Omni_CTI_Sync') {
		   if(status == 'available') {
			   helper.setOmniStatus(component, component.get('v.availableStatusId'));
		   }

		   if(status == 'busy') {
			   helper.setOmniStatus(component, component.get('v.busyStatusId'));
		   }
	   }
   },

   setOmniStatus : function(component, mystatusId) {
	   mystatusId = mystatusId.slice(0, -3);
	   var omniAPI = component.find("omniToolkit");
	   omniAPI.setServicePresenceStatus({
		   statusId: mystatusId,
		   callback: function(result) {
			   if (result.success) {
				   // console.log('Set status successful');
			   } else {
				   console.log('Set status failed');
			   }
		   }
	   });
   }


})