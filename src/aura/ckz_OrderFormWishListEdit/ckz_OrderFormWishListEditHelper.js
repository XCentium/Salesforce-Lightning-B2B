({
    addMoreOrderItems: function(component) {

        console.log('inside addMoreOrderItems');

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

        orderItem.qty = 1;
        orderItem.orig_qty = 1;

        return orderItem;
    },
    getWishList: function(component, userId, storefront, currencyCode, accountId, locale, wishListId) {

        console.log('inside getWishList()');

        component.set("v.pageMessages", []);

        var action = component.get("c.fetchWishList");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "wishListId" : wishListId
        });

        this.waiting(component);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                console.log('getWishList() returnValue = ' + JSON.stringify(returnValue));

                if(returnValue.orderItems) {

                    for(var i = 0; i < returnValue.orderItems.length; i++) {
                        var orderItem = returnValue.orderItems[i];

                        orderItem.productData.shortDesc = util.decodeHtml(orderItem.productData.shortDesc);
                    }

                    component.set('v.orderItems', returnValue.orderItems);
                }

                if(returnValue.wishListName) {
                    component.set('v.wishListName', returnValue.wishListName);
                }

                if(returnValue.wishListName) {
                    component.set("v.wishListNameOrig", returnValue.wishListName);
                }

                var messages = [];

                component.set("v.pageMessages", messages);

            }
            else {
                console.log('Failed with state: ' + state);
            }

            this.doneWaiting(component);
        });

        $A.enqueueAction(action);

    },

    createWishList: function(component) {

        console.log('inside createWishList()');

        var messages = [];

        component.set("v.pageMessages", messages);

        var userId = component.get('v.userId');
        var contactId = component.get('v.contactId');
        var storefront = component.get('v.selectedStorefront');
        var currencyCode = component.get('v.currencyCode');
        var orderItems = component.get("v.orderItems");
        var wishListId = component.get("v.cartId");
        var locale = component.get('v.locale');
        var accountId = component.get('v.accountId');
        var wishListName = component.get("v.wishListName");

        // Validate the contents of the cart
        // also done in helper.updateWishListHelper()
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

        if(wishListId == null || wishListId == "") {
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

            messages.push({'severity' : 'warning', 'message' : 'Wish List contains no items.  Please add an item.'});
            component.set("v.pageMessages", messages);

        }

        if(messages.length > 0) {
            return;
        }

        messages.push({'severity' : 'info', 'message' : "Please wait while the wish list is being created..."});

        component.set("v.pageMessages", messages);

        var action = component.get("c.fetchNewWishList");

        action.setParams({
            "wishListName" : wishListName,
            "userId" : userId,
            "contactId" : contactId,
            "locale" : locale,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "itemsJson" : itemsJson
        });

        this.waiting(component);

        action.setCallback(this, response => this.updateOrderItems(component, response));

        $A.enqueueAction(action);

    },
    updateWishListAddRemoveUpdate: function(component, wishListName, userId, storefront, currencyCode, accountId, locale, wishListId, addItemsJson, removeItemsJson) {

        console.log('inside updateWishListAddRemoveUpdate()');

        var action = component.get("c.fetchUpdatedWishList");

        action.setParams({
            "wishListName" : wishListName,
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "wishListId" : wishListId,
            "addItemsJson" : addItemsJson,
            "removeItemsJson" : removeItemsJson
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

            component.set("v.orderType", "wish");

            var wishListId = returnValue.wishListId;

            if(component.get('v.cartId') == null || component.get('v.cartId') == '') {
                component.set('v.cartId', wishListId);
            }

            var wishListName = returnValue.wishListName;
            component.set('v.wishListName', wishListName);
            component.set('v.wishListNameOrig', wishListName);

            // Post the messages returned

            var wishListItemsAdded = true;
            var wishListItemsDeleted = true;
            var wishListRevised = true;

            if('wishListCreated' in returnValue) {
                if(returnValue.wishListCreated == true) {
                    messages.push({'severity' : 'confirm', 'message' : returnValue.wishListCreatedMsg});
                }
                else {
                    messages.push({'severity' : 'error', 'message' : returnValue.wishListCreatedMsg});
                }
            }

            if('wishListRevised' in returnValue) {

                wishListRevised = returnValue.wishListRevised;

                if('wishListRevisedMsg' in returnValue) {
                    if(returnValue.wishListRevised == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.wishListRevisedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.wishListRevisedMsg});
                    }
                }
            }

            if('wishListItemsAdded' in returnValue) {
                wishListItemsAdded = returnValue.wishListItemsAdded;

                if('wishListItemsAddedMsg' in returnValue) {
                    if(returnValue.wishListItemsAdded == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.wishListItemsAddedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.wishListItemsAddedMsg});
                    }
                }
            }

            if('wishListItemsDeleted' in returnValue) {

                wishListItemsDeleted = returnValue.wishListItemsDeleted;

                if('wishListItemsDeletedMsg' in returnValue) {
                    if(returnValue.wishListItemsDeleted == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.wishListItemsDeletedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.wishListItemsDeletedMsg});
                    }
                }
            }

            // Only update the table when there are no errors.
            if(wishListItemsAdded && wishListItemsDeleted) {
                if(returnValue.orderItems) {
                    var orderItems = returnValue.orderItems;

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
            messages.push({'severity' : 'error', 'message' : 'Update failed with state: ' + state});
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
    updateWishListHelper: function(component, helper) {

        var userId = component.get('v.userId');
        var storefront = component.get('v.selectedStorefront');
        var currencyCode = component.get('v.currencyCode');

        var orderItems = component.get("v.orderItems");
        var cartEncryptedId = component.get("v.cartEncryptedId");
        var wishListId = component.get("v.cartId");
        var storefront = component.get("v.selectedStorefront");
        var locale = component.get("v.locale");
        var accountId = component.get('v.accountId');

        var wishListName = component.get("v.wishListName");
        var wishListNameOrig = component.get("v.wishListNameOrig");

        // Only send through the name if it has changed.
        var wishListNameUpd = (wishListName == wishListNameOrig ? null : wishListName);

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

        this.updateWishListAddRemoveUpdate(component, wishListNameUpd, userId, storefront, currencyCode, accountId, locale, wishListId, addItemsJson, removeItemsJson);

    },
    hasNewItem: function(component) {

        var orderItems = component.get("v.orderItems");
        var newItemFound = false;

        if(orderItems) {

            for(var i = 0; i < orderItems.length; i++) {
                var orderItem = orderItems[i];

                if((orderItem.sku != null && orderItem.sku != '') && (orderItem.cart_item_sfid == null || orderItem.cart_item_sfid == '') && (orderItem.qty > 0)) {
                    newItemFound = true;
                    break;
                }
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