({
	onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null)
        helper.connectCometd(component);
    },

	onStatusChanged : function(component, event, helper) {
       // console.log("Status changed. omniListener");
       var statusId = event.getParam('statusId');
       var channels = event.getParam('channels');
       var statusName = event.getParam('statusName');
       var statusApiName = event.getParam('statusApiName');
       // console.log(statusId);
       // console.log(channels);
       // console.log('statusName : ' + statusName);
       // console.log(statusApiName);

	   helper.sendNotification(component, statusName);
   },


   init : function(component, event, helper) {
	   component.set('v.cometdSubscriptions', []);
	   component.set('v.notifications', []);
	   // Disconnect CometD when leaving page
	   window.addEventListener('unload', function(event) {
		   helper.disconnectCometd(component);
	   });
	   // Retrieve session id
	   var action = component.get('c.getSessionId');
	   action.setCallback(this, function(response) {
		   if (component.isValid() && response.getState() === 'SUCCESS') {
			   component.set('v.sessionId', response.getReturnValue());
			   if (component.get('v.cometd') != null)
			   console.log('about to call the helper');
			   helper.connectCometd(component);
		   }
		   else
		   console.error(response);
	   });
	   $A.enqueueAction(action);

	   helper.getAvailableStatus(component);
	   helper.getBusyStatus(component);
   },


   omniLoggedIn : function(component, event, helper) {
	   var omniAPI = component.find("omniToolkit");
	   omniAPI.getServicePresenceStatusId({
		   callback: function(result) {
			   if (result.success) {
				   console.log('Get Status Id successful');
				   console.log('Status Id is: ' + result.statusId);
				   omniAPI.setServicePresenceStatus({
					   statusId: result.statusId,
					   callback: function(res) {
						   if (res.success) {
							   console.log('Set status successful');
						   } else {
							   console.log('Set status failed');
						   }
					   }
				   });
			   } else {
				   console.log('Get Status Id failed');
			   }
		   }
	   });
   }




})