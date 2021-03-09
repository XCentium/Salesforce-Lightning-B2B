({
    login : function(component, event, helper){
        var loginUserId = component.get("v.loginUserId");
        var orgId = component.get("v.orgId");
        var networkId = component.get("v.networkId");
        var isInternal = component.get("v.isInternal");
        
        var url = "/servlet/servlet.su?oid=" + orgId + "&retURL=/";
        
        if(!isInternal){
            url += "&sunetworkuserid=" + loginUserId;
        }
        else {
            url += "&suorgadminid=" + loginUserId;
        }
        
        if(networkId != null && !isInternal){
            url += "&sunetworkid=" + networkId;
        } else if(networkId != null && isInternal){
            url += "&targetURL=%2Fservlet%2Fnetworks%2Fswitch%3FnetworkId%3D" + networkId.slice(0,-3);
        } else {
            url += "&targetURL=%2F";
        }
        
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'SDO Event',
            payload: {
                action: 'Personas - Multi'
            }
        });
        
        mixpanelEvent.fire();
        
        console.log('Redirect URL:', url);
        
        window.location.replace(url);
    }
})