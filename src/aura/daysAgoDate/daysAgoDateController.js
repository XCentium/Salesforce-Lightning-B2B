({
    doInit: function(component, event, helper) {
		var date = new Date();
        var days = Number(component.get("v.numDays"));
        date.setTime(date.getTime() - days * 86400000);
        component.set("v.dateString", helper.formatDate(date));
    }
})