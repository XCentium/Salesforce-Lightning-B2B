({
    doInit: function(component, event, helper) {
        console.log('ckz_OrderForm_AddItem - begin init()');

        var orderItem = helper.createNewOrderItem();

        component.set("v.orderItem", orderItem);
    },
    scriptsLoaded : function(component) {

        var orderType = component.get("v.orderType");

        if(orderType == 'cart' || orderType == 'newcart') {
            component.set("v.addButtonLabel", util.getLabel('addToCart'));
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
             component.set("v.addButtonLabel", util.getLabel('addToWishList'));
         }
    },
    getProductSuggestions: function(component, event, helper) {
        console.log('inside getProductSuggestions');

        var enableTypeahead = component.get("v.enableTypeahead");

        if(enableTypeahead == false) {
            return;
        }

        // clear out previous matches
        component.set("v.productMatches", []);

        var storefront = component.get('v.storefront');
        var locale = component.get('v.locale');
        var searchString = component.get('v.searchString');
        var accountId = component.get("v.accountId");
        var currencyCode = component.get("v.currencyCode");
        var userId = component.get("v.userId");

        if(searchString.length < 3) {
            return false;
        }

        var action = component.get("c.fetchProductSuggestions");

        action.setParams({
            "userId" : userId,
            "accountId" : accountId,
            "currencyCode" : currencyCode,
            "storefront" : storefront,
            "locale" : locale,
            "searchString" : searchString
        });

        helper.waiting(component);

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state = ' + state);
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                var matches = [];

                for(var i = 0; i < returnValue.length; i++) {
                    var product = {};

                    product.productName = returnValue[i].productName;
                    product.sfid = returnValue[i].sfid;
                    product.price = returnValue[i].price;
                    product.sku = returnValue[i].sku;
                    product.thumbnailImage = returnValue[i].thumbnailImage;

                    // 2019-10-10  msobczak
                    product.product_sfid = returnValue[i].sfid;
                    product.qty = 1;
                    product.orig_qty = 1;
                    product.cart_item_sfid = '';

                    matches.push(product);
                }

                component.set("v.productMatches", matches);

                console.log('returnValue = ' + returnValue);

            }
            else {
                console.log('Failed with state: ' + state);
            }

            helper.doneWaiting(component);
        });

        $A.enqueueAction(action);
    },
    // Called when the user selects a product suggestion
    setProductFields: function(component, event, helper) {
        console.log('inside setProductFields');

        var selectedItem = event.currentTarget;

        var product_sfid = selectedItem.dataset.product_sfid;

        // 2019-10-10  msobczak
        var productMatches = component.get("v.productMatches");
        for(var i = 0; i < productMatches.length; i++) {
            var product = productMatches[i];
            if(product.product_sfid === product_sfid) {
                component.set("v.selectedProduct", product);
                break;
            }
        }

        component.set("v.productMatches", []);

    },
    clearProductFields: function(component, event, helper) {
        console.log('inside clearProductFields');

        component.set('v.selectedProduct', null);

        component.set('v.searchString', '');
    },
    handleNavigatePrev: function(component, event, helper) {

        var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        var orderType = component.get("v.orderType");

        if(orderType == 'cart' || orderType == 'newcart') {
            event.setParam("type", "c:ckz_OrderFormDataEntry");
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
            event.setParam("type", "c:ckz_OrderFormWishListEdit");
        }

        event.setParam("attributes", attrs);

        event.fire();

    },
    addItemAndReturnToCart: function(component, event, helper) {

        console.log('ckz_OrderForm_AddItem - begin addItemAndReturnToCart()');

        var orderItem = component.get("v.selectedProduct");

        var orderItems = component.get("v.orderItems");

        orderItems.push(orderItem);

        var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        var orderType = component.get("v.orderType");

        if(orderType == 'cart' || orderType == 'newcart') {
            event.setParam("type", "c:ckz_OrderFormDataEntry");
        }
        else if(orderType == 'wish' || orderType == 'newwish') {
            event.setParam("type", "c:ckz_OrderFormWishListEdit");
        }

        event.setParam("attributes", attrs);

        event.fire();
    },
    waiting: function(component, event, helper) {
        helper.waiting(component);
    },
    doneWaiting: function(component, event, helper) {
        helper.doneWaiting(component);
    },
    
})