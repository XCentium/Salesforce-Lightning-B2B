({
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
    waiting: function(component) {
        component.set("v.showSpinner", true);
    },
    doneWaiting: function(component) {
        component.set("v.showSpinner", false);
    },
})