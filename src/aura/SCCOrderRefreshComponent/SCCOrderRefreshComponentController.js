// noinspection BadExpressionStatementJS,JSUnusedGlobalSymbols
({
    afterScriptsLoaded : function(component) {

        // Initialize local variables
        let $getOrders;

        // Initialize a reference to the getOrders method
        $getOrders = component.get("c.getOrders");
        $getOrders.setParams({ orderId : component.get("v.recordId") });

        // Setup the callback to execute post-processing
        $getOrders.setCallback(this, function(response) {

            // Is the component valid and was processing successful?
            if (component.isValid() && response.getState() === "SUCCESS") {

                // Was a return-value provided?
                if (response.getReturnValue().length !== 0) {
                    component.set("v.checkRecords", true);
                }

                // Set the order-record details
                component.set("v.orders",response.getReturnValue());

            }

        });

    	$A.enqueueAction($getOrders);

    },

	handleClick : function(component) {

        // Initialize local variables
        let spinner,
            recordId,
            $syncOrder;

        // Create a reference to the current record
        recordId = component.get("v.recordId");

        // Set the processing status in the component
        component.set('v.syncstatus', 'Processing...');

        // Toggle the spinner display
        spinner = component.find("spnr");
        $A.util.toggleClass(spinner, "slds-show", true);

        // Create a reference to the sync-order method
        $syncOrder = component.get('c.syncOrder');
        $syncOrder.setParams({ orderId : recordId });

        // Define the callback to execute post method-processing
        $syncOrder.setCallback(this, function (response) {

            // Was a valid response provided by the sync-order method?
            if (component.isValid() && response.getState() === 'SUCCESS') {

                // Was the valid return-value provided?
                if (response.getReturnValue() === true) {

                    // If so, remove the spinner and refresh the display
                    $A.util.removeClass(spinner, "slds-show");
                    $A.get('e.force:refreshView').fire();

                    // Call out that the order has been successfully synch'd
                    component.set('v.syncstatus', 'Synchronised');

                } else {

                    // If so, remove the spinner and update the status
                    $A.util.removeClass(spinner, "slds-show");
                    component.set('v.syncstatus', 'No data retrieved');

                }

            } else {

                // Audit than an error was caught
                console.error(response);

                // Otherwise, explain that no data was retrieved
                $A.util.removeClass(spinner, "slds-show");
                component.set('v.syncstatus', 'Failed with error');

            }

        });

        $A.enqueueAction($syncOrder);

	}

});