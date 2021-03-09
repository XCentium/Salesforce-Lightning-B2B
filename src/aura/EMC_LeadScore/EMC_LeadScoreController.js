({
    onInit : function(component, event, helper) {
        
        window.addEventListener('message', function(event){
            if(event.origin != window.location.origin && event.data.type == 'sessionId'){
                console.log(event.data.session)
                let session = event.data.session;
                component.set('v.sessionId', session)
                
                helper.toggleLoading(component, true)
                .then(function(){
                    let promises = [
                        helper.getLeadFields(component),
                        helper.getLeadData(component),
                        helper.getScoreIntelligence(component)
                    ]
                    return Promise.all(promises)
                })
                .then(function(){
                    return helper.getLeadIQConfiguration(component);
                })
                .then(function(res){
                    return helper.getModelFactors(component,res.ModelVersion)
                })
                .then(function(){
                    return helper.getLeadInsights(component)
                })
                .then(function(res){
                    return helper.createModelFactorInsights(component);
                })
                .then(function(){
                    return helper.toggleLoading(component, false)
                })
                .catch(function(err){
                    console.log('ERROR:Init', err);
                })
            }
        })
    },
    addInsight : function(component, event, helper){
        let baseId = component.get('v.recordId');
        let lead = component.get('v.lead');
        let scoreIntelligence = component.get('v.scoreIntelligence');
        let leadIQConfig = component.get('v.leadIQConfig');
        let modelFactorInsights = component.get('v.modelFactorInsights');
        
        let uuid = helper.generateUUID();
        
        /*if(!scoreIntelligence.Id){
            scoreIntelligence = {
                BaseId: lead.Id,
                LastModifiedTimeOnRecord: new Date().toISOString(),
                Score: 100
            }
        }*/
        
        let modelFactor = {
            sobjectType : 'ModelFactor',
            ScoreCorrelation: 0.5,
            ConversionCorrelation: 0.5,
            Factor1: 'Lead.Title',
            Factor2: '',
            SourceField1: 'Lead.Title',
            SourceField2: '',
            ExternalId: uuid,
            Type: 'IS_EQUAL',
            Value: 'ModelFactorValue',
            Version: leadIQConfig.ModelVersion
        }
        
        let insight = {
            sobjectType : 'LeadInsight',
            Intensity: 1,
            IntensityLevel: "HIGH_POS",
            ExtractionTime: new Date().toISOString(),
            ModelFactor: uuid,
            ParentId: baseId,
            ExternalId: uuid+'_'+baseId,
            Value: ''
        }
        
        let modelFactorInsight = {
            modelFactor: modelFactor,
            insight: insight
        }
        
        modelFactorInsights.push(modelFactorInsight);
        
        component.set('v.scoreIntelligence', scoreIntelligence);
        component.set('v.modelFactorInsights', modelFactorInsights);
    },
    deleteIndex: function(component, event, helper){
        let index = event.getParam('index');
        let leadInsight = event.getParam('payload');
        
        let modelFactorInsights = component.get('v.modelFactorInsights');
        let modelFactorInsight = modelFactorInsights[index];
        
        let deletedModelFactors = component.get('v.deletedModelFactors');
        let deletedInsights = component.get('v.deletedInsights');

        if(modelFactorInsight.insight.hasOwnProperty('Id')) deletedInsights.push(modelFactorInsight.insight);
        if(modelFactorInsight.modelFactor.hasOwnProperty('Id')) deletedModelFactors.push(modelFactorInsight.modelFactor);
        modelFactorInsights.splice(index, 1);
        
        component.set('v.deletedModelFactors', deletedModelFactors);
        component.set('v.deletedInsights', deletedInsights);
        component.set('v.modelFactorInsights', modelFactorInsights);
    },
    save: function(component, event, helper){
        component.set('v.saving', true);
        let scoreIntelligence = component.get('v.scoreIntelligence')
        let lead = component.get('v.lead')
        scoreIntelligence['LastModifiedTimeOnRecord'] = lead.LastModifiedDate
        
        let recordId = component.get('v.recordId')
        let sessionId = component.get('v.sessionId')
        
        let close = $A.get('e.force:closeQuickAction');
        let refresh = $A.get('e.force:refreshView');
        
        helper.sendRequest(component,'c.httpRequest',{
            auth: sessionId,
            endpoint: '/services/data/v43.0/sobjects/ScoreIntelligence',
            method: 'POST',
            data: JSON.stringify(scoreIntelligence)
        })
        .then(function(){
            /*let promises = [
                helper.deleteModelFactors(component),
                helper.deleteLeadInsights(component)
            ]
            
            return Promise.all(promises)*/
            
            return helper.deleteLeadInsights(component)
        })
        .then(function(){
            return helper.setModelFactorsAndLeads(component)
        })
        .then(function(){
            let records = []
            let leadInsights = component.get('v.insights')
            let modelFactors = component.get('v.modelFactors')
            
            records = leadInsights
            records = records.concat(modelFactors)
            
            let promises = []
            
            console.log(records)
            
            records.map(function(record){
                let sobjectType = record['sobjectType']
                
                if(sobjectType){
                    delete record['sobjectType']
                } else if(record.hasOwnProperty('Id')) {
                    sobjectType = record['Id'].startsWith('0O3') ? 'ModelFactor' : 'LeadInsight'
                    delete record['Id']
                }
                
                if(sobjectType == 'LeadInsight'){
                    record['LastModifiedTimeOnRecord'] = lead.LastModifiedDate
                }
                
                promises.push(helper.sendRequest(component, 'c.httpRequest', {
                    auth: sessionId,
                    endpoint: '/services/data/v43.0/sobjects/'+sobjectType,
                    method:'POST',
                    data: JSON.stringify(record)
                }))
                
            })
            
            return Promise.all(promises)
        })
        .then(function(){
            helper.sendMixpanelEvent(component)
        })
        .finally(function(){
            refresh.fire();
            close.fire();
        })
        .catch($A.getCallback(function(err){
            console.log('ERROR:save',err);
            component.set('v.saving', false);
        }))
    }
})