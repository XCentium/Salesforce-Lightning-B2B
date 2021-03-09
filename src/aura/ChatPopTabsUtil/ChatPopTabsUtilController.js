({
    openTabWithSubtab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var action = component.get("c.getChatRecords");
        action.setParams({ recordId : component.get('v.recordId') });
       
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var vc = response.getReturnValue();
//helper.setTabLabels(component, event, helper, vc);
                helper.openSubTabs(component, event, helper, vc);
            }
            else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);              
    }
})