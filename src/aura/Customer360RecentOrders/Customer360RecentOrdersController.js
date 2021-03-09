({
    doInit : function(component, event, helper) {
        var currentRecord = component.get("v.recordId");
        var fieldsToUse = []; 
        var typeOfObject;
        var fieldsArray;
        var attrCounter = 1; 
        console.log('init hit')
        console.log('doInit and current record Id = ' + currentRecord)
        typeOfObject = currentRecord.slice(0,3);
        if(typeOfObject == '003'){
            console.log('typeOfObject is Contact')
            var action = component.get('c.getRecentOrderFromContact');
            action.setParams({
                'contactId' : component.get("v.recordId"),
            })
            action.setCallback(this,function(response){
                var state = response.getState();
                var orderRecords = response.getReturnValue();
                console.log(state);
                console.log(Object.values(orderRecords))
                if(state == "SUCCESS"){
                    component.set('v.recentOrders', orderRecords)
                    
                } else if(state == "ERROR"){
                    console.log('ERROR');
                } 
            })
            $A.enqueueAction(action)
        } else if (typeOfObject == '500'){
            console.log('typeOfObject is Case')
            var action = component.get('c.getRecentOrderFromCase');
            action.setParams({
                'caseId' : component.get("v.recordId"),
            })
            action.setCallback(this,function(response){
                var state = response.getState();
                var orderRecords = response.getReturnValue();
                console.log(state);
                console.log(orderRecords)
                if(state == "SUCCESS"){
                    component.set('v.recentOrders', orderRecords)
                    
                } else if(state == "ERROR"){
                    console.log('ERROR');
                } 
            })
            $A.enqueueAction(action)
        } else if (typeOfObject == '001'){
            console.log('typeOfObject is Account')
            var action = component.get('c.getRecentOrder');
            action.setParams({
                'accountId' : component.get("v.recordId"),
            })
            action.setCallback(this,function(response){
                var state = response.getState();
                var orderRecords = response.getReturnValue();
                console.log(state);
                console.log(Object.values(orderRecords))
                if(state == "SUCCESS"){
                    component.set('v.recentOrders', orderRecords)
                    
                } else if(state == "ERROR"){
                    console.log('ERROR');
                } 
            })
            $A.enqueueAction(action)
        } else {
            console.log('Error')            
        }
        
    },
    setCurrentId : function(component, event, helper) {
        console.log('test')
        console.log(event.currentTarget.id)
        component.set('v.selectedId', event.currentTarget.id)
    },
})