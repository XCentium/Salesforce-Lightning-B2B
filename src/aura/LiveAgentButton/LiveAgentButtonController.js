({
    doInit : function(component, event, helper) {
		var action = component.get("c.getId");        
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            var buttonID = data.Chat_Button_ID__c;
            window.id = buttonID;
 			var deploymentID1 = data.Deployment_ID_1__c;
            var deploymentID2 = data.Deployment_ID_2__c;
            component.set("v.liveAgentId",buttonID);
            component.set("v.deploymentID1",deploymentID1);
            component.set("v.deploymentID2",deploymentID2);
             setTimeout(function(){
                if (!window._laq) { window._laq = []; }
					window._laq.push(function(){liveagent.showWhenOnline(buttonID, document.getElementById('liveagent_button_online_' + buttonID));
					liveagent.showWhenOffline(buttonID, document.getElementById('liveagent_button_offline_' + buttonID));
				});
                liveagent.init('https://d.la1w1.salesforceliveagent.com/chat', deploymentID1, deploymentID2);
            }, 1000)
        });
        // Invoke the service
        $A.enqueueAction(action);
	},
    
	startChat : function(component, event, helper) {
		liveagent.startChat(window.id);
	}
    
    

})