({
	doInit : function(component, event, helper) {
		var action = component.get("c.getCustomSettingsData");
        action.setParams({"customSettingName" : component.get('v.selCustomSetting')});
        action.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS') {
                var Wrap = response.getReturnValue();
                component.set('v.colHeaders', Wrap.colHeaders);
                component.set('v.records', Wrap.records);
                console.log(Wrap.records);
            }
        });
        $A.enqueueAction(action);
	}
})