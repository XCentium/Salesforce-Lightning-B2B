import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

import COMMUNITYID from "@salesforce/community/Id";

import fetchInitValues from "@salesforce/apex/B2B_SPC_ComponentController.fetchInitValues";

export default class B2bCheckoutSinglePage extends LightningElement {

    @api cartId;
    @api effectiveAccountId;

    // User entered
    @api billingContactPointAddressId;
    @api hideCardExpirationMonth;
    @api hideCardHolderName;
    @api hideCardType;
    @api hideCreditCardBillingAddress;
    @api hideCVV;
    @api hideExpirationYear;
    @api hidePurchaseOrderBillingAddress;
    @api paymentGatewayId;
    @api purchaseOrderNumber;
    @api requireCardExpirationMonth;
    @api requireCardExpirationYear;
    @api requireCardType;
    @api requireCardholderName;
    @api requireCreditCardBillingAddress;
    @api requireCVV;
    @api requirePurchaseOrderBillingAddress;
    @api paymentType;

    @api shippingContactPointAddressId;
    @api shippingInstructions;

    // Component display options
    @api showDeliveryInstructions;
    @api showShippingAddresses;
    @api makeComponentReadOnly;

    @api
    availableActions = [];

    communityId = COMMUNITYID;

    @api webstoreId;

    // Used to determine if/when the cart summary may be loaded
    isShipToLocationSet = false;
    isDeliveryMethodSet = false;

    @track showLoadingSpinner = false;

    // Custom Labels
    labels = {
        toast: {
            processingErrorTitle: 'Processing Error'
        },
        component: {
            altPleaseWait: 'Please wait...'
        }
    };

    constructor() {
        super();

        console.log('B2bCheckoutSinglePage: paymentType = ' + this.paymentType);

        this.template.addEventListener('loadingspinner', this.handleSpinnerEvent.bind(this));

        this.template.addEventListener('reloadsummary', this.handleReloadSummaryEvent.bind(this));
    }

    connectedCallback() {
        console.log("B2bCheckoutSinglePage: connectedCallback()");
        console.log("cartId: ", this.cartId);

        this.doInit();

    }

