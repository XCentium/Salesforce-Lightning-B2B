({
    getAccount: function(component, recordId) {
        let self = this;
        
        return new Promise(
            $A.getCallback(function(resolve,reject){
                let action = component.get('c.getRecordDetails')
                
                action.setParams({
                    recordId: recordId
                })
                
                action.setCallback(this, function(res){
                    let state = res.getState()
                    let result = res.getReturnValue()
                    
                    if(state == 'SUCCESS'){
                        resolve()
                    } else {
                        let error = res.getError()
                        reject(error);
                    }
                })
                
                $A.enqueueAction(action);
            })
        )
    },
    getAddresses: function(component, recordId){
        let self = this;
        
        return new Promise(
            $A.getCallback(function(resolve,reject){
                let action = component.get('c.getAccountAddresses')
                
                action.setParams({
                    recordId: recordId
                })
                
                action.setCallback(this, function(res){
                    let state = res.getState()
                    let result = res.getReturnValue()
                    
                    console.log(JSON.stringify(result,null,2))
                    
                    if(state == 'SUCCESS'){
                        component.set('v.addresses',result)
                        resolve()
                    } else {
                        let error = res.getError()
                        reject(error)
                    }
                })
                
                $A.enqueueAction(action);
            })
        )
    }
})