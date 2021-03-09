({
    doInit: function(component, event, helper) {

        console.log('ckz_OrderReturn_CreateCase - doInit()');

        // Figure out which buttons to display
        var availableActions = component.get('v.availableActions');
        for (var i = 0; i < availableActions.length; i++) {
            if (availableActions[i] == "PAUSE") {
                component.set("v.canPause", true);
            } else if (availableActions[i] == "BACK") {
                component.set("v.canBack", true);
            } else if (availableActions[i] == "NEXT") {
                component.set("v.canNext", true);
            } else if (availableActions[i] == "FINISH") {
                component.set("v.canFinish", true);
            }
        }

        var recordId = component.get("v.recordId");

        console.log('recordId = ' + recordId);

        helper.generateCase(component);

    },
    handleNavigatePrev: function (component, event, helper) {

        var navigate = component.get("v.navigateFlow");

        navigate("BACK");

    },
    handleNavigateFinish: function (component, event, helper) {

        var navigate = component.get("v.navigateFlow");

        navigate("FINISH");

    },
});