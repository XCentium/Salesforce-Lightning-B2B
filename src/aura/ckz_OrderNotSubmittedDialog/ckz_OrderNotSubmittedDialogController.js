({
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
    },

    closeAndFinish: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer
        // and set set the "isOpen" attribute to "False for close the model Box.
        //alert('OK, will close soon!');
        component.set("v.isOpen", false);

        var event = component.getEvent("quickCheckoutDialogEvent");

        event.setParam("action", "FINISH");

        event.fire();

    },
})