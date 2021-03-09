/**
 * Created by msobczak on 11/27/2018.
 */
({
    startCheckout: function(component, userId, storefront, currencyCode, accountId, locale, cartId, cartEncryptedId) {

        console.log('inside startCheckout()');

        var action = component.get("c.updateCartForCheckout");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "currencyCode" : currencyCode,
            "accountId" : accountId,
            "locale" : locale,
            "cartId" : cartId,
            "cartEncryptedId" : cartEncryptedId

        });

        action.setCallback(this, function (response) {

            var messages = [];

            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if('ShippingAddressesFound' in returnValue) {
                    if(returnValue.ShippingAddressesFound == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.ShippingDefaultAddressMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.ShippingDefaultAddressMsg});
                    }
                }

                if('BillingAddressesFound' in returnValue) {
                    if(returnValue.BillingAddressesFound == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.BillingDefaultAddressMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.BillingDefaultAddressMsg});
                    }
                }

                if('cartItemGroupCreated' in returnValue) {
                    if(returnValue.cartItemGroupCreated == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.cartItemGroupCreatedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartItemGroupCreatedMsg});
                    }
                }

                if('cartHeaderRevised' in returnValue) {
                    if(returnValue.cartHeaderRevised == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.cartHeaderRevisedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartHeaderRevisedMsg});
                    }
                }

                if('cartItemGroupUpdated' in returnValue) {
                    if(returnValue.cartItemGroupUpdated == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.cartItemGroupUpdatedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.cartItemGroupUpdatedMsg});
                    }
                }

                if('paymentMethodsRetrieved' in returnValue) {
                    if(returnValue.paymentMethodsRetrieved == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.paymentMethodsRetrievedMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.paymentMethodsRetrievedMsg});
                    }
                }

                if('checkoutLoadSuccessful' in returnValue) {
                    if(returnValue.checkoutLoadSuccessful == true) {
                        //messages.push({'severity' : 'confirm', 'message' : returnValue.checkoutLoadMsg});
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.checkoutLoadMsg});
                    }
                }

                var validationMessages = [];

                // This will contain a value if there were cart validation errors
                if('cartValidationMessages' in returnValue) {

                    validationMessages = JSON.parse(returnValue.cartValidationMessages);

                    for(var i = 0; i < validationMessages.length; i++) {
                        if(validationMessages[i].severity == 'INFO') {
                            messages.push({'severity' : 'info', 'message' : validationMessages[i].message});
                        }

                        if(validationMessages[i].severity == 'ERROR') {
                            messages.push({'severity' : 'error', 'message' : validationMessages[i].message});
                        }
                    }

                }

                if('ShippingDefaultAddress' in returnValue) {
                    var shippingAddress = returnValue.ShippingDefaultAddress;
                    component.set("v.selectedShippingAddress", shippingAddress);
                }

                if('BillingDefaultAddress' in returnValue) {
                    var billingAddress = returnValue.BillingDefaultAddress;
                    component.set("v.selectedBillingAddress", billingAddress);
                }

                if('paymentMethodsRetrieved' in returnValue) {
                    var paymentOptions = [];
                    var paymentMethodMap = {};

                    var storedPaymentList = returnValue.storedPaymentList;

                    for(var i = 0; i < storedPaymentList.length; i++) {
                        var paymentOption = {};
                        paymentOption.label = storedPaymentList[i].accountType + ': ' + storedPaymentList[i].accountNumber;
                        paymentOption.value = storedPaymentList[i].sfid;
                        paymentOptions.push(paymentOption);

                        paymentMethodMap[storedPaymentList[i].sfid] = storedPaymentList[i];
                    }

                    component.set("v.paymentOptions", paymentOptions);
                    component.set("v.paymentMethodMap", paymentMethodMap);

                    var cartItemGroupShipToId = returnValue.cartItemGroupShipToId;  console.log('cartItemGroupShipToId = ' + cartItemGroupShipToId);
                    var shippingDefaultAddressId = returnValue.ShippingDefaultAddressId;  console.log('shippingDefaultAddressId = ' + shippingDefaultAddressId);

                }

                if('totalAmount' in returnValue) {
                    component.set("v.totalAmount", returnValue.totalAmount);
                }

                if('totalQuantity' in returnValue) {
                    component.set("v.totalQuantity", returnValue.totalQuantity);
                }

                if('cartValidated' in returnValue) {
                    component.set("v.cartValidated", returnValue.cartValidated);
                }


                if(component.get("v.cartValidated") == false) {
                    for(var i = 0; i < validationMessages.length; i++) {

                        if(validationMessages[i].severity == 'INFO') {
                            var msg = validationMessages[i].message.toLowerCase();

                            if(msg.includes('please') && msg.includes('request') && msg.includes('quote')){
                                component.set("v.quoteRequired", true);
                                //var createQuoteMsg = "<a href='/one/one.app?#/ccrz__E_Cart__c/" + component.get("v.cartId") + "/view' target='_blank'>Click here to open the cart record</a>";
                                //messages.push({'severity' : 'info', 'message' : createQuoteMsg});
                            }
                        }
                    }
                }

            }
            else {
                console.log('Failed with state: ' + state);
                messages.push({'severity' : 'error', 'message' : 'Cart Update failed with state: ' + state});
            }

            // 2019-02-28  msobczak: don't let user resubmit a Closed cart.
            var cartStatus = component.get("v.cartStatus");
            if(cartStatus != null && cartStatus == 'Closed') {
                component.set("v.orderProcessed", true);
                messages.push({'severity' : 'error', 'message' : 'This cart is Closed. An order has already been placed for it.'});
            }

            component.set("v.pageMessages", messages);
        });

        $A.enqueueAction(action);

    },
    submitOrder: function(component) {

        console.log('inside submitOrder()');

        var messages = [];

        component.set("v.pageMessages", messages);

        component.set("v.orderProcessed", true);

        var orderPlaced = false;
        var orderId = null;

        var userId = component.get("v.userId");
        var storefront = component.get("v.selectedStorefront");
        var cartId = component.get('v.cartId');
        var selectedPaymentOption = component.get('v.selectedPaymentOption');
        var paymentMethodMap = component.get('v.paymentMethodMap');

        var paymentMethodObj = paymentMethodMap[selectedPaymentOption];
        var temp = [];
        temp.push(paymentMethodObj);

        var jsonPaymentInfo = JSON.stringify(temp);

        var action = component.get("c.createOrder");

        action.setParams({
            "userId" : userId,
            "storefront" : storefront,
            "cartId" : cartId,
            "jsonPaymentInfo" : jsonPaymentInfo
        });

        action.setCallback(this, function (response) {

            var state = response.getState();

            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();

                if('orderPlaced' in returnValue) {
                    if(returnValue.orderPlaced == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.orderPlacedMsg});
                        orderPlaced = true;
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.orderPlacedMsg});
                    }
                }

                // order is retrieved after it has been placed.
                if('orderRetrieved' in returnValue) {
                    if(returnValue.orderRetrieved == true) {
                        messages.push({'severity' : 'confirm', 'message' : returnValue.orderRetrievedMsg});
                        orderPlaced = true;
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.orderRetrievedMsg});
                    }
                }

                if('orderId' in returnValue) {
                    orderId = returnValue.orderId;
                }

            }
            else {
                console.log('Failed with state: ' + state);
                messages.push({'severity' : 'error', 'message' : 'Place order failed with state: ' + state});
            }

            console.log('orderPlaced = ' + orderPlaced);
            console.log('orderId = ' + orderId);

            component.set("v.orderPlaced", orderPlaced);
            component.set("v.pageMessages", messages);
            component.set("v.orderId", orderId);
        });

        $A.enqueueAction(action);

    }
})