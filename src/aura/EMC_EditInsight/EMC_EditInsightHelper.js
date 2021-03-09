({
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
                
                if(state !== 'SUCCESS') reject(err);
                if(assignedVariable && assignedVariable != ''){
                    if(self.VERBOSE) console.log(assignedVariable, response);
                    component.set(assignedVariable, response);
                }
                
                resolve(response);
            })
            
            $A.enqueueAction(action);
        }))
	},
})