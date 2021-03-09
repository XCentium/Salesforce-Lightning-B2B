// noinspection BadExpressionStatementJS,JSUnusedGlobalSymbols
({
	afterScriptsLoaded : function(component) {

	    // Initialize local variables
        let recordId,
            $getCustomers;

        // Create a reference to the current record
        recordId = component.get('v.recordId');

        // Initialize the getCustomers method
        $getCustomers = component.get('c.getCustomers');

        // Seed the method arguments
        $getCustomers.setParams({objectId: recordId});

        // Define the callback to be executed
        $getCustomers.setCallback(this, function (response) {

            // Was a valid component / response provided?
            if(component.isValid() && response.getState() === 'SUCCESS') {

                // If so, set the customer-details via the responseValue
                component.set('v.customerDetails', response.getReturnValue());

                // Was a valid response returned?
                if (response.getReturnValue().length !== 0) {

                    // If so, then set the checkRecords flag
                    component.set('v.checkRecords', true);

                }

            } else {

                console.error(response);

            }

        });

        $A.enqueueAction($getCustomers);

    },

    openSyncCust : function(component) {

        // Initialize local variables
        let $syncCustomers,
            recordId,
            spinner;

	    // Set the processing status in the component
        component.set('v.syncstatus', 'Processing...');

        // Find and activate the spinner
        spinner = component.find('spnr');
        $A.util.toggleClass(spinner, 'slds-show', true);

        // Create a reference to the current record
        recordId = component.get('v.recordId');

        // Initialize the sync-method
        $syncCustomers = component.get('c.syncCustomer');
        $syncCustomers.setParams({objectId: recordId});

        // Define the callback to process after method execution
        $syncCustomers.setCallback(this, function (response) {

            // Was the request valid and successfully processed?
            if(component.isValid() && response.getState() === 'SUCCESS') {

                // Was a valid returnValue returned?
                if(response.getReturnValue() === true) {

                    // If so, remove the spinner and force a refresh of the view
                    $A.util.removeClass(spinner, 'slds-show');
                    $A.get('e.force:refreshView').fire();

                    // Call out that the profile has been successfully synch'd
                    component.set('v.syncstatus', 'Synchronized');

                } else {

                    // Otherwise, explain that no data was retrieved
                    component.set('v.syncstatus', 'No data retrieved');

                }

            } else {

                // Audit that an error was caught
                console.error(response);

                // Remove the spinner and update the status message
                $A.util.removeClass(spinner, 'slds-show');
                component.set('v.syncstatus', 'Failed with error');

            }

        });

        $A.enqueueAction($syncCustomers);

	}

});