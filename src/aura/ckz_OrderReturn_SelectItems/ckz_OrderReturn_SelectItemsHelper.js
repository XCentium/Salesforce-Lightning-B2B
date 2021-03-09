({
    processItems: function(component) {

        console.log('inside processItems');

        var selectedItemsMap = component.get("v.selectedItemsMap");

        var orderItemRecords = component.get("v.orderItemRecords");

        for(var i = 0; i < orderItemRecords.length; i++) {

            var orderItem = orderItemRecords[i];

            if(selectedItemsMap[orderItem.Id]) {
                var savedOrderItem = selectedItemsMap[orderItem.Id];
                orderItemRecords[i].selected = savedOrderItem.selected;
                orderItemRecords[i].returnQty = savedOrderItem.returnQty;
            }
            else {
                orderItemRecords[i].selected = false;
                orderItemRecords[i].returnQty = orderItem.ccrz__Quantity__c;
            }

        }

        component.set("v.orderItemRecords", orderItemRecords);

    },
});