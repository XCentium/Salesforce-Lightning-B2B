({
    saveScore : function(component) {
        let action = component.get('c.saveOpportunityScore');
        let score = component.get('v.score');
        let reasons = component.get('v.reasons');
        let recordId = component.get('v.recordId');
        
        score['BaseId'] = recordId
        score['Insights'] = JSON.stringify(reasons)
        
        action.setParams({
            scoreData: score
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            
            if(state === 'SUCCESS'){
                this.sendMixpanelEvent(
                    component, 
                    $A.getCallback(function(){
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }))
            } else if(state === 'INCOMPLETE'){
                console.log('INCOMPLETE', res.getError())
            } else {
                console.log('ERROR', res.getError());
            }
        })
        
        $A.enqueueAction(action);
    },
    sendMixpanelEvent: function(component, callback){
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'SDO Event',
            payload: {
                action: 'Score Opportunity'
            }
        });
        
        mixpanelEvent.fire();
        
        if(callback){
            callback();
        }
    }
})