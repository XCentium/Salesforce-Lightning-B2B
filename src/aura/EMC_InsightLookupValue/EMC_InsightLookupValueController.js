({
	onInit : function(component, event, helper) {
		let lookup = component.get('v.lookupValue');
		let lookupField = component.get('v.lookupField');
        
        component.set('v.lookupDisplayed', lookup[lookupField]);
	},
	selectedEvent : function(component, event, helper) {
		let lookupSelectedEvent = component.getEvent('lookupSelected');
        let data = component.get('v.lookupValue');
        lookupSelectedEvent.setParams({
            'type': 'lookupSelected',
            'payload': data
        })
        lookupSelectedEvent.fire();
	}
})