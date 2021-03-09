({
    doInit : function(component, event, helper) {
        let recId = component.get('v.recordId');
        let action = component.get('c.getContact');
        
        action.setParams({recId : recId});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                let val = response.getReturnValue();
                let fieldsListVals = helper.splitString(component.get('v.fieldsListString'));
                component.set('v.contact', val.c);
                component.set('v.user', val.u);   
                component.set('v.fieldsList', fieldsListVals);
            }
            else {
                console.log("FAILED: Failed with state" + state);
            }
        });
        
        $A.enqueueAction(action);                
    },
    
    handleDropdownSelect : function(component, event, helper) {
        var selectedVal = event.getParam("value");
        if(selectedVal == 'View') {
            helper.viewRecord(component.get('v.contact.Id'));
        } else if (selectedVal == 'Edit') {
            component.set('v.showEdit', true);
        }
    }
})