({
	getOrderDetails : function(component, recordId) {
        let self = this;
        
        return new Promise(
            $A.getCallback(function(resolve,reject){
                let action = component.get('c.getOrderDetails')
                
                action.setParams({
                    recordId: recordId
                })
                
                action.setCallback(this, function(res){
                    let state = res.getState()
                    let result = res.getReturnValue()
                    
                    if(state == 'SUCCESS'){
                        resolve(result);
                    } else {
                        let error = res.getError()
                        reject(error);
                    }
                })
                
                $A.enqueueAction(action);
            })
        )
	},
	getOrderLineItems : function(component, recordId) {
        let self = this;
        
        return new Promise(
            $A.getCallback(function(resolve,reject){
                let action = component.get('c.getOrderLineItems')
                
                action.setParams({
                    recordId: recordId
                })
                
                action.setCallback(this, function(res){
                    let state = res.getState()
                    let result = res.getReturnValue()
                    
                    if(state == 'SUCCESS'){
                        resolve(result);
                    } else {
                        let error = res.getError()
                        reject(error);
                    }
                })
                
                $A.enqueueAction(action);
            })
        )
	}
})