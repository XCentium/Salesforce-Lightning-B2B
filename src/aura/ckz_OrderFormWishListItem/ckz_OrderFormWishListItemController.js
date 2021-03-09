({
    doInit: function(component, event, helper) {
        console.log('ckz_OrderFormWishListItem - begin init()');

        // 2019-09-20  msobczak: added
        var useCardLayout = component.get("v.useCardLayout");
        console.log("useCardLayout = " + useCardLayout);

        // var userId = component.get('v.userId');
        // var locale = component.get('v.locale');
        // var storefront = component.get('v.storefront');
        // var currencyCode = component.get('v.currencyCode');
        // var accountId = component.get('v.accountId');
        // var cartStatus = component.get('v.cartStatus');

        // console.log('userId = ' + userId);
        // console.log('locale = ' + locale);
        // console.log('storefront = ' + storefront);
        // console.log('accountId = ' + accountId);
        // console.log('cartStatus = ' + cartStatus);
        // console.log('currencyCode = ' + currencyCode);
        var orderItem = component.get("v.orderItem");
        console.log('orderItem: ' + JSON.stringify(orderItem));

        // console.log('ckz_OrderItem - exit init()');

    },
    getProductSuggestions: function(component, event, helper) {
        console.log('inside getProductSuggestions');

        helper.waiting(component);

        var enableTypeahead = component.get("v.enableTypeahead");

        if(enableTypeahead == false) {
            return;
        }

        // clear out previous matches
        component.set("v.productMatches", []);

        var storefront = component.get('v.storefront');
        var locale = component.get('v.locale');
        var searchString = component.get('v.sku');
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
        var productName = selectedItem.dataset.productname;
        var sku = selectedItem.dataset.sku;
        var price = selectedItem.dataset.price;
        var product_sfid = selectedItem.dataset.product_sfid;

        component.set('v.orderItem.productName', productName);
        component.set('v.orderItem.sku', sku);
        component.set('v.orderItem.price', price);
        component.set('v.orderItem.product_sfid', product_sfid);

        component.set("v.productMatches", []);

    },
    clearProductFields: function(component, event, helper) {
        console.log('inside clearProductFields');

        component.set('v.orderItem.productName', '');
        component.set('v.orderItem.sku', '');
        component.set('v.orderItem.price', null);
        component.set('v.orderItem.product_sfid', null);
        component.set('v.orderItem.cart_item_sfid', null);
        component.set('v.orderItem.qty', '');
    },
    removeItemClicked: function(component, event, helper) {

        console.log('inside removeItemClicked');

        var sku = component.get("v.sku");
        var cart_item_sfid = component.get("v.cart_item_sfid");

        var isChecked = component.find("removeItem").get("v.checked");

        // This event will be handled by the parent component
        var event = component.getEvent("updateRemoveItems");

        event.setParam("cart_item_sfid", cart_item_sfid);
        event.setParam("sku", sku);
        event.setParam("checked", isChecked);

        event.fire();

    },
    waiting: function(component, event, helper) {
        helper.waiting(component);
    },
    doneWaiting: function(component, event, helper) {
        helper.doneWaiting(component);
    },
})