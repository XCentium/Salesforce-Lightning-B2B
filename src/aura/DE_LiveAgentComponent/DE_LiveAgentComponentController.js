({
    doInit : function(cmp, event, helper) {
        liveagent.setChatWindowHeight(480);
        liveagent.setChatWindowWidth(320);
        //alert(cmp.get("v.buttonId"));        
        if(cmp.get("v.buttonId")==''){
            var action2 = cmp.get("c.LiveAgentButtonId");
            action2.setCallback(this, function(response) {
                var state = response.returnValue;
                cmp.set("v.buttonId",state);
                //alert(state);
            });
            $A.enqueueAction(action2);
        }
        
        if(cmp.get("v.deploymentId")==''){
            var action3 = cmp.get("c.getLiveAgentDeploymentId");
            action3.setCallback(this, function(response) {
                var state = response.returnValue;
                cmp.set("v.deploymentId",state);
                //alert(state);
            });
            $A.enqueueAction(action3);
        }
        
        var action = cmp.get("c.getOrgId");
        action.setCallback(this, function(response) {
            var state = response.returnValue;
            //alert(state);
            cmp.set("v.orgId",state);
            liveagent.init(cmp.get("v.apiEndpoint"), cmp.get("v.deploymentId"), cmp.get("v.orgId"));
            // liveagent.init('https://d.la2-c1-dfw.salesforceliveagent.com/chat', '5725Y000000Lcal', '00D5Y000001QDus');
            var buttonId = cmp.get("v.buttonId");
            if (!window._laq) { window._laq = []; }
            window._laq.push(function(){liveagent.showWhenOnline(buttonId, document.getElementById('liveagent_button_online_' + buttonId));
                                        liveagent.showWhenOffline(buttonId, document.getElementById('liveagent_button_offline_' + buttonId));
                                       });
        });
        $A.enqueueAction(action); 
    },
    startChat : function(cmp) {
        var buttonId = cmp.get("v.buttonId");
        liveagent.startChat(buttonId);
    }
})