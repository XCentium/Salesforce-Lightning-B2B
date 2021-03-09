({
    handleSelect : function(component, event, helper) {
        let selected = event.getParam("value");
        let recordId = component.get('v.recordId');
        let insight = component.get('v.insight');
        
        switch(selected){
            case 'edit':
                component
                .getEvent('renderPanel')
                .setParams({
                    type : 'c:Insights_EditAccountInsight',
                    attributes : {
                        insight: insight,
                        recordId: recordId
                    }
                })
                .fire();
                
                break;
            case 'assign':
                component
                .getEvent('renderPanel')
                .setParams({
                    type : 'c:Insights_AssignInsight',
                    attributes : {
                        insightId: insight.Id,
                        insightType: 'Account_Insight',
                        insightTitle: insight.Title,
                        recordId: recordId
                    }
                })
                .fire();
                
                break;
            case 'edit_articles':
                component
                .getEvent('renderPanel')
                .setParams({
                    type: 'c:Insights_AccountInsightNewsArticles',
                    attributes : {
                        insight: insight,
                        recordId: recordId
                    }
                })
                .fire();
                break;
            case 'delete':
                helper
                .sendRequest(component, 'c.deleteRecord', {
                    sobjectName: 'AccountInsight',
                    recordId: insight.Id
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