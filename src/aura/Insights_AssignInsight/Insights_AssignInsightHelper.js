({
    VERBOSE: true,
    defaultPredictionDefinitionsMap: {
        Account_Insight: {
            "DeveloperName": "Account_Insight",
            "Language": "en_US",
            "MasterLabel": "Account_Insight",
            "Mode": "Manual",
            "SobjectType": "Account",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        Contact_Suggestion_Insight: {
            "DeveloperName": "Contact_Suggestion_Insight",
            "Language": "en_US",
            "MasterLabel": "Contact_Suggestion_Insight",
            "Mode": "Manual",
            "SobjectType": "Account",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        OCR_Suggestion_Insight: {
            "DeveloperName": "OCR_Suggestion_Insight",
            "Language": "en_US",
            "MasterLabel": "OCR_Suggestion_Insight",
            "Mode": "Manual",
            "SobjectType": "Opportunity",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        Opportunity_Insight: {
            "DeveloperName": "Opportunity_Insight",
            "Language": "en_US",
            "MasterLabel": "Opportunity_Insight",
            "Mode": "Manual",
            "SobjectType": "Opportunity",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        Opportunity_Insight: {
            "DeveloperName": "Campaign_Insight",
            "Language": "en_US",
            "MasterLabel": "Campaign_Insight",
            "Mode": "Manual",
            "SobjectType": "Campaign",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        }
    },
    defaultPredictionDefinitions: [
        {
            "DeveloperName": "Account_Insight",
            "Language": "en_US",
            "MasterLabel": "Account_Insight",
            "Mode": "Manual",
            "SobjectType": "Account",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        {
            "DeveloperName": "Contact_Suggestion_Insight",
            "Language": "en_US",
            "MasterLabel": "Contact_Suggestion_Insight",
            "Mode": "Manual",
            "SobjectType": "Account",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        {
            "DeveloperName": "OCR_Suggestion_Insight",
            "Language": "en_US",
            "MasterLabel": "OCR_Suggestion_Insight",
            "Mode": "Manual",
            "SobjectType": "Opportunity",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        },
        {
            "DeveloperName": "Opportunity_Insight",
            "Language": "en_US",
            "MasterLabel": "Opportunity_Insight",
            "Mode": "Manual",
            "SobjectType": "Opportunity",
            "SortOrder": 0,
            "Status": "Inactive",
            "Type": "Action"
        }
    ],
    addListener : function(component){
        let self = this;
        
        var listenerHandler = function(event){
            if(event.origin != window.location.origin){
                let session = event.data;
                let insightType = component.get('v.insightType')
                
                component.set('v.session', session)
                
                self.sendRequest(component, 'c.getPredictionDefinitions', {})
                .then(function(predictionDefinitions){
                    let predictionDefinitionsMap = {}
                    
                    predictionDefinitions.map(function(predictionDefinition){
                        predictionDefinitionsMap[predictionDefinition.DeveloperName] = predictionDefinition 
                    })
                    
                    if(!predictionDefinitionsMap.hasOwnProperty(insightType)){
                        let defaultPredictionDefinitionsMap = self.defaultPredictionDefinitionsMap
                        
                        return self.sendRequest(component, 'c.httpRequest', {
                            auth: session.session,
                            endpoint: '/services/data/v43.0/sobjects/PredictionDefinition',
                            method: 'POST',
                            data: JSON.stringify(defaultPredictionDefinitionsMap[insightType])
                        })
                    } else {
                        component.set('v.predictionDefinitionsMap', predictionDefinitionsMap)
                        return true
                    }
                })
                .then(function(res){
                    if(res != true){
                        return self.sendRequest(component, 'c.getPredictionDefinitions', {}, function(component, predictionDefinitions){
                            let predictionDefinitionsMap = {}
                            predictionDefinitions.map(function(predictionDefinition){
                                predictionDefinitionsMap[predictionDefinition.DeveloperName] = predictionDefinition 
                            })
                            console.log(JSON.stringify(predictionDefinitionsMap))
                            component.set('v.predictionDefinitionsMap', predictionDefinitionsMap)
                        })
                    } else {
                        return true
                    }
                })
                .then(function(){
                    return self.sendRequest(component, 'c.getInternalUsers', {}, function(component, users){
                        let usersMap = {}
                        users.map(function(user){
                            usersMap[user.Id] = user.Name
                        })
                        component.set('v.usersMap',usersMap)
                    })
                })
                .then(function(){
                    return self.getRecordRecommendations(component)
                })
                .then(function(){
                    return self.toggleLoading(component)
                })
                .catch(function(err){
                    console.log('ERROR', err)
                })
            }
            window.removeEventListener('message', listenerHandler);
        }
        window.addEventListener('message', listenerHandler, false);
    },
    getRecordRecommendations : function(component){
        let self = this
        let session = component.get('v.session')
        let querySelect = ['SELECT AcceptCount,ExternalDataSourceId,ExternalId,Id,InsightId,OwnerId',
                           'RecommendationDefinitionId,RecommendationScore,RecommendationStatus',
                           'RecommendationType,ReferenceDate,TargetId,TargetSobjectType'
                          ]
        let queryObject = ' FROM RecordRecommendation'
        let queryFilter = ' WHERE InsightId = \'' + component.get('v.insightId') + '\' AND TargetId = \'' + component.get('v.recordId') + '\''
        
        let query = querySelect.join(',') + queryObject + queryFilter
        query = query.replace(/\s/g, '+')
        
        return this.sendRequest(component, 'c.httpQuery', {
            auth: session.session,
            endpoint: '/services/data/v43.0/query/?q=' + query,
            method: 'GET'
        }, function(component, res){
            let assignments = JSON.parse(res) ? JSON.parse(res).records : []
            let usersMap = component.get('v.usersMap')
            
            assignments.map(function(assignment){
                assignment['OwnerName'] = usersMap[assignment.OwnerId]
            })
            
            component.set('v.assignments', assignments)
        })
    },
    toggleLoading: function(component){
        return new Promise(
            $A.getCallback(function(resolve,reject){
                try{
                    let isLoading = component.get('v.isLoading');
                    component.set('v.isLoading', !isLoading);
                } catch(err){
                    reject(err)
                }
            })
        )
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
        
        if(self.VERBOSE) console.log(JSON.stringify(actionName), JSON.stringify(params))
        
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
                
                if(callback != null && callback != '') {
                    if(typeof callback == 'function') { callback(component, retVal) }
                    if(typeof callback != 'function') { component.set(callback, retVal) }
                }
                
                resolve(retVal)
            })
            
            $A.enqueueAction(action);
        }))
    }
})