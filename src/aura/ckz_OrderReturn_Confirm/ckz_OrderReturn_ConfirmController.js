({
    doInit: function(component, event, helper) {

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

        // convert selected items String back to a List
        var selectedItemsList = [];

        var temp = component.get("v.selectedItemsString");

        if(temp != '') {
            selectedItemsList = JSON.parse(temp);
            component.set("v.selectedItemsList", selectedItemsList);
        }

    },

    handleNavigatePrev: function (component, event, helper) {

        var navigate = component.get("v.navigateFlow");

        navigate("BACK");

    },
    handleNavigateNext: function (component, event, helper) {

        var navigate = component.get("v.navigateFlow");

        navigate("NEXT");

    },
});