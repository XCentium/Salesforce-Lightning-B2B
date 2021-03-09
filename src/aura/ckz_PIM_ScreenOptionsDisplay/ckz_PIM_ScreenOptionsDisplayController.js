({
    doInit: function(component, event, helper) {
        var screen = component.get("v.screen");
        console.log("screen: " + screen);
    },
    loadScreenOptions: function(component, event, helper) {
        var screenOptions = util.getScreenOptions();
        var lastScreenOption = util.getLastScreenOption();

        console.log('lastScreenOption: ' + lastScreenOption);

        component.set("v.screenOptions", screenOptions);
        component.set("v.lastScreenOption", lastScreenOption);
    },
    goToScreen: function(component, event, helper) {

        var selectScreen = event.getSource().get("v.value");
        var currentScreen = component.get("v.screen");

        console.log('goToScreen: ' + selectScreen);

        if(selectScreen && selectScreen != null && (selectScreen != currentScreen)) {
            var nextEvent = component.getEvent("screenJump");

             nextEvent.setParam("screen", selectScreen);

             nextEvent.fire();
        }
    }
})