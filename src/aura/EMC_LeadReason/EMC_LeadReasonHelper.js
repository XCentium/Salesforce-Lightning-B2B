({
    VERBOSE: true,
    modelEnumValues: {
        "IS_EQUAL": {
            input_type_1: 'any',
            input_type_2: 'any',
            template: "${field_1} is ${value}"
        },
        "IS_NOT_EQUAL": {
            input_type_1: 'any',
            input_type_2: 'any',
            template:  "${field_1} is not ${value}"
        },
        "IS_VALID": {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is valid"
        },
        "IS_NOT_VALID": {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is not valid"
        },
        "ARE_VALID": {
            input_type_1: 'multipicklist',
            input_type_2: null,
            template: "${field_1} are valid"
        },
        "ARE_NOT_VALID": {
            input_type_1: 'multipicklist',
            input_type_2: null,
            template: "${field_1} are not valid"
        },
        "IS_SPECIFIED": {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is specified"
        },
        "IS_NOT_SPECIFIED": {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is not specified"
        },
        "ARE_SPECIFIED": {
            input_type_1: 'multipicklist',
            input_type_2: null,
            template: "${field1} are specified"
        },
        "ARE_NOT_SPECIFIED": {
            input_type_1: 'multipicklist',
            input_type_2: null,
            template: "${field_1} are not specified"
        },
        "IS_SIMILAR": {
            input_type_1: 'any',
            input_type_2: 'picklist',
            template: "${field_1} is similar to ${field_2}"
        },
        "IS_NOT_SIMILAR": {
            input_type_1: 'any',
            input_type_2: 'picklist',
            template: "${field_1} is not similar to ${field_2}"
        },
        "ARE_SIMILAR": {
            input_type_1: 'multipicklist',
            input_type_2: 'multipicklist',
            template: "${field_1} are similar to ${field_2}"
        },
        "ARE_NOT_SIMILAR": {
            input_type_1: 'multipicklist',
            input_type_2: 'multipicklist',
            template: "${field_1} are not similar to ${value}"
        },
        "IS_NOT_COMMON": {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is not common"
        },
        "NUMERIC":  {
            input_type_1: 'any',
            input_type_2: null,
            template: "${field_1} is numeric"
        }
    },
    modelFactorTypes: [
        {
            "value": "IS_EQUAL",
            "label": "<Field> is <Value>"
        },
        {
            "value": "IS_NOT_EQUAL",
            "label": "<Field> is not <Value>"
        },
        {
            "value": "IS_VALID",
            "label": "<Field> is valid"
        },
        {
            "value": "IS_NOT_VALID",
            "label": "<Field> is not valid"
        },
        {
            "value": "ARE_VALID",
            "label": "<Multipicklist Values> are valid"
        },
        {
            "value": "ARE_NOT_VALID",
            "label": "<Multipicklist Values> are not valid"
        },
        {
            "value": "IS_SPECIFIED",
            "label": "<Field Value> is specified"
        },
        {
            "value": "IS_NOT_SPECIFIED",
            "label": "<Field Value> is not specified"
        },
        {
            "value": "ARE_SPECIFIED",
            "label": "<Multipicklist Values> are specified"
        },
        {
            "value": "ARE_NOT_SPECIFIED",
            "label": "<Multipicklist Values> are not specified"
        },
        {
            "value": "IS_SIMILAR",
            "label": "<Field Value> is similar to <Field Value>"
        },
        {
            "value": "IS_NOT_SIMILAR",
            "label": "<Field Value> is not similar to <Field Value>"
        },
        {
            "value": "ARE_SIMILAR",
            "label": "<Multipicklist Values> are similar to <Multipicklist Values>"
        },
        {
            "value": "ARE_NOT_SIMILAR",
            "label": "<Multipicklist Values> are not similar to <Multipicklist Values>"
        },
        {
            "value": "IS_NOT_COMMON",
            "label": "<Field> is not common"
        },
        {
            "value": "NUMERIC",
            "label": "<Field> is numeric"
        }
    ],
    getLeadFieldValue: function(component, field){
        let leadValues = component.get('v.leadValues');
        return leadValues[field] ? leadValues[field] : null;
    },
    evaluatePreview: function(component){
        let modelFactor = component.get('v.modelFactor');
        let insight = component.get('v.insight');
        
        //eval blacklisted as of 210
        let evalText = modelEnumValues[modelFactorType.Type];
        let field =  modelFactor.Factor1;
        let value = insight.Value;
        //let preview = eval(evalText);
        //component.set('v.preview', preview);
    },
    setLeadFieldOptions : function(component, isInit){
        let modelFactor = component.get('v.modelFactor');
        let modelFactorType = modelFactor.Type;
        let modelFactorEnum = this.modelEnumValues[modelFactorType];
        
        let Factor1Options = component.get('v.leadFields');
        let Factor2Options = component.get('v.leadFields'); // Object.assign({}, Factor1Options);

        if(modelFactorEnum.input_type_1 == 'multipicklist'){
            Factor1Options = Factor1Options.filter(function(leadField){
                return leadField.type == 'multipicklist'
            })
        }
        
        if(modelFactorEnum.input_type_2 && modelFactorEnum.input_type_2 != 'any'){
            component.set('v.hasFactor2', true);
        } else {
            component.set('v.hasFactor2', false);
        }
            
        if(modelFactorEnum.input_type_2 == 'multipicklist'){
            Factor2Options = Factor2Options.filter(function(leadField){
                return leadField.type == 'multipicklist'
            })
        }
        
        if(modelFactorEnum.input_type_2 == 'picklist'){
            Factor2Options = Factor2Options.filter(function(leadField){
                return leadField.type != 'multipicklist'
            })
        }
        
        component.set('v.Factor1Options', Factor1Options);
        component.set('v.Factor2Options', Factor2Options);
        
        if(!isInit && (modelFactorEnum.input_type_1 == 'picklist' || modelFactorEnum.input_type_1 == 'multipicklist')){
            let factor1 = component.get('v.factor1');
            
            //Clean up null exception
            modelFactor['Factor1'] = Factor1Options.length > 0 ? 'Lead.' + Factor1Options[0].name : null;
            factor1 = Factor1Options.length > 0 ? Factor1Options[0].name : null;
            
            component.set('v.factor1', factor1);
        }
        
        if(!isInit && (modelFactorEnum.input_type_2 == 'picklist' || modelFactorEnum.input_type_2 == 'multipicklist')){
            let factor2 = component.get('v.factor2');
            
            modelFactor['Factor2'] = Factor2Options.length > 0 ? 'Lead.' + Factor2Options[0].name : null;
            factor2 = Factor2Options.length > 0 ? Factor2Options[0].name : null;
            
            component.set('v.factor2', factor2);
        }
        if(!isInit) component.set('v.modelFactor', modelFactor);
    }
})