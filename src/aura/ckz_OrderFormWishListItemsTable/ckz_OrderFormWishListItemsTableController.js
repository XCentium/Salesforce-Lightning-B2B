({
    doInit: function(component, event, helper) {
        console.log('ckz_OrderItemsTable - begin init()');

        var userId = component.get('v.userId');
        var locale = component.get('v.locale');
        var storefront = component.get('v.storefront');
        var currencyCode = component.get('v.currencyCode');
        var accountId = component.get('v.accountId');
        var cartStatus = component.get('v.cartStatus');
        var orderItems = component.get("v.orderItems");

        console.log('userId = ' + userId);
        console.log('locale = ' + locale);
        console.log('storefront = ' + storefront);
        console.log('currencyCode = ' + currencyCode);
        console.log('accountId = ' + accountId);
        console.log('cartStatus = ' + cartStatus);
        console.log('orderItems: ' + JSON.stringify(orderItems));

        var useCardLayout = component.get("v.useCardLayout");
        console.log("useCardLayout = " + useCardLayout);

        console.log('ckz_OrderItemsTable - exit init()');

    },
    addMore: function(component, event, helper) {

        console.log('inside addMore');

        // This event will be handled by the parent component
        var createEvent = component.getEvent("addMore");

        createEvent.fire();

    },
    // This is no longer used
    getProductInfo: function(component, event, helper) {
        console.log('inside getProductInfo');
        var storefront = component.get('v.storefront');
        var locale = component.get('v.locale');
        var searchString = 'A-1000';

        var action = component.get("c.fetchProduct");

        action.setParams({
            "storefront" : storefront,
            "locale" : locale,
            "searchString" : searchString
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state = ' + state);
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if(returnValue.price) {
                    //component.set('v.userId', returnValue.userId);
                    console.log('price = ' + returnValue.price);
                }

                if(returnValue.productName) {
                    //component.set('v.accountGroupName', returnValue.accountGroupName);
                    console.log('productName = ' + returnValue.productName);
                }

                if(returnValue.sfid) {
                    //component.set('v.accountGroup', returnValue.accountGroup);
                    console.log('sfid = ' + returnValue.sfid);
                }

                if(returnValue.productStatus) {
                    //component.set('v.locale', returnValue.locale);
                    console.log('productStatus = ' + returnValue.productStatus);
                }

            }
            else {
                console.log('Failed with state: ' + state);
            }
        });

        $A.enqueueAction(action);
    }
})