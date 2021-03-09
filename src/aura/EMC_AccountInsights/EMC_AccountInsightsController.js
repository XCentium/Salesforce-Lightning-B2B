({
    onInit : function(component, event, helper) {
        let didInit = component.get('v.didInit');
        let recordId = component.get('v.recordId');
        
        if(!didInit){
            component.set('v.didInit', true);
            
            helper.setViewState(component, {view:'home'})
            .then(function(viewState){
                return helper.fireAction(component, 'c.getInsightTypes', {
                    parentObject: 'Account'
                }, 'v.insightTypes')
            })
            .then(function(insightTypes){
                let insightTypesMap = {}
                insightTypes.map(function(insightType){
                    insightTypesMap[insightType.DeveloperName] = insightType.Id;
                })
                
                component.set('v.insightTypesMap', insightTypesMap);
                helper.setActiveInsight(component, insightTypes[0].DeveloperName);
                
                return helper.fireAction(component, 'c.getInsights', {
                    parentId: recordId
                });
            })
            .then(function(insights){
                return helper.setInsights(component, insights);
            })
        }
    },
    handleBack : function(component, event, helper){
        let oldViewStates = component.get('v.oldViewStates');
        let previousViewState = Object.assign({}, oldViewStates[oldViewStates.length-1]);
        
        oldViewStates.pop();
        
        component.set('v.oldViewStates', oldViewStates);
        component.set('v.viewState', previousViewState);
    },
    handleFinish : function(component, event, helper){
        helper.setViewState(component, {view: 'home'})
	},
    addInsight : function(component, event, helper){
        helper.setViewState(component, {view: 'new'})
    },
    goToEdit: function(component, event, helper){
        helper.setViewState(component, {view: 'edit'})
    },
    assignInsight : function(component, event, helper){
        let activeInsight = event.getParam('payload');
        console.log(JSON.stringify(activeInsight,null,2));
        component.set('v.activeInsight', activeInsight);
        
        helper.setViewState(component, {view: 'assign'})
    },
    editInsight : function(component, event, helper){
        helper.setActiveInsight(component)
        .then( function(){
            helper.setViewState(component, {view: 'edit'})
        })
    },
    insightTypeChangeHandler : function(component, event, helper){
        let selectedInsightType = component.find("selectedInsightType").get("v.value");
        helper.setActiveInsight(component, selectedInsightType);
    },
    loadInsight: function(component, event, helper){
        let existingInsight = event.getParam('payload');
        let insightTypesEnum = helper.insightEnums;
        let insightType = existingInsight.InsightType.DeveloperName;
        let dataPath = insightTypesEnum[insightType].dataPath.split('.');
        let existingInsightSupportData = JSON.parse(existingInsight.SupportingData);
		let supportingData = insightTypesEnum[insightType].supportingData;
        let existingInsightSupportDataValues;
        
        console.log(dataPath.length);
        
        if(dataPath.length == 1) {
            existingInsightSupportDataValues = existingInsightSupportData
        } else {
            existingInsightSupportDataValues = dataPath.reduce(function(currentPath, nextPath){
                return currentPath[nextPath];
            }, existingInsightSupportData)
        }
        
        if(helper.VERBOSE) console.log('existingInsightSupportData',existingInsightSupportData,supportingData)
        
        supportingData.fields.map(function(field, index){
            console.log('supportingDataMap',supportingData, field, index);
            let fieldName = field['field'];
            console.log('existingInsightSupportDataValues', existingInsightSupportDataValues);
            supportingData.fields[index]['value'] = existingInsightSupportDataValues[fieldName];
        })
        
        console.log(JSON.stringify(supportingData,null,2));
        
        existingInsight['supportingData'] = supportingData;
        
        if(helper.VERBOSE) console.log('existingInsightSupportDataValues', JSON.stringify(existingInsight,null,2));
        
        component.set('v.activeInsight', existingInsight);
        
        helper.setViewState(component, {view: 'edit', selectedInsightType: existingInsight.InsightType.DeveloperName})
    },
    saveInsight: function(component, event, helper){
        let recordId = component.get('v.recordId');
        
        let activeInsight = component.get('v.activeInsight');
        
        let insightTypesEnum = helper.insightEnums;
        let insightTypes = component.get('v.insightTypesMap');
        let insightType = activeInsight.InsightType.DeveloperName;
        
        let dataPath = insightTypesEnum[insightType].dataPath.split('.');
        
        let supportingDataFields = activeInsight.supportingData;
        
        let insight = Object.assign({}, activeInsight.insight);
        let insightSupportingObjectData = {};
        
        if(supportingDataFields.hasOwnProperty('fields')){
            supportingDataFields.fields.map(function(field){
                let fieldName = field['field'];
                if(field['type'] == 'parent'){
                    insightSupportingObjectData[fieldName] = recordId;
                    return true;
                }
                
                if(field['type'] == 'time'){
                    insightSupportingObjectData[fieldName] = new Date(field.value).getTime();
                    return true;
                }
                
                if(field.parent){
                    if(!insightSupportingObjectData[field.parent]) insightSupportingObjectData[field.parent] = {};
                    insightSupportingObjectData[field.parent][field.field] = field.value;
                }
                
                insightSupportingObjectData[fieldName] = field['value'] ? field['value'] : null;
            })
        }
        
        console.log('insightSupportingObjectData',insightSupportingObjectData);
        
        //reverse keys to build object tree records.0.record.payload => records:{[record:{ payload:{}}]}
        dataPath.reverse();
        
        let isArray = false;
        let insightSupportingData;
            
        if(dataPath.length == 1) {
            insightSupportingData = insightSupportingObjectData;
        } else {
            insightSupportingData = dataPath.reduce(function(supportingDataObject, newProperty){
                let property = new Object();
                
                if(isNaN(newProperty) && !isArray) {
                    Object.defineProperty(property, newProperty, {
                        value: supportingDataObject,
                        writable: true,
                        enumerable: true
                    })
                    return property;
                }
                
                if(isArray){
                    Object.defineProperty(property, newProperty, {
                        value: [supportingDataObject],
                        writable: true,
                        enumerable: true
                    })
                    isArray = false;
                    return property;
                }
                
                //Check if a number is given the next property will be an array
                if(!isNaN(newProperty)){
                    isArray = true;
                    return supportingDataObject;
                }
                
            }, insightSupportingObjectData)
        }
        
        
        //remove unnecessary fields
        if(activeInsight.hasOwnProperty('Id')) insight['Id'] = activeInsight['Id'];
        insight['Score'] = 0.50;
        insight['ParentId'] = recordId;
        insight['InsightTypeId'] = insightTypes[insightType];
        insight['SupportingData'] = JSON.stringify(insightSupportingData);
        
        helper.fireAction(component, 'c.upsertInsight', {
            insight: insight
        })
        .then(function(){
            return helper.fireAction(component, 'c.getInsights', {
                parentId: recordId
            });
        })
        .then(function(insights){
            return helper.setInsights(component, insights);
        })
        .then(function(){
            return helper.setViewState(component, {
                view: 'home'
            })
        })
        .then(function(){
            component.set('v.activeInsight', {})
        })
    },
    deleteInsight: function(component, event, helper){
        let insight = event.getParam('payload');
        let insightIndex = event.getParam('index');
        let recordId = component.get('v.recordId');
        
        helper.fireAction(component, 'c.deleteRecord', {
            record: insight
        })
        .then(function(){
            return helper.fireAction(component, 'c.getInsights', {
                parentId: recordId
            })
        })
        .then(function(insights){
            return helper.setInsights(component, insights);
        })
    },
    close: function(component, event, helper){
        let closeQuickAction = $A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
    }
})