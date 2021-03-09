({
    VERBOSE: true,
    getAssignments: function(component, insight){
        let self = this;
        
        self.fireAction(component, 'c.getInsightUserValues', {
            insightId:insight.Id
        })
        .then(function(assignments){
            if(self.VERBOSE) console.log('InsightAssignments:getAssignments',assignments);
            component.set('v.assignments', assignments)
        })
    },
    fireAction : function(component, apexAction, apexActionParams, assignedVariable) {
        let self = this;
        if(self.VERBOSE) console.log('fireAction', apexAction, apexActionParams);
        
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get(apexAction);
            
            action.setParams(apexActionParams);
            
            action.setCallback(this, function(res){
                let response = res.getReturnValue();
                let state = res.getState();
                let error = res.getError();
                
                if(state !== 'SUCCESS') {
                    console.log('ERROR:'+apexAction, error);
                    reject(error);
                }
                if(assignedVariable && assignedVariable != ''){
                    if(self.VERBOSE) console.log(assignedVariable, response);
                    component.set(assignedVariable, response);
                }
                
                resolve(response);
            })
            
            $A.enqueueAction(action);
        }))
    }
})