    doInit() {

        this.showLoadingSpinner = true;

        fetchInitValues({
            communityId: this.communityId,
            effectiveAccountId: this.effectiveAccountId
        })
            .then((result) => {
                this.showLoadingSpinner = false;

                console.log('result: ' + JSON.stringify(result));
                
                if (result) {
                    this.webstoreId = result.webstoreId;
                    this.effectiveAccountId = result.effectiveAccountId;
                    this.cartId = result.cartId;

                    if(this.cartId) {

                        // Does the initial retrieve of the cart summary.
                        // A custom event will be thrown whenever the ship to or carrier is changed to reload the cart summary.

                        const comp = this.template.querySelector('c-b2b-checkout-cart-summary');
                        if(comp) {
                            comp.setProperties(this.webstoreId, this.effectiveAccountId, this.cartId);
                            comp.loadCartSummary(true);
                        }
                        else {
                            console.log('child component not found (c-b2b-checkout-cart-summary)!');
                        }

                        // The cart summary will be loaded after the ship to addresses are loaded and a default address is applied (or not)

                        const comp2 = this.template.querySelector('c-b2b-checkout-delivery-method-selection');
                        if(comp2) {
                            comp2.setProperties(this.webstoreId, this.effectiveAccountId, this.cartId);
                            comp2.loadDeliveryMethods();
                        }
                        else {
                            console.log('child component not found (c-b2b-checkout-delivery-method-selection)!');
                        }

                        // Set the default ship to address, so that tax will be displayed when a default ship to is designated
                        // if the ship to address is not already set, the method will send an event to reload the cart summary
                        // const comp3 = this.template.querySelector('c-b2b-checkout-ship-to-input');
                        // if(comp3) {
                        //     comp3.setCartDeliveryGroupDefaultAddress();
                        // }
                        // else {
                        //     console.log('child component not found (c-b2b-checkout-ship-to-input)!');
                        // }
                        
                    }
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

    handleSpinnerEvent(event) {
        console.log('inside handleSpinnerEvent');
        console.log('detail: ' + event.detail);
        this.showLoadingSpinner = event.detail;
    }

    handleReloadSummaryEvent(event) {

        if(this.isShipToLocationSet && this.isDeliveryMethodSet) {
        //if(this.isShipToLocationSet || this.isDeliveryMethodSet) {
            const comp = this.template.querySelector('c-b2b-checkout-cart-summary');

            comp.loadCartSummary(true);
        }
    }

    // Drives the reload of the cart summary
    handleShippingAddressChange(event) {
        console.log('inside handleShippingAddressChange - parent');
        console.log('shippingContactPointAddressId: ' + event.detail);

        this.shippingContactPointAddressId = event.detail;
        this.isShipToLocationSet = true;

        this.handleReloadSummaryEvent(null);
    }

    // Drives the reload of the cart summary
    handleDeliveryMethodChange(event) {
        this.isDeliveryMethodSet = true;

        this.handleReloadSummaryEvent(null);
    }

    handleShippingInstructionsChange(event) {
        console.log('inside handleShippingInstructionsChange - parent');
        console.log('shippingInstructions: ' + event.detail);

        this.shippingInstructions = event.detail;
    }

    handlePaymentTypeChange(event) {
        console.log('inside handlePaymentTypeChange - parent');
        console.log('paymentType: ' + event.detail);

        this.paymentType = event.detail;
    }

    handlePoChange(event) {
        console.log('iside handlePoChange - grand parent');
        console.log('purchaseOrderNumber: ' + event.detail);
        this.purchaseOrderNumber = event.detail;
    };

    // Probably don't need these

    handleNameChange(event) {
        this.nameOnCard = event.detail;
    };

    handleCardTypeChange(event) {
        console.log('handleCardTypeChange grand parent');
        this.cardType = event.detail;
    };

    handleCardNumberChange(event) {
        this.cardNumber = event.detail;
    };

    handleCVVChange(event) {
        this.cvv = event.detail;
    }

    handleExpiryMonthChange(event) {
        this.expiryMonth = event.detail;
    };

    handleExpiryYearChange(event) {
        this.expiryYear = event.detail;
    };

    handleBillingAddressChange(event) {

        console.log('handleBillingAddressChange grand parent');

        const selectedAddress = event.detail;
        console.log('selectedAddress: ' + selectedAddress);

        this.billingContactPointAddressId = selectedAddress;

    }

    handleGoNext() {

        console.log('inside handleGoNext');

        // var attributeChangeEvent = new FlowAttributeChangeEvent('newStreet', this.newStreet);
        // this.dispatchEvent(attributeChangeEvent);

        // console.log('newStreet set');

        // attributeChangeEvent = new FlowAttributeChangeEvent('newCity', this.newCity);
        // this.dispatchEvent(attributeChangeEvent);

        // console.log('newCity set');

        // attributeChangeEvent = new FlowAttributeChangeEvent('newState', this.newState);
        // this.dispatchEvent(attributeChangeEvent);

        // attributeChangeEvent = new FlowAttributeChangeEvent('newPostalCode', this.newPostalCode);
        // this.dispatchEvent(attributeChangeEvent);

        // attributeChangeEvent = new FlowAttributeChangeEvent('newCountry', this.newCountry);
        // this.dispatchEvent(attributeChangeEvent);

        // attributeChangeEvent = new FlowAttributeChangeEvent('newPhone', this.newPhone);
        // this.dispatchEvent(attributeChangeEvent);

        // attributeChangeEvent = new FlowAttributeChangeEvent('newFax', this.newFax);
        // this.dispatchEvent(attributeChangeEvent);

        const comp2 = this.template.querySelector('c-b2b-checkout-delivery-method-selection');
        if(comp2) {
            let isValid = comp2.validateDeliveryMethodSelection();
            if(isValid === false) {
                return;
            }
        }

        console.log('checking for NEXT');

        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent2 = new FlowNavigationNextEvent();

            console.log('going to next');
            this.dispatchEvent(navigateNextEvent2);
        }
    }

}