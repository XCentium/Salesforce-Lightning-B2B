({
    // Dialog
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"
        helper.closeIt(component);
    },
    closeAndFinish: function(component, event, helper) {

    },
    onLoad: function(component, event, helper) {
        var saved = component.get("v.saved");

        console.log('ckz_ProductMediaDialog: onLoad() begin');
        console.log('productName = ' + component.get("v.productName"));

        var productField = component.find('product');
        productField.set("v.value", component.get("v.productId"));

        console.log('ckz_ProductMediaDialog: onLoad() exit');
    },
    onSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been Saved successfully."
        });
        toastEvent.fire();

        helper.closeIt(component);

        var event = component.getEvent("recordSavedEvent");

        event.fire();

    },
    onSubmit : function(component, event, helper) {
        event.preventDefault(); // stop form submission

        var eventFields = event.getParam("fields");

        component.find('recordEditForm').submit(eventFields);
    },
    onError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Error."
        });
        toastEvent.fire();
    }
});