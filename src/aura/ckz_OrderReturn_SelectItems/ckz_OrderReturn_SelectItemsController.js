({
    doInit: function(component, event, helper) {

        // Figure out which buttons to display
        var availableActions = component.get('v.availableActions');
        for (var i = 0; i < availableActions.length; i++) {
            if (availableActions[i] == "PAUSE") {
                component.set("v.canPause", true);
            } else if (availableActions[i] == "BACK") {
                component.set("v.canBack", true);
            } else if (availableActions[i] == "NEXT") {
                component.set("v.canNext", true);
            } else if (availableActions[i] == "FINISH") {
                component.set("v.canFinish", true);
            }
        }

        var recordId = component.get("v.recordId");

        console.log('recordId = ' + recordId);

        var orderRecords = component.get("v.orderRecords");
        var orderObj = null;

        if(orderRecords.length > 0) {
            orderObj = orderRecords[0];
            component.set("v.orderObj", orderObj);
        }

        // convert selected items String back to a List
        var selectedItemsList = [];

        var temp = component.get("v.selectedItemsString");

        if(temp != '') {
            selectedItemsList = JSON.parse(temp);
            component.set("v.selectedItemsList", selectedItemsList);
        }

        // Convert selected items list to a map, to use when determining which items were selected previously
        var selectedItemsMap = {};

        for(var i = 0; i < selectedItemsList.length; i++) {
            var orderItem = selectedItemsList[i];
            selectedItemsMap[orderItem.Id] = orderItem;
        }

        component.set("v.selectedItemsMap", selectedItemsMap);

        helper.processItems(component);

    },

    handleNavigatePrev: function (component, event, helper) {

        var navigate = component.get("v.navigateFlow");

        navigate("BACK");

    },
    handleNavigateNext: function (component, event, helper) {

        var messages = [];

        component.set("v.pageMessages", messages);

        var selectedItemsString = '';

        var orderItemRecords = component.get("v.orderItemRecords");

        var selectedItemsList = [];

        var validForm = false;

        for(var i = 0; i < orderItemRecords.length; i++) {
            var orderItem = orderItemRecords[i];

            if(orderItem.selected) {
                if(orderItem.returnQty && orderItem.returnQty != "" && orderItem.returnQty != "0") {
                    selectedItemsList.push(orderItem);
                }
                else {
                    messages.push({'severity' : 'error', 'message' : 'Item being returned (' + orderItem.SKU__c + ') must have a return quantity greater than zero.'});
                }
            }
        }

        var totItems = selectedItemsList.length;

        if(totItems > 0) {
            validForm = true;
        }
        else {
            messages.push({'severity' : 'error', 'message' : 'Please select at least one item for return'});

            component.set("v.pageMessages", messages);

            return false;
        }

        var selectedItemsString = JSON.stringify(selectedItemsList);

        component.set("v.selectedItemsString", selectedItemsString);

        // If we pass error checking, do some real work
        if(validForm){
            var navigate = component.get("v.navigateFlow");

            navigate("NEXT");
        }

    },
});