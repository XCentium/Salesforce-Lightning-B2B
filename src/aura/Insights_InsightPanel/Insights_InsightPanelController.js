({
    doInit : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        let renderedComponent;
        
        if( recordId.substring(0,3) == '001'){
            renderedComponent = 'c:Insights_AccountInsights'
        } else if( recordId.substring(0,3) == '006'){
            renderedComponent = 'c:Insights_OpportunityInsights'
        } else if( recordId.substring(0,3) == '701') {
            renderedComponent = 'c:Insights_CampaignInsights'
        }
        
        console.log(recordId, renderedComponent)
        
        helper.renderPanel(component, {
            type: renderedComponent,
            attributes: {
                recordId: component.get('v.recordId')
            }
        });
    },
    renderPanel: function(component, event, helper) {
        var params = event.getParams();
        helper.renderPanel(component, params);
    },
})