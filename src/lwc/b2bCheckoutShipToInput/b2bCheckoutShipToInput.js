import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import COMMUNITYID from "@salesforce/community/Id";

import fetchInitValues from "@salesforce/apex/B2B_SPC_ComponentController.fetchInitValues";
import getAddressInfo from "@salesforce/apex/B2B_SPC_ComponentController.getAddressInfo";
import setCartDeliveryGroupShipToAddress from "@salesforce/apex/B2B_SPC_ComponentController.setCartDeliveryGroupShipToAddress";

export default class B2bCheckoutShipToInput extends LightningElement {

    // Custom Labels
    labels = {
        toast: {
            processingErrorTitle: 'Processing Error'
        },
        component: {

            altPleaseWait: 'Please wait...'
        }
    };

    @api effectiveAccountId;
    @api cartId;
    //@api webstoreId;

    // User entered
    @api shippingContactPointAddressId;
    @api shippingInstructions;

    // To be displayed in a radio button group
    addresses = [];
    defaultAddress;
    selectedAddress;


    // Component display options
    showDeliveryInstructions;
    showShippingAddresses;
    makeComponentReadOnly;

    communityId = COMMUNITYID;

    //@track showLoadingSpinner = false;

    connectedCallback() {
        console.log("B2bCheckoutShipToInput: connectedCallback()");
        console.log("effectiveAccountId: ", this.effectiveAccountId);
        //console.log("cartId", this.cartId);

        // this.loadAddresses();

        // if(this.effectiveAccountId === undefined || this.cartId === undefined) {
        //     this.doInit();
        // }
        // else {
        //     this.loadAddresses();
        // }

        // We need the cartId so that when we default the address on the cart delivery group, tax can be calculated.
        this.doInit();

    }

