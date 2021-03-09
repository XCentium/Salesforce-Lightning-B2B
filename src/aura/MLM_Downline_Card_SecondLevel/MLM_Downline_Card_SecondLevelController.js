({
	getDownline : function(component, event, helper) {
        console.log('Contact ID: ' + component.get("v.recordId"));
        
        var action1 = component.get("c.GetContactDownlineCount");
        action1.setParams({
            ContactID: component.get("v.recordId")
        });
		action1.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.downlineCount",response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
        
        
		var action = component.get("c.GetContactDownline");
        action.setParams({
            ContactID: component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.downline",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    viewMore : function(component, event, helper) {
        var whichone = event.currentTarget.id;
        console.log("Which One: " + whichone); 
        component.set("v.SelectedContactId", whichone);
        
        /*Use Workspace API to open new console tab*/
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: whichone,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                  tabId: response
            }).then(function(tabInfo) {
            });
        })
        .catch(function(error) {
               console.log(error);
        });
    }
})