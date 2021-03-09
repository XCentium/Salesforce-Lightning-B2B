({
    init: function(component, event, helper){
        let d = new Date();
        let thirtydaysago = d.setDate(d.getDate() - 30);
        thirtydaysago = new Date(thirtydaysago).toISOString();

        component.set("v.currentDate",thirtydaysago);
        if(orgId != ''){
           var orgId = component.get("v.OrgId");
            var endpoint = '/api/announcements?demo_org__c=' + orgId + '&orderby=order__c';
            var callout = component.get("c.getCalloutResponseContents");
            callout.setParams({
                endpoint: endpoint
            });
            callout.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var res = JSON.parse(response.getReturnValue());
            		component.set("v.Announcements",res);
                    for(var i = 0; i < res.length; i++){
                    if(res[i].createddate < thirtydaysago){
                        component.set("v.hasOldUpdate",true);
                        console.log("Set Old: " + component.get("v.hasOldUpdate"));
                        break;
                    }
                }
                }else{
                    console.log("error: " + orgid);
                }
            });
            $A.enqueueAction(callout); 
        }
	},
    LoadAnnouncements : function(component, event, helper) {
        let d = new Date();
        let thirtydaysago = d.setDate(d.getDate() - 30);
        thirtydaysago = new Date(thirtydaysago).toISOString();
        
        var orgId = component.get("v.OrgId");
        var endpoint = '/api/announcements?demo_org__c=' + orgId;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(response.getReturnValue());
            	component.set("v.Announcements",res);

                for(var i = 0; i < res.length; i++){
                    if(res[i].createddate < thirtydaysago){
                        component.set("v.hasOldUpdate",true);
                        console.log("Set Old: " + component.get("v.hasOldUpdate"));
                        break;
                    }
                }
            }else{
                console.log("error: " + orgid);
            }
        });
		$A.enqueueAction(callout);
	},
    toURL : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    goToSingle: function(component, event, helper) {
        component.set("v.ScreenChoice",'Updates');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
})