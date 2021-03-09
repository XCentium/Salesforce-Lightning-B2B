({
    doInit : function(component, event, helper) {
        let promises = [
            helper.getInsights(component)
        ]
        Promise.all(promises);
    },
    newInsight : function(component){
        let recordId = component.get('v.recordId');
        component.getEvent('renderPanel').setParams({
            type : 'c:Insights_EditCampaignInsight',
            attributes : {
                recordId: recordId
            }
        }).fire();
    }
})