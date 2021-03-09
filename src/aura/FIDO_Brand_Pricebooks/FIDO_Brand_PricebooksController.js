({
	init : function(component, event, helper) {
        var settings = component.get("v.Settings");
        var settingsLength = settings.length;
        var newSettings = [];
        for (var i = 0; i < settingsLength; i++) {
            if(settings[i].demo_industry__c == component.get('v.Industry')){
                newSettings = settings[i];
                var PricebookName = newSettings['pricebook_name__c'];
                break;
            }
        }

		var action = component.get("c.GetPricebookByIndustry");
        action.setParams({
            Industry: component.get("v.Industry"),
            Brand: PricebookName
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Pricebooks",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
	},
    GoToPricebook : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Pricebook2/' + whichOne + '/view');
    }, 
})