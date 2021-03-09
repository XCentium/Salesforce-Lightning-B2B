({
	init : function(component, event, helper) {
		var url = component.get("v.redirectURL");
        var recid = component.get("v.recordId");
        var recidURL = url+ '/' + recid + '/view';
        if(recid == ''){
            var eUrl= $A.get("e.force:navigateToURL");
            eUrl.setParams({
                "url": url 
            });
            eUrl.fire();
        }else{
            var eUrl= $A.get("e.force:navigateToURL");
            eUrl.setParams({
                "url": recidURL
            });
            eUrl.fire();
        }
	}
})