({
    doInit: function(component, event, helper) {
        // Kick off Header Helper
        helper.styleHeader(component);

        // Set the initial selected tab
        component.set("v.selected","Home");

        // Create the action - from the Server-Side Controller
        var action = component.get("c.getProducts");

        // Add callback behavior for when the response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var products = response.getReturnValue();
                component.set("v.products",products);
                component.set("v.shownProducts",products);
                //console.log(component.get("v.products"));
                helper.createFamilyMap(component,products);
            }else{
                console.log("Failed with state:"+state);
            }
        });
        //Send the action off to be executed
        $A.enqueueAction(action);
    },
    setSelected: function(component, event, helper) {
        var selectedName = event.getParam("Category");
        var familyList = event.getParam("FamilyList");
        component.set("v.selected", selectedName);
        component.set("v.shownProducts", familyList);
        //console.log("ProductCatalogController - setSelected");
    }
})