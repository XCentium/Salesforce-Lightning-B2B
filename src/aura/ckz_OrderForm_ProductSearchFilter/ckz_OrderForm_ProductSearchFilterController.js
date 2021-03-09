({
    handleFilterChange : function(component, event, helper) {
        var changeValue = event.getParam("value");

        // This event will be handled by the parent component
        var event = component.getEvent("productFilterChange");

        event.setParam("filterName", component.get("v.filterName"));
        event.setParam("filterSfid", component.get("v.filterSfid"));
        event.setParam("filterSelections", changeValue);

        event.fire();

    },
});