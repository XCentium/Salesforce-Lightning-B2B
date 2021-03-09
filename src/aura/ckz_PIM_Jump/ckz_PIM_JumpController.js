/**
 * Created by msobc on 2/5/2019.
 */
({
    doInit: function(component, event, helper) {
        console.log('ckz_PIM_Jump.doInit() - screen: ' + component.get("v.screen"));
    },
    handleScreenChange: function(component, event, helper) {
        var screen = component.find("selectScreen").get("v.value");

        if(screen != null && screen != '') {

            console.log('ckz_PIM_Jump.handleScreenChange() - screen: ' + screen);
            component.set("v.screen", screen);

            var event = component.getEvent("screenJump");

             event.setParam("screen", screen);

             event.fire();
        }
    },
    loadScreenOptions: function(component, event, helper) {
        var screenOptions = util.getScreenOptions();

        component.set("v.screenOptions", screenOptions);
    }
})