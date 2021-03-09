// noinspection BadExpressionStatementJS,JSUnusedGlobalSymbols
({
    doInit : function(component) {
        let action = component.get("c.getCountryList");
        action.setCallback(this, function(response) {
            let countryMap = response.getReturnValue();
            component.set("v.countryMap", countryMap);
        });
        $A.enqueueAction(action);
    }
});