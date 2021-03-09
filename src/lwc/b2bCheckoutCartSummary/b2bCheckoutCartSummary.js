import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import COMMUNITYID from "@salesforce/community/Id";
import CURRENCY from '@salesforce/i18n/currency';

import fetchInitValues from "@salesforce/apex/B2B_SPC_ComponentController.fetchInitValues";
import getCartSummary from "@salesforce/apex/B2B_SPC_ComponentController.getCartSummary";

export default class B2bCheckoutCartSummary extends LightningElement {

    // Custom Labels
    labels = {
        toast: {
            processingErrorTitle: 'Processing Error'
        },
        component: {
            altPleaseWait: 'Please wait...'
        }
    };

    communityId = COMMUNITYID;
    currency = CURRENCY;

    @api effectiveAccountId;
    @api cartId;
    @api webstoreId;

    @track subtotal = 0.00;
    @track discount = 0.00;
    @track estShipping = 0.00;
    @track estTax = 0.00;
    @track total = 0.00;

    @track showLoadingSpinner = false;

    connectedCallback() {
        //console.log("B2bCheckoutCartSummary: connectedCallback()");

        //this.loadCartSummary();
        //this.doInit();

    }

    doInit() {
        fetchInitValues({
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId,
            cartId: null
        })
            .then((result) => {
                console.log('result: ' + JSON.stringify(result));
                if (result) {
                    this.webstoreId = result.webstoreId;
                    this.effectiveAccountId = result.effectiveAccountId;
                    this.cartId = result.cartId;

                    this.loadCartSummary(false);
                }
            })
            .catch((error) => {
                console.log("error from doInit()");
                console.log(error);
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.toast.processingErrorTitle,
                        message: error.message,
                        variant: "error"
                    })
                );
            });
    }

    @api
    setProperties(webstoreId, effectiveAccountId, cartId) {
        this.webstoreId = webstoreId;
        this.effectiveAccountId = effectiveAccountId;
        this.cartId = cartId;
    }

    @api
    loadCartSummary(recalculateTax) {

        console.log("loadCartSummary() begin");
        console.log("effectiveAccountId", this.effectiveAccountId);
        console.log("webstoreId: ", this.webstoreId);
        console.log("cartId", this.cartId);

        const customEvent = new CustomEvent('loadingspinner', {
            detail : true, bubbles : true
        });

        this.dispatchEvent(customEvent);

        getCartSummary({
            effectiveAccountId: this.effectiveAccountId,
            webstoreId: this.webstoreId,
            activeOrCartId: this.cartId,
            recalculateTax : recalculateTax
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

        console.log("b2bCheckoutCartSummary(): processResult");

        const customEvent = new CustomEvent('loadingspinner', {
            detail : false, bubbles : true
        });

        this.dispatchEvent(customEvent);

        if (result) {
            console.log("processResult():" + JSON.stringify(result));

            this.processResults(result);
        }

        this.processMessages(result);
    }

    processResults(result) {
        // console.log("productResults()", productResults);
        this.total = result.grandTotalAmount;
        this.estTax = result.totalTaxAmount;
        this.subtotal = result.totalProductAmount;
        this.estShipping = result.shippingFee;
        this.discount = result.discount
    }

    processError(error) {
        // console.log("processError()", error);
        console.log("b2bCheckoutCartSummary(): processError");
        console.log("b2bCheckoutCartSummary(): " + error.body.message);

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
            // console.log("processMessages()", messages);

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

        }
    }

}