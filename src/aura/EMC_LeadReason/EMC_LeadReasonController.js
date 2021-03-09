({
    doInit : function(component, event, helper) {
        let modelFactor = component.get('v.modelFactor');
        let fieldName = modelFactor.Factor1.split('.')[1];
        let leadFieldsMap = component.get('v.leadFieldsMap');
        let selectedField = leadFieldsMap.get(fieldName);
        
        let insight = component.get('v.insight');
        
        component.set('v.modelFactorTypes', helper.modelFactorTypes);
        component.find('factor1').set('v.value', fieldName);
        
        component.set('v.fieldType', selectedField.type);
        
        if(selectedField.type == 'picklist' || selectedField.type == "multipicklist") {
            console.log('options', selectedField['picklistValues']);
            component.set('v.picklistValues', selectedField['picklistValues']);
        } else {
            component.set('v.picklistValues', []);
        }
        
        helper.setLeadFieldOptions(component, true);
    },
    confidenceChangeHandler : function(component, event, helper){
        let insight = component.get('v.insight');
        let intensity = insight.IntensityLevel.split('_');
        let intensityLevel = intensity[0];
        let intensityTrend = intensity[1];
        
        switch(intensityLevel){
            case 'HIGH': insight.Intensity = 3.0;
                break;
            case 'MEDIUM': insight.Intensity = 2.0;
                break;
            default: insight.Intensity = 1.0;
        }
        
        if(intensityTrend === 'NEG') {
            insight.Intensity = insight.Intensity * -1
        } else {
            insight.Intensity = insight.Intensity
        }
        
        component.set('v.insight', insight);
	},
    formatStringChangeHandler : function(component, event, helper){
		
	},
    modelFactorTypeChangeHandler : function(component, event, helper){
        helper.setLeadFieldOptions(component, false);
    },
    factor1ChangeHandler : function(component, event, helper){
        let fieldName = component.find("factor1").get("v.value");
        let leadFieldsMap = component.get('v.leadFieldsMap');
        let selectedField = leadFieldsMap.get(fieldName);
        let modelFactor = component.get('v.modelFactor');
        
        component.set('v.fieldType', selectedField.type);
        
        if(selectedField.type == 'picklist' || selectedField.type == "multipicklist") {
            console.log('options', selectedField['picklistValues']);
            component.set('v.picklistValues', selectedField['picklistValues']);
        } else {
            component.set('v.picklistValues', []);
        }
        
        modelFactor['Factor1'] = 'Lead.' + fieldName;
        modelFactor['SourceField1'] = 'Lead.' + fieldName;
        component.set('v.modelFactor', modelFactor);
    },
    factor2ChangeHandler : function(component, event, helper){
        let fieldName = component.find("factor2").get("v.value");
        let modelFactor = component.get('v.modelFactor');

        modelFactor['Factor2'] = 'Lead.' + fieldName;
        modelFactor['SourceField1'] = 'Lead.' + fieldName;
        component.set('v.modelFactor', modelFactor);
    },
    deleteIndex : function(component, event, helper){
        let deleteIndex = component.getEvent("deleteIndex");
        deleteIndex.setParams({
            index: component.get('v.index'),
            payload: component.get('v.insight')
        })
        deleteIndex.fire();
    }
})