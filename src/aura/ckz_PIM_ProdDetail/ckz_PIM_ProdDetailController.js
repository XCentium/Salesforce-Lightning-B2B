({
    doInit: function(component, event, helper) {

        console.log('ckz_PIM_ProdDetail - inside doInit');

        //console.log('productDataMap: ' + JSON.stringify(component.get("v.productDataMap")));

        console.log('ckz_PIM_ProdDetail.doInit() - screen: ' + component.get("v.screen"));

        helper.getStorefrontOptions(component);

        helper.loadAttributes(component);

    },
    handleStorefrontChange: function(component, event) {
        var selections = event.getParam('value');
        //component.set("v.selectedStorefronts", selections);
    },

    handleScreenJump: function(component, event, helper) {

        helper.saveAttributes(component);
        var screen = event.getParam("screen");

        util.openTargetComponent(component, screen);
    },
    handleNavigateNext: function(component, event, helper) {

        helper.saveAttributes(component);
        util.openNextComponent(component);
    },
})