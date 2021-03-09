/**
 * Created by msobczak on 11/1/2018.
 */
({
    // 2020-03-31: added helper method.  This is called when viewing a new cart and the cart has no items.
    addMoreOrderItems: function(component) {

        console.log('inside handleAddMoreOrderItems');

        var maxItems = 5;

        var orderItems = component.get("v.orderItems");

        console.log('orderItems size = ' + orderItems.length);

        for(var i = 0; i < maxItems; i++) {
            var orderItem = this.createNewOrderItem();

            orderItems.push(orderItem);
        }

        console.log('orderItems new size = ' + orderItems.length);

        component.set('v.orderItems', orderItems);

    },
    createNewOrderItem: function() {
        var orderItem = {};
        orderItem.product_sfid = '';
        orderItem.sku = '';
        orderItem.productName = '';
        orderItem.price = null;
        orderItem.cart_item_sfid = null;

        orderItem.qty = null;
        orderItem.orig_qty = null;

        return orderItem;
    },

    getOrderItems: function(component, userId, storefront, currencyCode, accountId, locale, orderId) {

        console.log('inside getOrderItems()');

        var action = component.get("c.fetchOrderItems");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "orderId" : orderId

        });

        this.waiting(component);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                component.set('v.orderItems', returnValue);

                // 2019-10-10  msobczak: automatically create the cart.
                this.createCart(component);

            }
            else {
                console.log('Failed with state: ' + state);
            }

            // 2019-06-04  msobczak: added
            this.doneWaiting(component);
        });

        $A.enqueueAction(action);

    },

    getCartItems: function(component, userId, storefront, currencyCode, accountId, locale, cartId) {

        console.log('inside getCartItems()');

        component.set("v.pageMessages", []);

        var action = component.get("c.fetchCartItems");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "cartId" : cartId,
            "getPrices" : true
        });

        this.waiting(component);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                console.log('getCartItems() returnValue = ' + JSON.stringify(returnValue));

                component.set('v.orderItems', returnValue);

                var messages = [];
                //messages.push({'severity' : 'info', 'message' : 'Cart Loaded'});

                var cartStatus = component.get('v.cartStatus');
                if(cartStatus == 'Closed') {
                    messages.push({'severity' : 'error', 'message' : 'This cart is Closed. An order has already been placed for it.'});
                }

                component.set("v.pageMessages", messages);

            }
            else {
                console.log('Failed with state: ' + state);
            }

            // 2019-06-04  msobczak: added
            this.doneWaiting(component);
        });

        $A.enqueueAction(action);

    },

    createCart: function(component) {

        console.log('inside createCart()');

        this.waiting(component);

        var messages = [];

        component.set("v.pageMessages", messages);

        var userId = component.get('v.userId');
        var contactId = component.get('v.contactId');
        var storefront = component.get('v.selectedStorefront');
        var currencyCode = component.get('v.currencyCode');
        var orderItems = component.get("v.orderItems");
        var cartId = component.get("v.cartId");
        var locale = component.get('v.locale');
        var accountId = component.get('v.accountId');

        // Validate the contents of the cart
        // also done in helper.updateCartHelper()
        var validationMessages = this.validateOrderForm(component, orderItems);

        if(validationMessages.length > 0) {
            for(var i = 0; i < validationMessages.length; i++) {
                messages.push({'severity' : 'error', 'message' : validationMessages[i]});
            }

            component.set("v.pageMessages", messages);

            return false;
        }

        var addItems = [];
        var itemsJson = null;

        if(cartId == null || cartId == "") {
            if(orderItems.length > 0) {
                for(var i = 0; i < orderItems.length; i++) {
                    var orderItem = orderItems[i];

                    if((orderItem.sku != null && orderItem != '') && (orderItem.qty > 0)) {
                        addItems.push(orderItem);
                    }
                }

                if(addItems.length > 0) {
                    itemsJson = JSON.stringify(addItems);
                }
            }
        }

        if(itemsJson == null) {
            
            messages.push({'severity' : 'warning', 'message' : 'Cart contains no items.  Please add an item.'});
            component.set("v.pageMessages", messages);

        }

        if(messages.length > 0) {
            return;
        }

        messages.push({'severity' : 'info', 'message' : "Please wait while the cart is being created..."});

        component.set("v.pageMessages", messages);

        var action = component.get("c.fetchNewCart");

        action.setParams({
            "userId" : userId,
            "contactId" : contactId,
            "locale" : locale,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "itemsJson" : itemsJson
        });

        action.setCallback(this, response => this.updateOrderItems(component, response));

        $A.enqueueAction(action);

    },
    // Legacy code
    updateCartAddItems: function(component, cartId, itemsJson) {

        console.log('inside updateCartAddItems()');

        var action = component.get("c.putLineItems");

        action.setParams({
            "cartId" : cartId,
            "itemsJson" : itemsJson
        });

        this.waiting(component);

        action.setCallback(this, response => this.updateOrderItems(component, response));

        $A.enqueueAction(action);

    },
    updateCartAddRemoveUpdate: function(component, userId, storefront, currencyCode, accountId, locale, cartId, addItemsJson, removeItemsJson, updateItemsJson) {

        console.log('inside updateCartAddRemoveUpdate()');

        var action = component.get("c.fetchUpdatedCart");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "cartId" : cartId,
            "addItemsJson" : addItemsJson,
            "removeItemsJson" : removeItemsJson,
            "updateItemsJson" : updateItemsJson
        });

        this.waiting(component);

        action.setCallback(this, response => this.updateOrderItems(component, response));

        $A.enqueueAction(action);

    },
    // Utility function to handle updating the order items with cart item SFIDs
    updateOrderItems: function(component, response) {

        console.log('ckz_OrderFormDataEntry - begin updateOrderItems()');

        var messages = [];

        component.set("v.pageMessages", messages);

        var state = response.getState();

        if (state === 'SUCCESS') {
            var returnValue = response.getReturnValue();

            // 2019-09-25  msobczak: added
            component.set("v.orderType", "cart");

            var cartEncryptedId = returnValue.cartEncryptedId;
            var cartId = returnValue.cartId;

            console.log('cartEncryptedId = ' + cartEncryptedId);

            if(component.get('v.cartEncryptedId') == null || component.get('v.cartEncryptedId') == '') {
                component.set('v.cartEncryptedId', cartEncryptedId);
            }

            if(component.get('v.cartId') == null || component.get('v.cartId') == '') {
                component.set('v.cartId', cartId);
            }

            // 2020-04-07  msobczak: added to get new cart name
            if(component.get('v.selectedObjectName') == null || component.get('v.selectedObjectName') == '') {
                var cartName = returnValue.cartName;
                component.set('v.selectedObjectName', cartName);
            }

            // Post the messages returned

            var cartItemsAdded = true;
            var cartItemsDeleted = true;
            var cartItemsUpdated = true;

            if('cartCreated' in returnValue) {
                if(returnValue.cartCreated == true) {
                    messages.push({'severity' : 'confirm', 'message' : returnValue.cartCreatedMsg});
                }
                else {
                    messages.push({'severity' : 'error', 'message' : returnValue.cartCreatedMsg});
                }
            }

            if('contactRetrieved' in returnValue) {
                if(returnValue.contactRetrieved == true) {
                    //messages.push({'severity' : 'confirm', 'message' : returnValue.contactRetrievedMsg});
                }
                else {
                    messages.push({'severity' : 'error', 'message' : returnValue.contactRetrievedMsg});
                }
            }

            if('cartItemsAdded' in returnValue) {
                cartItemsAdded = returnValue.cartItemsAdded;

                if('cartAddItemMsg' in returnValue) {
                    if(returnValue.cartItemsAdded == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.cartAddItemMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartAddItemMsg});
                    }
                }
            }

            if('cartItemsDeleted' in returnValue) {

                cartItemsDeleted = returnValue.cartItemsDeleted;

                if('cartDeleteItemMsg' in returnValue) {
                    if(returnValue.cartItemsDeleted == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.cartDeleteItemMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartDeleteItemMsg});
                    }
                }
            }

            if('cartItemsUpdated' in returnValue) {

                cartItemsUpdated = returnValue.cartItemsUpdated;

                if('cartItemUpdateMsg' in returnValue) {
                    if(returnValue.cartItemsUpdated == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.cartItemUpdateMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartItemUpdateMsg});
                    }
                }
            }

            // Only update the table when there are no errors.
            if(cartItemsAdded && cartItemsDeleted && cartItemsUpdated) {
                if(returnValue.cartItems) {
                    var orderItems = returnValue.cartItems;

                    console.log('orderItems = ' + JSON.stringify(orderItems));

                    // Reset the attribute that represents the cart
                    component.set("v.orderItems", orderItems);

                    // Reset the attributes used to store removals and item updates.
                    component.set("v.removeItems", {});
                    component.set("v.changeItems", {});
                }
            }

        }
        else {
            console.log('Failed with state: ' + state);
            messages.push({'severity' : 'error', 'message' : 'Cart Update failed with state: ' + state});
        }

        this.doneWaiting(component);

        component.set("v.pageMessages", messages);

    },
    validateOrderForm: function(component, orderItems) {
        var validationMessages = [];

        if(orderItems.length > 0) {
    
            var skuMap = {};

            for(var i = 0; i < orderItems.length; i++) {
                var orderItem = orderItems[i];

                if(orderItem.sku != null && orderItem.sku != '') {

                    if(orderItem.qty == null) {
                        validationMessages.push("Please enter a quantity for: " + orderItem.sku);
                    }
                    else if(orderItem.qty <= 0) {
                        validationMessages.push(orderItem.sku + " must have a quantity greater than zero");
                    }

                    if(orderItem.sku in skuMap) {
                        validationMessages.push("Duplicate item: " + orderItem.sku);
                    }
                    else {
                        skuMap[orderItem.sku] = orderItem.sku;
                    }
                }
            }

        }

        return validationMessages;
    },
    updateCartHelper: function(component, helper) {

        var userId = component.get('v.userId');
        var storefront = component.get('v.selectedStorefront');
        var currencyCode = component.get('v.currencyCode');

        var orderItems = component.get("v.orderItems");
        var cartEncryptedId = component.get("v.cartEncryptedId");
        var cartId = component.get("v.cartId");
        var storefront = component.get("v.selectedStorefront");
        var locale = component.get("v.locale");
        var accountId = component.get('v.accountId');

        var messages = [];

        component.set("v.pageMessages", messages);

        // Validate the contents of the cart
        // also done in helper.createCart()
        var validationMessages = helper.validateOrderForm(component, orderItems);

        if(validationMessages.length > 0) {
            for(var i = 0; i < validationMessages.length; i++) {
                messages.push({'severity' : 'error', 'message' : validationMessages[i]});
            }

            component.set("v.pageMessages", messages);

            return false;
        }

        var addItemsJson = null;
        var removeItemsJson = null;
        var updateItemsJson = null;

        // 1. Add items to cart
        if(orderItems.length > 0) {

            var addItems = [];
            for(var i = 0; i < orderItems.length; i++) {
                var orderItem = orderItems[i];

                if((orderItem.sku != null && orderItem.sku != '') && (orderItem.cart_item_sfid == null || orderItem.cart_item_sfid == '') && (orderItem.qty > 0)) {
                    addItems.push(orderItem);
                }
            }

            if(addItems.length > 0) {
                addItemsJson = JSON.stringify(addItems);
            }
        }

        // 2. Remove items from the cart
        var removeItems = component.get("v.removeItems");

        if(Object.keys(removeItems).length > 0) {
            removeItemsJson = JSON.stringify(removeItems);
        }

        // 3. Update items in the cart
        // TODO Need to take into account any removals.

        var changeItems = component.get("v.changeItems");

        if(Object.keys(changeItems).length > 0) {
            updateItemsJson = JSON.stringify(changeItems);
        }

        this.updateCartAddRemoveUpdate(component, userId, storefront, currencyCode, accountId, locale, cartId, addItemsJson, removeItemsJson, updateItemsJson);

    },
    hasNewItem: function(component) {

        var orderItems = component.get("v.orderItems");
        var newItemFound = false;

        for(var i = 0; i < orderItems.length; i++) {
            var orderItem = orderItems[i];

            if((orderItem.sku != null && orderItem.sku != '') && (orderItem.cart_item_sfid == null || orderItem.cart_item_sfid == '') && (orderItem.qty > 0)) {
                newItemFound = true;
                break;
            }
        }

        return newItemFound;
    },
    waiting: function(component) {
        component.set("v.showSpinner", true);
    },
    doneWaiting: function(component) {
        component.set("v.showSpinner", false);
    },

})