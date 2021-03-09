({
    createFamilies: function(component, event, helper){
    	console.log("Help");
        var products = event.getParam("products");
        console.log("PRODUCTS IN TABS CONTROLLER",products);
        component.set("v.products",products);
    },
})