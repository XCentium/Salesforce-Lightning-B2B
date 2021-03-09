({
    mapsNavigate : function(component, event, helper) {
       var urlEvent = $A.get("e.force:navigateToURL");
       var accountId = component.get("v.accId");
        var mapItUrl = '/apex/maps__maps?recordId=' + accountId + '&baseObjectId=' + component.get('v.ObjectId') + '&tooltipField=Name&zoom=13&color=%2366FF00';
        console.log(mapItUrl);
       urlEvent.setParams({
      "url": mapItUrl,
           "isredirect": "true"
    });
    urlEvent.fire();

    
    }
})