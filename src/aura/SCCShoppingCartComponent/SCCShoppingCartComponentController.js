// noinspection BadExpressionStatementJS,BadExpressionStatementJS,JSUnusedGlobalSymbols,JSUnusedGlobalSymbols,JSUnusedGlobalSymbols
({

    afterScriptsLoaded : function(component) {

        // Initialize local variables
        let recordId,
            objectName,
            responseObj,
            $initComponent,
            $getStoreSessionUrl,
            $getStoreFrontURL;

        // Reference the object id and name
        recordId = component.get('v.recordId');
        objectName = component.get('v.sObjectName');

        // Create a reference to the init-method
        $initComponent = component.get('c.initComponent');

        // Seed the method properties with the component values
        $initComponent.setParams({recordId: recordId, objectName: objectName});

        // Set the callback and invoke the get-url methods
        $initComponent.setCallback(this, function (response) {

            // Was the invoked component valid and return a valid response?
            if (component.isValid() && response.getState() === 'SUCCESS') {

                // Parse the response-object and capture the site identifiers
                /** @typeof responseObj **/
                responseObj = JSON.parse(response.getReturnValue());

                // Cache the site identifiers in the aura component
                component.set('v.siteId', responseObj.siteId);
                // noinspection JSUnresolvedVariable
                component.set('v.customerListId', responseObj.customerListId);
                component.set('v.customerId', responseObj.customerId);

                // Initialize the getStoreSession url function
                $getStoreSessionUrl = component.get('c.getStoreSessionURL');

                // Seed the method properties with the component values
                $getStoreSessionUrl.setParams({siteId: component.get('v.siteId')});

                // Invoke the method to retrieve the store-session url
                $getStoreSessionUrl.setCallback(this, function (response) {

                    // Is the component value and the response state valid?
                    if(component.isValid() && response.getState() === 'SUCCESS') {

                        // If so, write the store session url
                        component.set('v.storeSessionURL', response.getReturnValue());

                        // Initialize the getStoreFrontUrl function
                        $getStoreFrontURL = component.get('c.getStoreFrontURL');

                        // Seed the method properties with the component values
                        $getStoreFrontURL.setParams({siteId: component.get('v.siteId')});

                        // Invoke the method to retrieve the store-session url
                        $getStoreFrontURL.setCallback(this, function (response) {

                            // Is the component value and the response state valid?
                            if (component.isValid() && response.getState() === 'SUCCESS') {

                                // If so, write the store front url
                                component.set('v.storeFrontURL', response.getReturnValue());

                            }

                        });

                        // Invoke the store-session method
                        $A.enqueueAction($getStoreFrontURL);

                    }

                });

                // Invoke the store-session method
                $A.enqueueAction($getStoreSessionUrl);

            }

        });

       $A.enqueueAction($initComponent);

    },

    openShoppingCart : function(component) {

        // Enable the spinner
        component.set("v.Spinner", true);

        // Initialize local variables
        let siteId,
            customerId,
            sessionURL,
            storefrontURL,
            $getAccessToken,
            token;

        // Create references to the individual properties
        siteId = component.get('v.siteId');
        customerId = component.get('v.customerId');
        sessionURL = component.get('v.storeSessionURL');
        storefrontURL = component.get('v.storeFrontURL');

        // Prepare the getAccessToken function
        $getAccessToken = component.get('c.getAccessToken');
        $getAccessToken.setParams({siteId: siteId, customerId: customerId});
        $getAccessToken.setCallback(this, function (response) {

            // Create a reference to the token value
            token = response.getReturnValue();

            // Was a valid token returned and are the session / storefront urls defined?
            if (component.isValid() && response.getState() === 'SUCCESS' && sessionURL && storefrontURL) {

				// Create the jQuery request to launch the shopping session
                // noinspection JSUnresolvedVariable
                let $j = jQuery.noConflict();
                $j.ajax({

                    type: 'POST',
                    url: sessionURL,
                    headers: {
                        'Authorization': token,
                    },

                    dataType: 'json',
                    data: {},
                    xhrFields: {
                        withCredentials: true
                    },

                    success: function() {

                        // Open the storefront URL in a new window
                        component.set('v.Spinner', false);
                        window.open(storefrontURL);

                    },

                    error: function() {
                        component.set('v.Spinner', false);
                        alert('Cannot Load Storefront, Please Contact Administrator');
                    }

                });

      		} else {

                component.set('v.Spinner', false);
                console.error(response);

            }

        });

        // Invoke the method to get the access token
        $A.enqueueAction($getAccessToken);

    },

    // this function automatic call by aura:waiting event
    showSpinner: function(component) {
       	// make Spinner attribute true for display loading spinner
        component.set('v.Spinner', true);
   	},

 	// this function automatic call by aura:doneWaiting event
    hideSpinner : function(component) {
     	// make Spinner attribute to false for hide loading spinner
       	component.set('v.Spinner', false);
    }
});