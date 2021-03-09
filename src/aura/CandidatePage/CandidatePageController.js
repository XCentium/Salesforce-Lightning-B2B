({
	contactSelected : function(component) {
        var event = $A.get("e.force:navigateToSObject");
        if (event) {
            event.setParams({"recordId": component.get("v.applicant").Id});
            event.fire();
        }
    }
})