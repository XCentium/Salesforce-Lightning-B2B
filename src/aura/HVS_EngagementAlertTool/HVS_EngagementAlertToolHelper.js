({
    createEngagementHelper : function(component) {
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.createEngagement');
            let params = {
                channelType: component.get('v.ChannelType'),
                channelAction: component.get('v.ChannelAction'),
                channelVehicleId: component.get('v.ChannelVehicleId'),
                engagementDate: component.get('v.EngagementDateTime'),
                targetId: component.get('v.recordId'),
                templateId: component.get('v.TemplateId')
            }
            
            console.log(params)
            
            action.setParams(params)
            
            action.setCallback(this,function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    console.log(retVal);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log(err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    }
})