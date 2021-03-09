({
    VERBOSE: true,
    getInsights : function(component) {
        return this.sendRequest(
            component, 
            'c.getCampaignRationales', 
            { 
                campaignInsightId: component.get('v.campaignInsightId') 
            },
            'v.rationales'
        );
    },
    sendRequest : function(component, actionName, params, callback){
        let self = this;
        
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get(actionName);
            let campaignId = component.get('v.recordId');
            
            action.setParams( params )
            
            action.setCallback(this, function(res){
                let state = res.getState();
                let retVal = res.getReturnValue();
                let error = res.getError();
                
                if(state !== 'SUCCESS') {
                    reject(error);
                }
                
                if(self.VERBOSE) console.log(actionName, JSON.stringify(retVal, null, 2));
                if(callback != null && callback != '') {
                    if(typeof callback == 'function') callback(component, retVal);
                    if(typeof callback != 'function') component.set(callback, retVal)
                        };
                
                resolve(retVal);
            })
            
            if(self.VERBOSE) console.log('Firing:' + actionName, params, action);
            
            $A.enqueueAction(action);
        }))
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
    }
})