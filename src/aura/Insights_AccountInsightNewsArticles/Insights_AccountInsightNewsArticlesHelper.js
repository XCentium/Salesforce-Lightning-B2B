({	
    VERBOSE: true,
    validateProtocol: function(url) {
        var pattern = new RegExp('^(https?:\/\/)')
        if(!pattern.test(url)) {
            return 'http://' + url;
        } else {
            return url;
        }
    },
    showToast : function(component, params){
        let self = this;
        return new Promise(
            $A.getCallback(function(resolve,reject){
                try {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(params);
                    toastEvent.fire();
                    resolve();
                } catch (err){
                    reject(err);
                }
            })
        )
    },
    goToState : function(component, state) {
        let self = this;
        
        return new Promise(
            $A.getCallback(function(resolve, reject){
                try{
                    component.getEvent('renderPanel')
                    .setParams(state)
                    .fire()
                    
                    resolve()
                } catch(err){
                    reject(err)
                }
            })
        )
    },
    sendRequest : function(component, actionName, params, callback){
        let self = this;
        
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get(actionName);
            
            action.setParams( params )
            
            action.setCallback(this, function(res){
                let state = res.getState()
                let retVal = res.getReturnValue()
                let error = res.getError()
                
                if(state !== 'SUCCESS') {
                    reject(error)
                }
                
                if(self.VERBOSE) console.log('Recieved:' + actionName, retVal)
                
                if(callback != null && callback != '') {
                    if(self.VERBOSE) console.log(callback)
                    if(typeof callback == 'function') callback(component, retVal)
                    if(typeof callback != 'function') component.set(callback, retVal)
                        }
                
                resolve(retVal)
            })
            
            if(self.VERBOSE) console.log('Firing:' + actionName, params, action);
            
            $A.enqueueAction(action);
        }))
    }
})