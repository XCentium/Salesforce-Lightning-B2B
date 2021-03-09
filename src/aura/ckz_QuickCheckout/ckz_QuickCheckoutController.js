({
    doInit: function(component, event, helper) {
        console.log('ckz_QuickCheckout - begin init()');

        var userId = component.get('v.userId');
        var locale = component.get('v.locale');
        var selectedStorefront = component.get('v.selectedStorefront');
        var currencyCode = component.get('v.currencyCode');
        var cartId = component.get('v.cartId');
        var cartEncryptedId = component.get('v.cartEncryptedId');
        var accountId = component.get('v.accountId');

        // 2019-09-20  msobczak: added
        var useCardLayout = component.get("v.useCardLayout");
        console.log("useCardLayout = " + useCardLayout);

        console.log('userId = ' + userId);
        console.log('locale = ' + locale);
        console.log('selectedStorefront = ' + selectedStorefront);
        console.log('cartId = ' + cartId);
        console.log('cartEncryptedId = ' + cartEncryptedId);
        console.log('accountId = ' + accountId);

        helper.startCheckout(component, userId, selectedStorefront, currencyCode, accountId, locale, cartId, cartEncryptedId);

        console.log('ckz_QuickCheckout - exit init()');

    },
    handleSubmitOrder: function(component, event, helper) {
        helper.submitOrder(component);
    },
    waiting: function(component, event, helper) {
        component.set("v.HideSpinner", true);
    },
    doneWaiting: function(component, event, helper) {
        component.set("v.HideSpinner", false);
    },
    handleNavigateFinish: function(component, event, helper) {

        var isValid = false;

         var messages = [];

         component.set("v.pageMessages", messages);

         var orderProcessed = component.get("v.orderProcessed");

         if(orderProcessed)
         {
             isValid = true;
         }
         else {
             messages.push({'severity' : 'error', 'message' : "Please click [Place Order] to submit your order" });
         }

         if(messages.length == 0) {
             isValid = true;
         }
         else {
             component.set("v.pageMessages", messages);
             // for Display Model,set the "isOpen" attribute to "true"
             component.set("v.isOpen", true);
         }

         if(isValid) {
             var navigate = component.get("v.navigateFlow");
             navigate("FINISH");
         }

     },
     handleQuickCheckoutDialogEvent: function(component, event, handler) {

         var action = event.getParam("action");

         if(action == "FINISH") {
            var navigate = component.get("v.navigateFlow");
            navigate(action);
        }
     },
     handleNavigatePrev: function(component, event, helper) {

         var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        event.setParam("type", "c:ckz_OrderFormDataEntry");
        event.setParam("attributes", attrs);

        event.fire();

     },
   handleNavigateStartOver: function(component, event, helper) {

       var attrs = util.createAttrsObj(component);

        var event = component.getEvent("renderPanel");

        event.setParam("type", "c:ckz_OrderFormStart");
        event.setParam("attributes", attrs);

        event.fire();

   }
})