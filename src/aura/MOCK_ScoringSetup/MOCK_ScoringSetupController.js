({
    onInit : function(component, event, helper) {
        let action = component.get('c.getScoreData');
        let recordId = component.get('v.recordId');
        let parentObjectType = recordId.startsWith('006') ? 'Opportunity': 'Lead';
        let parentLookupField = parentObjectType + '__c';
        component.set('v.parentObjectType', parentObjectType);
        
        action.setParams({
            recordId: recordId,
            parentObjectType: parentObjectType
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            console.log(retVal);
            
            if(state === 'SUCCESS'){
                let score = retVal.score;
                let reasons = retVal.scoreReasons;
                //Check if score returned
                if(!score.Id){
                    score['Parent_Object_Type__c'] = parentObjectType;
                    score[parentLookupField] = recordId;
                }
                
                //Check if it is pulling from a default
                if(score[parentLookupField] != recordId && score.Default__c) {
                    score['Parent_Object_Type__c'] = parentObjectType;
                    score[parentLookupField] = recordId;
                    score.Default__c = false;
                    delete score.Id;
                    
                    reasons.forEach(function(reason){
                        delete reason.Id;
                    })
                }
                
                component.set('v.score', score);
                component.set('v.reasons', reasons);
                
            } else if(state === 'INCOMPLETE'){
                
            } else {
                console.log('ERROR', res.getError());
            }
        })
        
        $A.enqueueAction(action);
    },
    addReason : function(component, event, helper){
        let reasons = component.get('v.reasons');
        let reason = {'Confidence__c': null, 'Reason__c': null}
        reasons.push(reason);
        component.set('v.reasons', reasons);
    },
    deleteReason : function(component, event, helper){
        let reasons = component.get('v.reasons');
        let reasonIndex = event.getSource().get('v.value');
        let reason = reasons[reasonIndex];
        console.log('reason',reason);
        
        if(reason.hasOwnProperty('Id')){
            helper.deleteReason(component, reason.Id, reasonIndex);
        } else {
            reasons.splice(reasonIndex, 1);
            component.set('v.reasons', reasons);
        }
    },
    save : function(component, event, helper){
        helper.saveScore(component);
    },
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})