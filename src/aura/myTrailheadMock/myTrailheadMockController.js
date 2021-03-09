({
	add : function(component, event, helper) {
        helper.ToastNotification('Successfully added to your myTrailhead', 'Congrats, you have added this trail to your myTrailhead account.', 'success');
	},
    favorite : function(component, event, helper) {        
        helper.ToastNotification('Successfully added to your myTrailhead Favorites', 'Congrats, you have added this trail to your myTrailhead Favorites List.', 'success');
	},
    FirstLink : function(component, event, helper) {
        if(component.get("v.FirstTrailLink") != ''){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": component.get("v.FirstTrailLink")
            });
            urlEvent.fire();
        }
    },
    SecondLink : function(component, event, helper) {
        if(component.get("v.SecondTrailLink") != ''){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": component.get("v.SecondTrailLink")
            });
            urlEvent.fire();
        }
    },
    ThirdLink : function(component, event, helper) {
        if(component.get("v.ThirdTrailLink") != ''){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": component.get("v.ThirdTrailLink")
            });
            urlEvent.fire();
        }
    }
})