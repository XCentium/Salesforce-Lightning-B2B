/**
 * @FileName: checkoutShippingAddress
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/8/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, wire, track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import getContactPointAddresses from "@salesforce/apex/XC_LWC_CheckoutCtrl.getContactPointAddresses";

export default class CheckoutShippingAddress extends LightningElement {
    @api availableActions = [];
    @api contactPointAddressId;
    @api shippingInstructions = '';

    @track error;
    @track modalOpen;
    @track contactPointAddresses;

    get addressValid() {
        return !this.contactPointAddressId;
    }

    @wire(getContactPointAddresses, {})
    wiredAddresses({error, data}) {
        if (data) {
            this.error = undefined;

            this.contactPointAddresses = [];

            for (let address of data) {
                this.parseAddress(address);
            }
        }
        else if (error) {
            this.contactPointAddresses = undefined;
            this.error = error.body != undefined ? error.body.message : error;
        }
    }

    parseAddress(address) {
        console.log(address);

        let label = (address.Street ? address.Street : '')
                    + (address.City ? ', ' + address.City : '')
                    + (address.State ? ', ' + address.State : '')
                    + (address.postalCode ? ' ' + address.PostalCode : '')
                    + (address.Country ? ' ' + address.Country : '');

        if (label.startsWith(',')) {
            label = label.substring(1);
        }

        this.contactPointAddresses.push({label : label, value : address.Id});
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
    }

    handleNext() {
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    addAddress(event) {
        this.parseAddress(event.detail);
        this.closeModal();
    }

    openModal() {
        this.modalOpen = true;
    }

    closeModal() {
        this.modalOpen = false;
    }
}