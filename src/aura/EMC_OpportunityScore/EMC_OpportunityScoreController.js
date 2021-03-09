({
    onInit : function(component, event, helper) {
        let action = component.get('c.getOpportunityScore');
        let opportunityId = component.get('v.recordId');
        
        action.setParams({
            opportunityId: opportunityId
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            console.log(retVal[0]);
            
            if(state === 'SUCCESS'){
                let score = retVal[0];
                let reasons = score && score.Insights ? JSON.parse(score.Insights) : [];
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
        let baseId = component.get('v.recordId');
        let reasons = component.get('v.reasons');
        let reason = {
            intensity: 1, 
            intensityLevel: "HIGH_POS",
            title: {
                label:"AMOUNT_INCREASE_P",
                formatter: "custom",
                formatString: "Higher likelihood to win when amount went up significantly"
            }
        }
        reasons.push(reason);
        component.set('v.reasons', reasons);
    },
    deleteReason : function(component, event, helper){
        let reasons = component.get('v.reasons');
        let reasonIndex = event.getParam('index');
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