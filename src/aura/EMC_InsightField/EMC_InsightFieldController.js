({
    onInit : function(component, event, helper){
        if(helper.VERBOSE) console.log('InsightField Init')
        let didInit = component.get('v.didInit');
        let field = component.get('v.field');
        if(!didInit){ 
            if(field.type == 'lookup' && field.value) helper.prepopulate(component,field);
            if(field.type == 'time' && field.value) helper.formatTime(component, field);
            component.set('v.didInit', true);
        }
	},
	lookup : function(component, event, helper) {
        let searchTerm = component.find('searchTerm').get('v.value');
        let isRunning = component.get('v.isRunning');
        
        if(searchTerm.length > 2 && isRunning == false){

            component.set('v.isRunning', true);
            helper.fireAction(component, 'c.getLookup', {
                sobjectType: component.get('v.field').parentType,
                sobjectField: component.get('v.lookupField'),
                searchString: searchTerm
            })
            .then(function(lookups){
                if(helper.VERBOSE) console.log('lookups', lookups);
                component.set('v.lookupValues', lookups);
                component.set('v.showLookup', true);
                component.set('v.isRunning', false);
            })
        }
	},
    handleEvent : function(component, event, helper){
		let eventType = event.getParam('type');
        
        if(eventType == 'lookupSelected'){
            let lookupValue = event.getParam('payload');
            
            let field = component.get('v.field');
            let lookupField = component.get('v.lookupField');
            
            field.value = lookupValue['Id'];
            
            component.set('v.field', field)
            component.set('v.searchTerm', lookupValue[lookupField]);
            component.set('v.showLookup', false);
            component.set('v.lookupValues', []);
        }
	},
})