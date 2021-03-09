({
	MixpanelCallout : function(component, event, helper) {
        console.log('Sending Data to Mixpanel');
        console.log('Industry Name: ' + component.get("v.IndustryName"));
        console.log('Org Name: ' + component.get("v.OrgName"));
        /** Pass data to MixPanel **/
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'IDO-GetToKnow',
            payload: {
                Page: component.get("v.ScreenChoice"),
                PageID: component.get("v.recid"),
                URL: window.location.href,
                IndustryID: component.get("v.Industry"),
                UserEmail: component.get("v.UserEmail"),
                IndustryName: component.get("v.IndustryName"),
                OrgName: component.get("v.OrgName")
            }
        });
        mixpanelEvent.fire();
	}
})