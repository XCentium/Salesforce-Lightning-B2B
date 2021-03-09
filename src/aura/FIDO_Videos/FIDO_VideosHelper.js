({
	MixpanelCallout : function(component, event, helper) {
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