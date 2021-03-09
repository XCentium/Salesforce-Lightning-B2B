({
    VERBOSE: false,
    excludedInsights: [
        'ContactLeaving',
        'NoCommunication',
        'ProspectUnresponsive',
        'CompetitorMentioned'
    ],
    requiredFieldsMap: {
        'ProspectUnresponsive': [ 'ExpectedHeardWithinDays', 'ActualHeardWithinDays' ],
        'NoCommunication': [ 'ExpectedHeardWithinDays', 'ActualHeardWithinDays' ],
        'CompetitorMentioned': [ 'CompetitorName', 'ContactName', 'ContactTitle', 'Activity' ]
    },
    hasRequiredFields: function(component){
        let self = this
        let insight = component.get('v.insight')
        
        return new Promise(
            $A.getCallback(function(resolve,reject){
                let requiredFields = self.requiredFieldsMap[insight.Type]
                let isValid = true
                
                try{
                    if(requiredFields){
                        requiredFields.map(function(requiredField){
                            if(insight[requiredField] == null || insight[requiredField] == '') {
                                isValid = false
                            }
                        })
                    }
                    resolve(isValid)
                } catch(err){
                    reject(err)
                }
            })
        )
    },
    getTypes : function(component) {
        let helper = this;
        return this.sendRequest(
            component,
            'c.getPicklistOptions',
            {
                sobjectName: 'AccountInsight',
                fieldName: 'Type'
            },
            function(component, options){
                let insight = component.get('v.insight');
                if(insight && insight.Type){
                    options.map(function(option){
                        if( option.value == insight.Type ){
                            option['selected'] = true;
                        }
                    })
                }
                
                options = options.filter(function(option){
                    return helper.excludedInsights.indexOf(option.value) == -1
                })
                
                component.set('v.typeOptions', options)
            }
        );
    },
    getTrendTypes : function(component){
        return this.sendRequest(
            component,
            'c.getPicklistOptions',
            {
                sobjectName: 'AccountInsight',
                fieldName: 'TrendType'
            },
            function(component, options){
                let insight = component.get('v.insight');
                if(insight && insight.TrendType){
                    options.map(function(option){
                        if( option.value == insight.TrendType ){
                            option['selected'] = true;
                        }
                    })
                }
                component.set('v.trendTypeOptions', options)
            }
        );
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
            let accountId = component.get('v.recordId');
            
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