    doInit() {
        fetchInitValues({
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId,
            cartId: this.cartId
        })
            .then((result) => {
                console.log('B2bCheckoutShipToInput result: ' + JSON.stringify(result));
                if (result) {
                    //this.webstoreId = result.webstoreId;
                    this.effectiveAccountId = result.effectiveAccountId;
                    this.cartId = result.cartId;

                    if(this.effectiveAccountId) {
                        this.loadAddresses();
                    }
                }
            })
            .catch((error) => {
                console.log("error from doInit()");
                console.log(error);
                //this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.toast.processingErrorTitle,
                        message: error.message,
                        variant: "error"
                    })
                );
            });
    }

    loadAddresses() {

        console.log("loadAddresses() begin");

        getAddressInfo({
            effectiveAccountId: this.effectiveAccountId,
            isShipping: true,
            isBilling: false
            })
            .then((result) => {
                this.processResult(result);
            })
            .catch((error) => {
                this.processError(error);
            });

    }

    processResult(result) {
        //this.showLoadingSpinner = false;

        if (result) {
            console.log("processResult():" + JSON.stringify(result));

            this.processResults(result);
        }

        this.processMessages(result);
    }

    processResults(result) {
        // console.log("productResults()", productResults);
        if(result.addresses && result.addresses.length > 0) {
            this.addresses = result.addresses;
        }

        let id;

        if(result.defaultAddress) {
            id = result.defaultAddress;
        }
        else {
            if(this.addresses.length > 0) {
                id = this.addresses[0].Id;
            }

        }

        this.defaultAddress = id;
        this.selectedAddress = id;
        // this.shippingContactPointAddressId = id;

        // const customEvent = new CustomEvent('shippingaddresschange', {
        //     detail : id, bubbles : true, composed: true
        // });

        // this.dispatchEvent(customEvent);

        // The account may have a default ContactPointAddress defined.
        // When that is the case, the user will see that address selected in the component.
        // That results in the user seeing no sales tax calculated.
        // An option would be for the parent component to call the child to set the default.
        // The other option would be to force an update to the CartDeliveryGroup upon component load.
        // Currently the Apex method does not identify what address has been selected before.
        // The workaround here is to force an update to the CartDeliveryGroup when the component is loaded.

        // This will ensure that the CartDeliveryGroup has an address from the beginning
        // and that sales tax will be a value other than zero.
        // This doesn't work because initially, this component doesn't have the cartId
        // Retrieving the addresses only requires the effectiveAccountId.
        // this.updateCartDeliveryGroupShipToAddress(id);

        console.log('B2bCheckoutShipToInput - processResults()');
        console.log('selectedAddress: ' + this.selectedAddress);

        // const customEvent = new CustomEvent('cartdeliverygroupshiptocheck', {
        //     detail : id, bubbles : true, composed: true
        // });

        // this.dispatchEvent(customEvent);

        this.setCartDeliveryGroupDefaultAddress();

    }

    get options() {

        let addressOptions = [];

        for(let i = 0; i < this.addresses.length; i++) {

            const addr = this.addresses[i];
            let opt = {};
            opt.label = addr.Address.street + ', ' + addr.Address.city + ', ' + addr.Address.state + ', ' + addr.Address.postalCode + ' ' + addr.Address.country;
            opt.value = addr.Id;

            addressOptions.push(opt);
        }

        return addressOptions;
    }

    processError(error) {
        //console.log("processError()", error);
        //this.showLoadingSpinner = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.toast.processingErrorTitle,
                message: error.body.message,
                variant: "error"
            })
        );
    }

    processMessages(result) {
        if (result.messagesJson) {
            let messages = JSON.parse(result.messagesJson);
            //console.log("processMessages()", messages);

            // Process messages returned
            // Display toasts when applicable
            // Create content for the details section

            for (var i = 0; i < messages.length; i++) {
                var message = messages[i];

                if (message.toast === true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: message.title,
                            message: message.message,
                            variant: message.severity
                        })
                    );
                }
            }

            this.showProcessLog = true;
        }
    }

    handleAddressChange(event) {

        console.log('B2bCheckoutShipToInput - handleAddressChange');
        
        const selectedAddress = event.detail.value;
        console.log('Option selected with value: ' + selectedAddress);

        this.selectedAddress = selectedAddress;
        this.shippingContactPointAddressId = selectedAddress;

        // Update the CartDeliveryGroup

        this.updateCartDeliveryGroupShipToAddress(selectedAddress);

    }

    // Called by the parent component
    setCartDeliveryGroupDefaultAddress() {

        if(this.shippingContactPointAddressId === undefined || this.shippingContactPointAddressId === null) {
            const defaultAddressId = this.defaultAddress;

            this.updateCartDeliveryGroupShipToAddress(defaultAddressId);
        }
        else {
            this.updateCartDeliveryGroupShipToAddress(this.shippingContactPointAddressId);
        }

    }

    // Update the CartDeliveryGroup record to have the address fields from the specified address.
    updateCartDeliveryGroupShipToAddress(contactPointAddressId) {

        console.log('inside updateCartDeliveryGroupShipToAddress()');
        console.log('contactPointAddressId: ' + contactPointAddressId);

        // // Send the change to the containing component
        // const customEvent = new CustomEvent('shippingaddresschange', {
        //     detail : contactPointAddressId, bubbles : true, composed: true
        // });

        // this.dispatchEvent(customEvent);

        setCartDeliveryGroupShipToAddress({
            contactPointAddress: contactPointAddressId,
            cartId: this.cartId
            })
            .then((result) => {

                console.log('back from setCartDeliveryGroupShipToAddress');

                this.processMessages(result);

                // const customEvent = new CustomEvent('loadingspinner', {
                //     detail : true, bubbles : true
                // });
        
                // this.dispatchEvent(customEvent);
        
                // const customEvent2 = new CustomEvent('reloadsummary', {
                //     detail : true, bubbles : true
                // });

                // Send the change to the containing component
                const customEvent2 = new CustomEvent('shippingaddresschange', {
                    detail : contactPointAddressId, bubbles : true, composed: true
                });
        
                this.dispatchEvent(customEvent2);
            })
            .catch((error) => {
                this.processError(error);
            });

    }

    handleShippingInstructionsChange(event) {
        const value = event.detail.value;

        this.shippingInstructions = value;

        const selectedEvent = new CustomEvent('shippinginstructionschange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);
    }

}