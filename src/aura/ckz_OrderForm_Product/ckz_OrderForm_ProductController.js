({
    handleProductSelect : function(component, event, helper) {
        //var changeValue = event.getParam("value");

        // This event will be handled by the parent component
        var event = component.getEvent("productSelectChange");

        event.setParam("productName", component.get("v.product.sfdcName"));
        event.setParam("productSfid", component.get("v.product.sfid"));
        event.setParam("productSelectValue", component.get("v.productSelected"));
        event.setParam("productSKU", component.get("v.product.SKU"));

        event.fire();

    },
});