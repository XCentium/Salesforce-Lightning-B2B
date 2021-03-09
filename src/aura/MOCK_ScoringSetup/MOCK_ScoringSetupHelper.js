({
    saveScore : function(component) {
        
        let action = component.get('c.saveScore');
        let score = component.get('v.score');
        action.setParams({
            score: JSON.stringify(score)
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            
            if(state === 'SUCCESS'){
                this.saveScoreReasons(component, retVal);
            } else if(state === 'INCOMPLETE'){
                console.log('INCOMPLETE', res.getError())
            } else {
                console.log('ERROR', res.getError());
            }
        })
        
        $A.enqueueAction(action);
    },
    saveScoreReasons : function(component, scoreId){
        
        let action = component.get('c.saveScoreReasons');
        let reasons = component.get('v.reasons');
        
        action.setParams({
            scoreId: scoreId,
            sReasons: JSON.stringify(reasons)
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            
            if(state === 'SUCCESS'){
                console.log('Reasons',retVal);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success!",
                    "message": "Score Reasons Saved",
                    "type": "success"
                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else if(state === 'INCOMPLETE'){
                console.log('INCOMPLETE', res.getError())
            } else {
                console.log('ERROR', res.getError());
            }
        })
        
        $A.enqueueAction(action);
    },
    deleteReason : function(component, reasonId, reasonIndex){
        let action = component.get('c.deleteReasonDB');
        let reasons = component.get('v.reasons');
        
        action.setParams({
            'scoreReasonId': reasonId
        })
        
        action.setCallback(this, function(res){
            let retVal = res.getReturnValue();
            let state = res.getState();
            if(state === 'SUCCESS'){
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success!",
                    "message": "Score Reason Deleted",
                    "type": "success"
                });
                resultsToast.fire();
                
                reasons.splice(reasonIndex, 1);
                component.set('v.reasons', reasons);
            } else {
                console.log('ERROR', res.getError());
            }
        })
        
        $A.enqueueAction(action);
    }
})