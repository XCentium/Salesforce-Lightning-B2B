({
	doInit : function(component, event, helper) {
        helper.GetZone(component, event);
        helper.GetGuestUser(component, event);
    },
    checkForSimilarIdeas : function(component, event, helper){
        var title = component.find("title").get("v.value");
        if(typeof(title) != 'undefined' && title != ''){
        	$('.loadingSimilarIdeas').css('display', 'block');
            $('.titleError').css('display', 'none');
            var action = component.get("c.findSimilarIdeas");
            action.setParams({"title" : title});
            action.setCallback(this, function(a) {
                component.set("v.similarIdeas", a.getReturnValue());
                $('.loadingSimilarIdeas').css('display', 'none');
            });
            $A.enqueueAction(action);
        }
    },
    submitPostIdea : function(component, event, helper) {
        var title = component.find("title").get("v.value");
        var description = component.find("description").get("v.value");
        var zone = component.find("zone").get("v.value");
        if(zone != ''){
            $('.zoneError').css('display', 'none');
            if(typeof(title) != 'undefined' && title != ''){
                $('.titleError').css('display', 'none');
                var action = component.get("c.postIdea");
                action.setParams({"title" : title, "description" : description, "zone" : zone});
                action.setCallback(this, function(a) {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/idea/"+a.getReturnValue()
                    });
                    urlEvent.fire();
                });
                $A.enqueueAction(action);
            }else{
                $('.titleError').css('display', 'block');
            }
        }else{
            $('.zoneError').css('display', 'block');
        }
    },
    cancelPostIdea : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/ideas"
        });
        urlEvent.fire();
    }
})