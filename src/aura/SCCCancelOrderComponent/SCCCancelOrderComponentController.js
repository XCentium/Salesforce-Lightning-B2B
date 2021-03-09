// noinspection BadExpressionStatementJS,JSUnusedGlobalSymbols,JSUnusedGlobalSymbols,JSUnusedGlobalSymbols
({
    afterScriptsLoaded : function(component) {

        // Initialize local variables
        let recordId,
            $checkOrderStatus;

        // Retrieve the order recordId
        recordId = component.get('v.recordId');

        // Initialize the method reference
        $checkOrderStatus = component.get('c.checkOrderStatus');
        $checkOrderStatus.setParams({orderId: recordId});

        // Define the post-processing callback to execute
        $checkOrderStatus.setCallback(this, function (response) {

            // Was the request processed successfully?
            if (component.isValid() && response.getState() === 'SUCCESS') {

                // If so, then record the cancel-status
                component.set('v.checkRecords', response.getReturnValue());

            } else {

                // Otherwise, audit the error-message
                console.error(response);

            }

        });
        $A.enqueueAction($checkOrderStatus);

    },

    openCancelOrder : function(component, event, helper) {

        // Initialize local variables
        let recordId,
            $cancelOrder;

        // Create a reference to the order being cancelled
        recordId = component.get('v.recordId');

        // Create a reference to the cancellation method
        $cancelOrder = component.get('c.cancelledOrder');
        $cancelOrder.setParams({orderId: recordId});

        // Define the callback to execute post-processing
        $cancelOrder.setCallback(this, function (response) {

            // Was the request processing successful / did we get a valid response
            if (component.isValid() && response.getState() === 'SUCCESS') {

                // Was the order successfully cancelled?
				if (response.getReturnValue() === true) {

				    // Inform the user that the order was cancelled successfully
                    helper.toastToDisplay('Success','Order has been successfully cancelled!!');

                } else {

				    // Otherwise, inform the user that the order was not cancelled; and may already be cancelled
                    helper.toastToDisplay('Warning','Order has been already cancelled!!');

                }

				// Refresh the order view whenever the cancel button returns a success-status
                $A.get('e.force:refreshView').fire();

            } else {

                // Audit any error or exception caught during processing
                helper.toastToDisplay('Error','Unexpected error. Please contact system administrative!!!');
                console.error(response);

            }

        });

        $A.enqueueAction($cancelOrder);

    },

    hidePopup: function(component, event, helper){
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
        $A.get('e.force:refreshView').fire();
    },

    openPopup :  function(component, event, helper){
        //called on clicking your button
        //run your form render code after that, run the following lines
        helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component,'backdrop','slds-backdrop--');
    }

});