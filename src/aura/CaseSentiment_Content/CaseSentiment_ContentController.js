({
    doInit : function(component, event, helper) {
        component.set('v.cardLabel', 'Case Sentiment');
        
        let action = component.get('c.getCaseAnalysis');
        
        action.setParams({
            caseId: component.get('v.recordId')
        })
        
        action.setCallback(this, function(res){
            let state = res.getState();
            let retVal = res.getReturnValue();
            console.log(retVal);
            
            if(state === 'SUCCESS'){
                if(retVal){
                    console.log(JSON.stringify(retVal, null, 2))
                    component.set('v.analysis', retVal);
                    component.set('v.hasData', true);
                }
            } else {
                console.log(res.getError());
            }
        })
        
        $A.enqueueAction(action);
    }
})