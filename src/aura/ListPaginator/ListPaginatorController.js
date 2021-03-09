({
	previousPage : function(component, event, helper) {
        var evtHandler = "e."+component.get("v.evtHandler");
        var myEvent = $A.get(evtHandler);
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
	},
	nextPage : function(component, event, helper) {
        var evtHandler = "e."+component.get("v.evtHandler");
        var myEvent = $A.get(evtHandler);
        //var myEvent = $A.get("e.c:LeadPassPageChange");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire();
	}
})