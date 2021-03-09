({
    doInit : function(component, event, helper) {
        console.log(component.get('v.recordId'),component.get('v.campaignInsightId'));
        let promises = [
            helper.getInsights(component)
        ]
        Promise.all(promises);
    },
    newInsight : function(component){
        let recordId = component.get('v.recordId');
        let campaignInsightId = component.get('v.campaignInsightId');
        let rationale = {
            CampaignInsightId: campaignInsightId,
            InsightType: 'HighEmailOpenRate',
            AvgEngagementRate: 3,
            EngagementRate : 3,
            NumberOfDays: 3
        }
        component.getEvent('renderPanel').setParams({
            type : 'c:Insights_EditCampaignRationale',
            attributes : {
                insight: rationale,
                campaignInsightId: campaignInsightId,
                recordId: recordId
            }
        }).fire();
    },
    goBack : function(component, event, helper) {
        helper.goToState(component, {
            type : 'c:Insights_CampaignInsights',
            attributes : {
                recordId: component.get('v.recordId')
            }
        })
    }
})