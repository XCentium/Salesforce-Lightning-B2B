({
    VERBOSE: false,
    insightEnums:{
        IMPLISIT_COMPETITION_MENTIONED : {
            label: 'Competition Mentioned',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Competition was mentioned","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Recent activity mentions competitors","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_ACTIVE_AGAIN : {
            label: 'Competition Mentioned',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Positive',
                CustomTitle: '{"formatter":"custom","formatString":"Re-engaged opportunity","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"There\'s new activity on this inactive opportunity.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_WONT_CLOSE_ON_TIME : {
            label: 'Opportunity Won\'t Close on Time',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"Opportunity is unlikely to close in time","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Recent email sentiment suggests this deal won\'t be won by the Closed Date","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_STAKEHOLDER_LEFT : {
            label: 'Contact is leaving',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Contact is leaving","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"A recent email indicates that a contact is leaving","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_PAST_CLOSE_DATE  : {
            label: 'Past close date',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Past close date","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"A recent email indicates that a contact in this opportunity is leaving","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_PROSPECT_UNRESPONSIVE  : {
            label: 'Prospect has not responded',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"Prospect has not responded","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"We usually hear back within 2 days, but we haven\'t heard back in 7 days.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_NO_FUTURE_ACTIVITY  : {
            label: 'Opportunity has no open activity',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Opportunity has no open activity","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"There isn\'t any open future activity related to this opportunity.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_TRENDING_UP : {
            label: 'Opportunity boosting',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySubject'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Positive',
                CustomTitle: '{"formatter":"custom","formatString":"Opportunity boosting","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Activity suggests that this deal is more likely to be won compared to previously closed deals.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_HIGH_EFFORT_LOW_IMPACT : {
            label: 'Time-consuming opportunity',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySnippetOverride'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Informational',
                CustomTitle: '{"formatter":"custom","formatString":"Time-consuming opportunity","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Extra time is spent on this deal relative to its value compared to opportunities.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_OVERDUE_TASK : {
            label: 'Opportunity has overdue tasks',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySnippetOverride'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"Opportunity has overdue tasks","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Task is past due","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_TRENDING_DOWN : {
            label: 'Opportunity slowing',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySnippetOverride'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"Opportunity slowing","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"Activies suggests that this deal is less likely to be won compared to previously closed deals.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_OPP_NO_COMMUNICATION : {
            label: 'No communication',
            customTitle:'label',
            rationale: 'label',
            dataPath: '',
            display: {
                label: 'Subject',
                path:'activitySnippetOverride'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Negative',
                CustomTitle: '{"formatter":"custom","formatString":"No communication","parameters":[]}',
                Rationale: '{"formatter":"custom","formatString":"There’s usually communication related to opportunities every 14 days. So far, there hasn’t been any in 21 days.","parameters":[]}',
                SupportingData: '{"activityId":"","activitySubject":"","activitySnippetOverride":"",}'
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
        IMPLISIT_ADC_NEW_OPPORTUNITY_CONTACT_ROLE : {
            label: 'Opportunity Contact Role',
            customTitle:'label',
            rationale: 'label',
            dataPath:'records.0.record.payload',
            display: {
                label: 'Email',
                path:'records.0.record.payload.Email'
            },
            insight: {
                Score: 0.5,
                TrendType: 'Suggestion',
                CustomTitle: '{"formatter":"label","formatString":"Insight.NewContactFound","parameters":[]}',
                Rationale: '{"formatter":"label","formatString":"Insight.ContactSuggestionRationale ","parameters":[]}',
                SupportingData: '{"records":[{"record":{"payload":{"AccountId":"","Email":"","FirstName":"","LastName":""},"descriptor":{"id":null,"type":"Contact"}}}]}'
            },
            supportingData: {
                fields: [
                    {
                        label: 'Opportunity',
                        field: 'OpportunityId',
                        type: 'parent',
                        parentType: 'Opportunity'
                    },
                    {
                        label: 'Contact',
                        field: 'ContactId',
                        type: 'lookup',
                        parentType: 'Contact',
                        lookupField: 'Name'
                    },
                    {
                        label: 'Role',
                        field: 'Role',
                        type: 'string',
                        parentType: null
                    },
                    {
                        label: 'First Name',
                        field: 'FirstName',
                        type: 'string',
                        parentType: null
                    },
                    {
                        label: 'Last Name',
                        field: 'LastName',
                        type: 'string',
                        parentType: null
                    },
                    {
                        label: 'Email',
                        field: 'Email',
                        type: 'string',
                        parentType: null
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