({
    handleSelect : function(component, event, helper) {
        let selected = event.getParam("value");
        let recordId = component.get('v.recordId');
        let rationale = component.get('v.rationale');
        let campaignInsightId = component.get('v.campaignInsightId');
        
        switch(selected){
            case 'edit':
                component.getEvent('renderPanel')
                .setParams({
                    type : 'c:Insights_EditCampaignRationale',
                    attributes : {
                        insight: rationale,
                        campaignInsightId: campaignInsightId,
                        recordId: recordId
                    }
                })
                .fire();
                
                break;
            case 'delete':
                helper
                .sendRequest(component, 'c.deleteRecord', { 
                    sobjectName: 'CampaignInsightRationale',
                    recordId: rationale.Id
                })
                .then(function(){
                    helper.showToast(component, {
                        message: 'Insight Successfully Deleted',
                        type: 'success'
                    });
                })
                .then(function(){
                    component.destroy()
                })
                
                break;
            default:
                return false;
                break;
        }
    },
    handleValueChange: function(component, event){
        component.set('v.disableSave', false)
    },
})