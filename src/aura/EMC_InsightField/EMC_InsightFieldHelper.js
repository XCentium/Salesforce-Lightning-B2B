({
    VERBOSE: false,
    prepopulate: function(component,field){
        let self = this;
        
        if(self.VERBOSE) console.log('InsightFieldHelper:prepopulate', field.parentType, field.lookupField,field.value);
        self.fireAction(component, 'c.getRecord', {
            sobjectType: field.parentType,
            sobjectField: field.lookupField,
            recordId: field.value
        })
        .then(function(record){
            if(self.VERBOSE) console.log('InsightFieldHelper:prepopulate', record);
            if(record.length > 0) component.set('v.searchTerm', record[0][field.lookupField]);
        })
    },
    formatTime : function(component, field){
		let self = this;
        
        return new Promise(function(resolve,reject){
            try {
                field.value = new Date(field.value);
                if(self.VERBOSE) console.log(field.value);
                
                component.set('v.field', field);
                resolve()
            } catch(err){
                reject(err)
            }
        })
	},
    fireAction : function(component, apexAction, apexActionParams, assignedVariable) {
        let self = this;
        
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get(apexAction);
        	if(self.VERBOSE) console.log('fireAction', apexAction, apexActionParams);
            
            action.setParams(apexActionParams);
            
            action.setCallback(self, function(res){
                let response = res.getReturnValue();
                let state = res.getState();
                let error = res.getError();
                
                if(state !== 'SUCCESS') reject(err);
                if(assignedVariable && assignedVariable != ''){
                    if(self.VERBOSE) console.log(assignedVariable, response);
                    component.set(assignedVariable, response);
                }
                
                console.log(state, response);
                
                resolve(response);
            })
            
            $A.enqueueAction(action);
        }))
    },
})