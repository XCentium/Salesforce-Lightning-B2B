({
    doInit : function(component, event, helper) {
		var action = component.get("c.getActivePricebooks");
        action.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId : component.get("v.recordId")
        });
	    action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var options = a.getReturnValue();
				component.set('v.options',options);
                for (var i = 0; i < options.length; i++) {
                    if (options[i].selected){
                      component.set("v.selectedValue",options[i].value);  
                      component.set("v.currentPricebookId",options[i].value);
                      component.set("v.currentPricebookName",options[i].label);  
                    }    
                }
            }else if (state === "ERROR") {
                helper.showToast(component,event,'Error','Couldn\'t load pricebooks','error'); 
            } 
           component.set("v.isApexInProgress",false);     
        });

        $A.enqueueAction(action);
        component.set("v.isApexInProgress",true);
	},
    
	closeModal : function(component, event, helper) {
		component.destroy();
	},
    changePB : function(component, event, helper) {
       var action = component.get("c.setPricebook");
         action.setParams({
            parentObjName : component.get("v.sObjectName"),
            parentRecId : component.get("v.recordId"),
            pricebookId : component.get("v.selectedValue") 
          });
	      action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
				helper.showToast(component,event,'Success','Pricebook changed!','success');
                component.getEvent("reloadPricer").fire();
            }else if (state === "ERROR") {
                helper.showToast(component,event,'Error','Couldn\'t change pricebook :(','error'); 
            } 
           component.set("v.isApexInProgress",false);   
           component.destroy();   
        });

        if (component.get("v.selectedValue") != component.get("v.currentPricebookId")){
           $A.enqueueAction(action);
           component.set("v.isApexInProgress",true);  
        } 
        else 
    	component.destroy();   
		
	}
})