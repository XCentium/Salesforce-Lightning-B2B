({
    VERBOSE: true,
    insightEnums:{
        IMPLISIT_ADC_NEW_CONTACT: {
            label: 'Automated Contact',
            customTitle:'label',
            rationale: 'label',
            display: {
                label: 'Email',
                path:'records.0.record.payload.Email'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Suggestion',
                CustomTitle: '{"formatter":"label","formatString":"Insight.NewContactFound","parameters":[]}',
                Rationale: '{"formatter":"label","formatString":"Insight.ContactSuggestionRationale ","parameters":[]}',
                SupportingData: '{"records":[{"record":{"payload":{"AccountId":"","Email":"","FirstName":"","LastName":""}}}]}'
            },
            dataPath: 'records.0.record.payload',
            supportingData: {
                fields: [
                    {
                        label: 'Account',
                        field: 'AccountId',
                        type: 'parent',
                        parentType: 'Account',
                        lookupField: 'Name'
                    },
                    {
                        label: 'First Name',
                        field: 'FirstName',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Last Name',
                        field: 'LastName',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Email',
                        field: 'Email',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_COMPETITION_MENTIONED: {
            label: 'Competition Mentioned',
            display: {
                label: 'Name',
                path: 'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Suggestion',
                CustomTitle: '{"formatter":"custom","formatString":"Competition was mentioned","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Recent activity mentions competitors","parameters":[]}',
                SupportingData: '{"activityId":null}'
            },
            dataPath: '',
            supportingData: {
                fields: [
                    {
                        label: 'Subject',
                        field: 'activitySubject',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Activity',
                        field: 'activityId',
                        type: 'lookup',
                        parentType: 'Task',
                        lookupField: 'Subject'
                    },
                    {
                        label: 'Content',
                        field: 'activitySnippetOverride',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_STAKEHOLDER_LEFT: {
            label: 'Contact is leaving',
            display: {
                label: 'Name',
                path: 'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Contact is leaving","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"A recent email indicates that a contact is leaving","parameters":[]}',
                SupportingData: '{"records":[{"record":{"payload":{"AccountId":"","Email":"","FirstName":"","LastName":""}}}]}'
            },
            dataPath: '',
            supportingData: {
                fields: [
                    {
                        label: 'Subject',
                        field: 'activitySubject',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Activity',
                        field: 'activityId',
                        type: 'lookup',
                        parentType: 'Task',
                        lookupField: 'Subject'
                    },
                    {
                        label: 'Content',
                        field: 'activitySnippetOverride',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_NEWS_DOWNSIZING: {
            label: 'Competition Mentioned',
            display: {
                label: 'Article',
                path: 'news.0.article.title'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"Company is cutting costs","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Recent activity mentions competitors","parameters":[]}',
                SupportingData: '{"records":[{"record":{"payload":{"AccountId":"","Email":"","FirstName":"","LastName":""}}}]}'
            },
            dataPath: 'news.0.article',
            supportingData: {
                fields: [
                    {
                        label: 'Title',
                        field: 'title',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Date/Time',
                        field: 'dateTime',
                        type: 'time',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'URL',
                        field: 'url',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Displayed URL',
                        field: 'displayName',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_NEWS_EXECUTIVE_CHANGE: {
            label: 'Leadership changes',
            display: {
                label: 'Article',
                path: 'news.0.article.title'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Leadership changes","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Here are articles about changes to leadership.","parameters":[]}',
                SupportingData: '{"records":[{"record":{"payload":{"AccountId":"","Email":"","FirstName":"","LastName":""},"descriptor":{"id":null,"type":"Contact"}}}]}'
            },
            dataPath: 'news.0.article',
            supportingData: {
                fields: [
                    {
                        label: 'Title',
                        field: 'title',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Date/Time',
                        field: 'dateTime',
                        type: 'time',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'URL',
                        field: 'url',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Displayed URL',
                        field: 'displayName',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_NEWS_EXPANDING : {
            label: 'Company is expanding',
            display: {
                label: 'Article',
                path: 'news.0.article.title'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Positive',
                CustomTitle: '{"formatter":"custom","formatString":"Company is expanding","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Here are articles about expansions.","parameters":[]}',
                SupportingData: ''
            },
            dataPath: 'news.0.article',
            supportingData: {
                fields: [
                    {
                        label: 'Title',
                        field: 'title',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Date/Time',
                        field: 'dateTime',
                        type: 'time',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'URL',
                        field: 'url',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Displayed URL',
                        field: 'displayName',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        },
        IMPLISIT_ACC_NEWS_MA_ACTIVITY : {
            label: 'M&A activity detected',
            display: {
                label: 'Article',
                path: 'news.0.article.title'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"M&A activity detected","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Here are articles about mergers and acquisitions.","parameters":[]}',
                SupportingData: ''
            },
            dataPath: 'news.0.article',
            supportingData: {
                fields: [
                    {
                        label: 'Title',
                        field: 'title',
                        type: 'string',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Date/Time',
                        field: 'dateTime',
                        type: 'time',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'URL',
                        field: 'url',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    },
                    {
                        label: 'Displayed URL',
                        field: 'displayName',
                        type: 'string',
                        parent: 'sourceInfo',
                        parentType: null,
                        lookupField: null
                    }
                ]
            }
        }
    },
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
                
                if(state !== 'SUCCESS') {
                    console.log('ERROR:'+apexAction, error);
                    reject(error);
                }
                if(assignedVariable && assignedVariable != ''){
                    if(self.VERBOSE) console.log(assignedVariable, response);
                    component.set(assignedVariable, response);
                }
                
                resolve(response);
            })
            
            $A.enqueueAction(action);
        }))
    },
    setInsights: function(component, insights){
        let self = this;
        return new Promise(function(resolve,reject){
            if(self.VERBOSE) console.log('insights', insights);
            try{
                insights.map(function(insight){
                    let insightEnum = self.insightEnums[insight.InsightType.DeveloperName];
                    let path = insightEnum.display.path.split('.');
                    let supportingData = JSON.parse(insight.SupportingData);
                    
                    insight['label'] = insightEnum.display.label;
                    insight['displayed'] = path.reduce(function(currentPath, nextPath){
                        return currentPath[nextPath];
                    }, supportingData)
                })
                
                component.set('v.insights', insights);
                resolve(insights);
            } catch(err){
                reject(err);
            }
        })
    },
    setViewState: function(component, viewStateParams){
        let self = this;
        
        return new Promise($A.getCallback(function(resolve,reject){
            try {
                let viewState = component.get('v.viewState');
                let oldViewStates = component.get('v.oldViewStates');
                
                //Initialize empty array as lightning creates an array with a null value [null]
                if(!oldViewStates[0]) oldViewStates = [];
                
                let oldViewState = Object.assign({}, oldViewStates.length > 0 ? oldViewStates[oldViewStates.length-1] : {});
                
                oldViewStates.push(viewState);
                
                let newViewState = Object.assign(oldViewState, viewStateParams);
                
                component.set('v.viewState', newViewState);
                component.set('v.oldViewStates', oldViewStates);
                
                resolve();
            } catch(err){
                reject(err);
            }
        }))
    },
    setActiveInsight : function(component, selectedInsightType) {
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
                let viewState = component.get('v.viewState');
                let insightEnum = self.insightEnums[selectedInsightType];
                let insightTypes = component.get('v.insightTypesMap');
                
                let activeInsight = Object.assign({}, insightEnum);
                
                activeInsight['InsightType'] = {};
                activeInsight['InsightType']['DeveloperName'] = selectedInsightType;
                
                if(self.VERBOSE) console.log('activeInsightClone', activeInsight);
                
                component.set('v.activeInsight', activeInsight);
                resolve(activeInsight);
            } catch(e){
                reject(e);
            }
        }))
    },
})