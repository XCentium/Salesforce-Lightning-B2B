({
    VERBOSE: true,
    toggleLoading: function(component, shown){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let spinner = component.find('spinner');
            if(!shown) $A.util.addClass(spinner, 'hidden');
            if(shown) $A.util.removeClass(spinner, 'hidden');
            if(self.VERBOSE) console.log('SUCCESS:toggleLoading', shown);
            resolve();
        }));
    },
    getLeadFields : function(component) {
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.getLeadFields');
            
            action.setCallback(this,function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    let fields = JSON.parse(retVal);
                    let leadFieldsMap = new Map();
                    
                    fields = fields.filter(function(field){
                        return field.updateable == true 
                        && field.externalId == false 
                        && field.type != 'reference' 
                        && field.type != 'id'
                    })
                    
                    fields.sort(function(a,b){
                        if(a.label < b.label) return -1;
                        if(a.label > b.label) return 1;
                        return 0;
                    });
                   
                    fields.map(function(field){
                        leadFieldsMap.set(field.name, field);
                    })
                    
                    if(self.VERBOSE) console.log('SUCCESS:getLeadFields', fields, leadFieldsMap);
                    component.set('v.leadFields', fields);
                    component.set('v.leadFieldsMap', leadFieldsMap);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log('ERROR:LeadFields', err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    getLeadData : function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let leadId = component.get('v.recordId');
            let action = component.get('c.getLeadData');
            
            action.setParams({
                leadId: leadId
            })
            
            action.setCallback(this,function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCES:getLeadData',retVal);
                    component.set('v.lead', retVal);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log('ERROR:getLeadData', err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    getLeadIQConfiguration: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.getLeadIQConfiguration');
            
            action.setCallback(this,function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:getLeadIQConfiguration', retVal[0]);
                    component.set('v.leadIQConfig', retVal[0]);
                    resolve(retVal[0]);
                } else {
                    let err = res.getError();
                    console.log('ERROR:getLeadIQConfiguration', err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    getModelFactors: function(component, version){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.getModelFactor');
            
            action.setParams({
                version: version 
            })
            
            action.setCallback(this,function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:getModelFactor', retVal);
                    component.set('v.modelFactors', retVal);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log('ERROR:getModelFactor', err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    getScoreIntelligence : function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let leadId = component.get('v.recordId');
            let action = component.get('c.getScoreIntelligence');
            
            action.setParams({
                leadId: leadId
            })
            
            action.setCallback(this,function(res){            
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:getScoreIntelligence',retVal);
                    let scoreIntelligence = {};
                    if(retVal.length == 0) {
                        scoreIntelligence = {
                            BaseId: leadId,
                            Score: 99
                        }
                    }
                    if(retVal.length > 0) {
                        scoreIntelligence = retVal[0]
                        delete scoreIntelligence.Id;
                    }
                    
                    component.set('v.scoreIntelligence', scoreIntelligence);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log('ERROR:getScoreIntelligence', err);
                    reject(err)
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    getLeadInsights: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let leadId = component.get('v.recordId');
            let action = component.get('c.getLeadInsights');
            
            action.setParams({
                leadId: leadId
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:getLeadInsights',retVal);
                    component.set('v.insights', retVal);
                    resolve();
                } else {
                    let err = res.getError();
                    console.log('ERROR:getLeadInsights', res.getError());
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    createModelFactorInsights: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve, reject){
            let modelFactors = component.get('v.modelFactors');
            let insights = component.get('v.insights');
            let modelFactorsMap = new Map();
            let modelFactorInsights = [];
            
            try{
                modelFactors.map(function(modelFactor){
                    modelFactorsMap.set(modelFactor.ExternalId, modelFactor);
                })
                
                insights.map(function(insight){
                    if(modelFactorsMap.has(insight.ModelFactor)){
                        modelFactorInsights.push({ 
                            modelFactor: modelFactorsMap.get(insight.ModelFactor),
                            insight: insight
                        })
                    }
                })
                console.log('v.modelFactorInsights',modelFactorInsights)
                component.set('v.modelFactorInsights', modelFactorInsights)
                
                resolve();
            } catch(err){
                reject(err);
            }
        }))
    },
    generateUUID: function(){
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        })
    },
    deleteModelFactors: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.deleteModelFactors');
            let modelFactors = component.get('v.modelFactors');
            
            console.log('v.modelFactors',modelFactors)
            
            action.setParams({
                modelFactors: modelFactors
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:DeleteModelFactors', retVal);
                    resolve()
                } else if(state === 'INCOMPLETE'){
                    reject()
                } else {
                    let err = res.getError();
                    console.log('ERROR:DeleteModelFactors', err);
                    reject(err)
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    deleteLeadInsights: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.deleteLeadInsights');
            let leadInsights = component.get('v.insights');
            
            console.log('v.leadInsights',leadInsights)
            
            action.setParams({
                leadInsights: leadInsights
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:DeleteLeadInsight', retVal);
                    resolve()
                } else if(state === 'INCOMPLETE'){
                    reject()
                } else {
                    let err = res.getError();
                    console.log('ERROR:DeleteLeadInsight', err);
                    reject(err)
                }
            })
            $A.enqueueAction(action);
        }))
    },
    upsertScoreIntelligence: function(component, callback){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.upsertScoreIntelligence');
            let scoreIntelligence = component.get('v.scoreIntelligence');
            
            action.setParams({
                scoreIntelligence: scoreIntelligence
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:UpsertScoreIntelligence',retVal);
                    resolve()
                } else if(state === 'INCOMPLETE'){
                    reject()
                } else {
                    let err = res.getError();
                    console.log('ERROR:UpsertScoreIntelligence', err);
                    reject(err)
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    setModelFactorsAndLeads: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
                let modelFactorInsights = component.get('v.modelFactorInsights')
                let recordId = component.get('v.recordId')
                let modelFactors = []
                let insights = []
                
                modelFactorInsights.map(function(modelFactorInsight){
                    let uuid = self.generateUUID()
                    modelFactors.push(Object.assign(modelFactorInsight.modelFactor,{
                        ExternalId: uuid
                    }))
                    insights.push(Object.assign(modelFactorInsight.insight, {
                        ModelFactor:uuid,
                        ExternalId:uuid+'_'+recordId
                    }));
                })
                
                component.set('v.modelFactors', modelFactors);
                component.set('v.insights',insights);
                
                if(self.VERBOSE) console.log('SUCCESS:setModelFactorsAndLeads');
                resolve();
            } catch(err) {
                console.log('ERROR:setModelFactorsAndLeads', err);
                reject(err);
            }
        }));
    },
    upsertModelFactors: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.upsertModelFactors');
            let modelFactors = component.get('v.modelFactors');
            console.log(JSON.stringify(modelFactors));
            action.setParams({
                modelFactors: modelFactors
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:UpsertModelFactors',retVal);
                    resolve()
                } else if(state === 'INCOMPLETE'){
                    reject()
                } else {
                    let err = res.getError();
                    console.log('ERROR:UpsertModelFactors',err)
                    reject(err)
                }
            })
            
            $A.enqueueAction(action);
        }))
    },
    upsertLeadInsights: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            let action = component.get('c.upsertLeadInsight');
            let leadInsights = component.get('v.insights');
            let scoreIntelligence = component.get('v.scoreIntelligence');
            
            leadInsights.map(function(leadInsight){
                leadInsight['LastModifiedTimeOnRecord'] = scoreIntelligence.LastModifiedTimeOnRecord
            })
            
            action.setParams({
                leadInsights: leadInsights
            })
            
            action.setCallback(this, function(res){
                let retVal = res.getReturnValue();
                let state = res.getState();
                
                if(state === 'SUCCESS'){
                    if(self.VERBOSE) console.log('SUCCESS:UpsertLeadInsight', retVal);
                    
                    self.sendMixpanelEvent(
                        component,
                        $A.getCallback(function(){
                            $A.get('e.force:refreshView').fire();
                            $A.get("e.force:closeQuickAction").fire();
                        })
                    )
                    
                    resolve();
                } else if(state === 'INCOMPLETE'){
                    reject()
                } else {
                    let err = res.getError();
                    console.log('ERROR:UpsertLeadInsight', err);
                    reject(err);
                }
            })
            
            $A.enqueueAction(action);
        }))
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
                    console.log(callback)
                    if(typeof callback == 'function') { callback(component, retVal) }
                    if(typeof callback != 'function') { component.set(callback, retVal) }
                }
                
                resolve(retVal)
            })
            
            if(self.VERBOSE) console.log('Firing:' + actionName, params, action);
            
            $A.enqueueAction(action);
        }))
    },
    sendMixpanelEvent: function(component, callback){
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'SDO Event',
            payload: {
                action: 'Score Lead'
            }
        });
        
        mixpanelEvent.fire();
        
        if(callback){
            callback();
        }
    }
})