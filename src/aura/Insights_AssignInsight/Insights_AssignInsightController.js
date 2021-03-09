({
    doInit : function(component, event, helper) {
        helper.addListener(component)
    },
    insertAssignment: function(component, event, helper){
        let insightType = component.get('v.insightType')
        let assigneeId = component.get('v.assigneeId')
        let session = component.get('v.session')
        let predictionDefinitionsMap = component.get('v.predictionDefinitionsMap')
        
        console.log(JSON.stringify(predictionDefinitionsMap))
        
        let recordRecommendation = {
            AcceptCount: 0,
            InsightId: component.get('v.insightId'),
            OwnerId: assigneeId,
            RecommendationDefinitionId: predictionDefinitionsMap[insightType].Id,
            RecommendationScore: 1,
            RecommendationStatus: 'New',
            ReferenceDate: (new Date()).toISOString(),
            TargetId: component.get('v.recordId')
        }
        
        if(assigneeId && assigneeId != ''){
            helper.sendRequest(component, 'c.httpRequest', {
                auth: session.session,
                endpoint: '/services/data/v44.0/sobjects/RecordRecommendation',
                method: 'POST',
                data: JSON.stringify(recordRecommendation)
            })
            .then(function(res){
                let response = JSON.parse(res)
                let assignments = component.get('v.assignments')
                let usersMap = component.get('v.usersMap')
                let lookup = component.find('lookup')
                assignments.push(Object.assign(recordRecommendation, { 
                    Id: response.id, 
                    OwnerName: usersMap[assigneeId]
                }))
                component.set('v.assignments',assignments)
                lookup.clear()
            })
        } else {
            alert('You must lookup a user')
        }
    },
    handleGoBack : function(component, event, helper){
        helper.goToState(component, {
            type : 'c:Insights_InsightPanel',
            attributes : {
                recordId: component.get('v.recordId')
            }
        })
    },
})