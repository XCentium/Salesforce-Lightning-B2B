({   
	GetProducts : function(component, event, helper) {
        var action = component.get("c.getProduct");
        action.setParams({
            ProductID : component.get("v.ProductID"),
            ProductID2 : component.get("v.ProductID2")
        });
		action.setCallback(this, function(response) {
            console.log(response);
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ReturnedProduct",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    handleClick:function(component,event,helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log(response);
        	console.log(response.recordId);
            console.log(response.title);
      	})
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            message: "Added recommendation to chat!",
            type: "success"
        });
        toastEvent.fire();
    }
})