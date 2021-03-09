/**
 * Created by msobczak on 10/30/2018.
 */
({
    getUserInfo: function(component) {
        console.log('inside getUserInfo');

        var action = component.get("c.fetchUserInfo");

        var recordId = component.get('v.recordId');

        action.setParams({
            "recordId" : recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if(returnValue.accountGroupName) {
                    component.set('v.accountGroupName', returnValue.accountGroupName);
                    console.log('accountGroupName = ' + returnValue.accountGroupName);
                }

                if(returnValue.accountGroup) {
                    component.set('v.accountGroup', returnValue.accountGroup);
                }

                if(returnValue.userName) {
                    component.set('v.userName', returnValue.userName);
                }

//                if(returnValue.accountId) {
//                    component.set('v.accountId', returnValue.accountId);
//                    console.log('accountId = ' + returnValue.accountId);
//                }

            }
            else {
                console.log('Failed with state: ' + state);
            }
        });

        $A.enqueueAction(action);
    },
    getStorefrontOptions: function(component) {
        console.log('inside getStorefrontOptions');

        // 2019-03-04  msobczak: need to get this here.  If this is done within the callback function, the component value is undefined.
        var selectedStorefront = component.get("v.selectedStorefront");

        var action = component.get("c.getStorefrontSet");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                component.set('v.storefrontOptions', returnValue);

                if(returnValue.length == 1) {

                    // Let DOM state catch up.
                    window.setTimeout(
                        $A.getCallback( function() {
                            // Now set our preferred value
                            var cmp = component.find("selectStorefront");

                            if(cmp) {
                                cmp.set("v.value", returnValue[0]);
                            }

                            component.set("v.selectedStorefront", returnValue[0]);
                        }));

                }
                else {

                    if(selectedStorefront != null && selectedStorefront != "") {
                        // Let DOM state catch up.
                        window.setTimeout(
                            $A.getCallback( function() {
                                // Now set our preferred value
                                component.find("selectStorefront").set("v.value", selectedStorefront);
                            }));
                    }
                }
            }
            else {
                console.log('Failed with state: ' + state);
            }
        });

        $A.enqueueAction(action);
    },
    setDefaultStorefrontOptions: function(component) {

        var options = component.get('v.storefrontOptions');

        if(options.length == 1) {
        // Let DOM state catch up.
        window.setTimeout(
            $A.getCallback( function() {
                // Now set our preferred value
                var cmp = component.find("selectStorefront");

                if(cmp) {
                    cmp.set("v.value", options[0]);
                }

                component.set("v.selectedStorefront", options[0]);
            }));

        }
    },
    getOrders: function(component) {
        try{
            var hasOrders = false;

            var userId = component.get('v.userId');
            var locale = component.get('v.locale');
            //var storefront = component.find('selectStorefront').get("v.value");

            //component.set('v.selectedStorefront', storefront);

            // 2019-09-05  msobczak: chanaged
            var storefront = component.get("v.selectedStorefront");

            console.log('getOrders - storefront: ' + storefront);

            if(storefront == "") {
                component.set('v.orders', []);
                component.set('v.hasOrders', hasOrders);
                return;
            }

            var action = component.get("c.fetchOrders");

            action.setParams({
                "storefront" : storefront,
                "userId" : userId,
                "locale" : locale
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    if(response.getReturnValue()) {
                        var returnValue = response.getReturnValue();
                        if(returnValue.length > 0) {
                            console.log('orders size = ' + returnValue.length);
                            component.set('v.orders', returnValue);

                            for(var i = 0; i < returnValue.length; i++) {
                                returnValue[i].isSelected = false;
                            }

                            hasOrders = true;
                        }
                    }
                    else {
                        console.log('no data returned in response');
                    }
                }
                else {
                    console.log('Failed with state: ' + state);
                }

                component.set('v.hasOrders', hasOrders);

            });

            $A.enqueueAction(action);

        }
        catch(err) {
            console.log('error message: ' + err.message);
        }
    },
    getCarts: function(component) {
        try{
            var hasCarts = false;

            var userId = component.get('v.userId');
            var locale = component.get('v.locale');
            //var storefront = component.find('selectStorefront').get("v.value");

            //component.set('v.selectedStorefront', storefront);

            // 2019-09-05  msobczak: chanaged
            var storefront = component.get("v.selectedStorefront");

            console.log('getCarts - storefront: ' + storefront);

            if(storefront == "") {
                component.set('v.carts', []);
                //component.set('v.childCarts', []);
                component.set('v.hasCarts', hasCarts);
                return;
            }

            var action = component.get("c.fetchCarts");

            action.setParams({
                "storefront" : storefront,
                "userId" : userId,
                "locale" : locale
            });


            // If I comment this out, the code does not go into an infinite loop.
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    if(response.getReturnValue()) {
                        var returnValue = response.getReturnValue();
                        if(returnValue.length > 0) {
                            console.log('carts size = ' + returnValue.length);
                            component.set('v.carts', returnValue);

                            for(var i = 0; i < returnValue.length; i++) {
                                returnValue[i].isSelected = false;
                            }

                            hasCarts = true;
                        }
                    }
                    else {
                        console.log('no data returned in response');
                    }
                }
                else {
                    console.log('Failed with state: ' + state);
                }

                component.set('v.hasCarts', hasCarts);

            });

            $A.enqueueAction(action);

        }
        catch(err) {
            console.log('error message: ' + err.message);
        }
    },
    getWishLists: function(component) {
        try{
            var hasWishLists = false;

            var userId = component.get('v.userId');
            var locale = component.get('v.locale');

            // 2019-09-05  msobczak: chanaged
            var storefront = component.get("v.selectedStorefront");

            console.log('getWishLists - storefront: ' + storefront);

            if(storefront == "") {
                component.set('v.wishLists', []);
                component.set('v.hasWishLists', hasWishLists);
                return;
            }

            var action = component.get("c.fetchWishLists");

            action.setParams({
                "storefront" : storefront,
                "userId" : userId,
                "locale" : locale
            });


            // If I comment this out, the code does not go into an infinite loop.
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    if(response.getReturnValue()) {
                        var returnValue = response.getReturnValue();
                        if(returnValue.length > 0) {
                            console.log('wish lists size = ' + returnValue.length);
                            component.set('v.wishLists', returnValue);

                            for(var i = 0; i < returnValue.length; i++) {
                                returnValue[i].isSelected = false;
                            }

                            hasWishLists = true;
                        }
                    }
                    else {
                        console.log('no data returned in response');
                    }
                }
                else {
                    console.log('Failed with state: ' + state);
                }

                component.set('v.hasWishLists', hasWishLists);

            });

            $A.enqueueAction(action);

        }
        catch(err) {
            console.log('error message: ' + err.message);
        }
    },
    customValidation: function(component) {
        var orderType = component.get("v.orderType");

        if(orderType == "new") {
            return { isValid: true };
        }

        if(orderType == "order") {
            var selectedOrderId = component.get("v.selectedOrderId");

            if(selectedOrderId == null || selectedOrderId == "") {
                return { isValid: false, errorMessage: "Please select an order from the table" };
            }
        }

        if(orderType == "cart") {
            var cartId = component.get("v.cartId");

            if(cartId == null || cartId == "") {
                return { isValid: false, errorMessage: "Please select a cart from the table" };
            }
        }
    },
    clearCartSelections: function(component) {
        var someArray = component.get("v.carts");

        if(someArray.length > 0) {
            this.clearSelection(someArray);
        }

    },
    clearOrderSelections: function(component) {
        var someArray = component.get("v.orders");

        if(someArray.length > 0) {
            this.clearSelection(someArray);
        }

    },
    clearSelection: function(someArray) {
        for(var i = 0; i < someArray.length; i++) {
            someArray[i].isSelected = false;
        }
    },
    selectObj: function(someArray, sfid) {
        if(someArray.length > 0) {
            for(var i = 0; i < someArray.length; i++) {
                if(someArray[i].sfid === sfid) {
                    someArray[i].isSelected = true;
                    break;
                }
            }
        }
        return someArray;
    }

})