({
    doInit : function(component, event, helper) {
        var recid = component.get("v.recordId");
        console.log("opportunity id: " + recid);
        component.set('v.cardLabel','Einstein Discovery')
        
        var action = component.get("c.getEDInfo");
        action.setParams({
            "caseId": recid
        });
        action.setCallback(component, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            
            if (state === 'SUCCESS'){
                
                $('.slds-card__header slds-grid').hide();
                $('#csat').html(myUtil.round(result.ED_Outcome__c, 1));
                $('#leadingCauses').html(myUtil.populateTable(result.ED_Leading_Causes__c));
                $('#recommendedImprovements').html(myUtil.populateTable(result.ED_Prescription__c));
                
            } 
        });
        $A.enqueueAction(action);
    }, 
    
    refresh : function(component, event, helper) {
        var action = component.get('c.getEDInfo');
        action.setCallback(component,
                           function(response) {
                               var state = response.getState();
                               if (state === 'SUCCESS'){
                                   $A.get('e.force:refreshView').fire();
                               } else {
                                   //do something
                               }
                           }
                          );
        $A.enqueueAction(action);
    }
    
 
 })