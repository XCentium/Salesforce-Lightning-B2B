({
    SetRecord : function(component, event, helper) {
        var RecordId = event.currentTarget.id;
		component.set("v.recid",RecordId);
	}
})