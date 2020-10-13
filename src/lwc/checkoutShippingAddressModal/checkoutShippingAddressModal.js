/**
 * @FileName: checkoutShippingAddressModal
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/14/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, track } from 'lwc';
import createContactPointAddress from "@salesforce/apex/XC_LWC_CheckoutCtrl.createContactPointAddress";

export default class CheckoutShippingAddressModal extends LightningElement {
    showSpinner = false;
    @track error;
    address = {};

    closeModal() {
        this.dispatchEvent(new CustomEvent("modalclose", {}));
    }

    handleChange(event) {
        this.address[event.target.name] = event.target.value;
    }

    createAddress() {
        this.showSpinner = true;

        let addressJSON = JSON.stringify(this.address);

        createContactPointAddress({
            addressJSON : addressJSON
        })
        .then(result => {
            this.dispatchEvent(new CustomEvent("modalsave", {detail : result}));
            this.error = undefined;
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.error = error.body != undefined ? error.body.message : error;
            this.showSpinner = false;
        });
    }
}