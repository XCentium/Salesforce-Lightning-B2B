({
    doInit: function(component, event, helper) {

        console.log('ckz_RetrievedOrderDetail - begin init()');

        // 2019-09-20  msobczak: added
        var useCardLayout = component.get("v.useCardLayout");
        console.log("useCardLayout = " + useCardLayout);

        var childOrder = component.get("v.childOrder");
        var orderItemsList = childOrder.orderItemsList;

        for(var i = 0; i < orderItemsList.length; i++) {
            var orderItem = orderItemsList[i];
            if(orderItem.productType != 'Product') {
                component.set("v.isValid", false);
                break;
            }
        }

        console.log('ckz_RetrievedOrderDetail - exit init()');
    },
    selectOrder: function(component, event, helper) {
        console.log('inside selectOrder');

        var selectedItem = event.currentTarget;
        var orderName = component.get('v.currentOrderName');
        var orderId = component.get('v.currentOrderId');

        console.log('orderName = ' + orderName);
        console.log('orderId = ' + orderId);

        //component.set('v.selectedOrder', orderName);
        //component.set('v.selectedOrderId', orderId);

        var event = component.getEvent("startingObjectSelected");

        event.setParam("objectType", "order");
        event.setParam("objectName", orderName);
        event.setParam("objectId", orderId);
        event.setParam("cartEncryptedId", "");

        event.fire();

    },
    handleGotoDataEntry: function(component, event, helper) {
        var event = component.getEvent("gotoDataEntry");

        event.setParam("screen", "ckz_OrderFormDataEntry");

        event.fire();
    }
})