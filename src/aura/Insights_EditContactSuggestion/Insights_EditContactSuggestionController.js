({
    doInit: function(component) {
        let contactSuggestion = component.get('v.contactSuggestion')
        contactSuggestion['AccountId'] = component.get('v.recordId')
        component.set('v.contactSuggestion', contactSuggestion)
    },
    handleGoBack: function(component, event, helper) {
        helper.goToState(component, {
            type : 'c:Insights_AccountInsights',
            attributes : {
                recordId: component.get('v.recordId')
            }
        });
    },
    handleValueChange: function(component, event){
        component.set('v.disableSave', false)
    },
    handleSave: function(component, event, helper){
        let record = component.get('v.contactSuggestion');
        //Update or insert for Database methods of for non defined SObject types
        let action = 'c.upsertRecords';
        
        if(helper.VERBOSE) console.log(JSON.stringify(record,null,2));
        
        helper.sendRequest(component, action, {
            sobjectName: 'ContactSuggestionInsight',
            recordsJSON: JSON.stringify([record])
        })
        .then(function(){
            helper.showToast(component, {
                message: record.hasOwnProperty('Id') ? 'Contact Suggestion Updated' :  'Contact Suggestion Created',
                type:'success'
            })
        })
        .then(function(){
            helper.goToState(component, {
                type : 'c:Insights_AccountInsights',
                attributes : {
                    recordId: component.get('v.recordId')
                }
            })
        })
    }
})