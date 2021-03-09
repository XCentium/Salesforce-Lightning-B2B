({
    doInit : function(component, event, helper){
        let recordId = component.get('v.recordId')
        let insight = component.get('v.insight')
        
        let promises = [
            helper.getTypes(component), 
            helper.getTrendTypes(component),
            helper.getReasons(component)
        ];
        
        Promise.all(promises)
        .then(function(){
            let insightTrend = component.find('insightType')
            let insightTrendType = component.find('insightTrendType')
            let insightReason = component.find('insightReason')
            
            if(insightTrend && insight.Type) insightTrend.set('v.value', insight.Type)
            if(insightTrendType && insight.TrendType) insightTrendType.set('v.value', insight.TrendType)
            if(insightReason && insight.Reason) insightReason.set('v.value', insight.Reason)
            
            if(helper.VERBOSE) console.log(JSON.stringify(component.get('v.insight',null,2)))
        })
        .then(function(){
            if(!insight.hasOwnProperty('Id')){
                let trendTypeOptions = component.get('v.trendTypeOptions')
                let typeOptions = component.get('v.typeOptions')
                
                component.set('v.insight',{
                    Score: 1,
                    OpportunityId: recordId,
                    TrendType: trendTypeOptions[0].value, 
                    Type: typeOptions[0].value
                });
            }
        })
    },
    handleValueChange: function(component, event, helper){
        helper.hasRequiredFields(component)
        .then(function(isValid){
            if(isValid) {
                component.set('v.disableSave', false)
            } else {
                component.set('v.disableSave', true)
            }
        })
    },
    handleSave: function(component, event, helper){
        let record = component.get('v.insight');
        //Update or insert for Database methods of for non defined SObject types
        let action = 'c.upsertRecords';
        
        if(helper.VERBOSE) console.log(JSON.stringify(record,null,2));
        
        helper.sendRequest(component, action, {
            sobjectName: 'OpportunityInsight',
            recordsJSON: JSON.stringify([record])
        })
        .then(function(){
            helper.showToast(component, {
                message: record.hasOwnProperty('Id') ? 'Insight Record Updated!' : 'Insight Record Created',
                type:'success'
            })
        })
        .then(function(){
            helper.goToState(component, {
                type : 'c:Insights_OpportunityInsights',
                attributes : {
                    recordId: component.get('v.recordId')
                }
            })
        })
    },
    goBack : function(component, event, helper) {
        helper.goToState(component, {
            type : 'c:Insights_OpportunityInsights',
            attributes : {
                recordId: component.get('v.recordId')
            }
        })
	},
})