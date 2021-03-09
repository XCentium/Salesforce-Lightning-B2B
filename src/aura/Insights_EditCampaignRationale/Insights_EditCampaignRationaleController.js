({
    doInit : function(component, event, helper){
        let recordId = component.get('v.recordId')
        let insight = component.get('v.insight')
        let campaignInsightId = component.get('v.campaignInsightId')
        
        let promises = [
            helper.getTypes(component)
            //helper.getTrendTypes(component)
        ];
        
        Promise.all(promises)
        .then(function(){
            let insightTrend = component.find('insightType')
            let insightTrendType = component.find('insightTrendType')
            
            if(helper.VERBOSE) console.log(JSON.stringify(component.get('v.insight',null,2)))
                })
        .then(function(){
            if(!insight.hasOwnProperty('Id')){
                let trendTypeOptions = component.get('v.trendTypeOptions')
                let typeOptions = component.get('v.typeOptions')
                
                component.set('v.insight',{
                    AvgEngagementRate : 5,
                    EngagementRate : 5,
                    NumberOfDays  : 5,
                    CampaignInsightId: campaignInsightId,
                    InsightType: typeOptions[0].value
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
            sobjectName: 'CampaignInsightRationale',
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
                type : 'c:Insights_CampaignRationales',
                attributes : {
                    recordId: component.get('v.recordId'),
                    campaignInsightId: component.get('v.campaignInsightId')
                }
            })
        })
    },
    goBack : function(component, event, helper) {
        helper.goToState(component, {
            type : 'c:Insights_CampaignRationales',
            attributes : {
                recordId: component.get('v.recordId'),
                campaignInsightId: component.get('v.campaignInsightId')
            }
        })
    }
})