import { LightningElement, api, track } from 'lwc';

export default class B2bCheckoutPaymentPo extends LightningElement {

    @api cartId;
    @api contactPointAddressId;
    
    @api hidePurchaseOrderBillingAddress;
    @api purchaseOrderNumber;
    @api requirePurchaseOrderBillingAddress;

    // To be displayed in a combo box
    @api options = [];
    @api defaultAddress;
    @api selectedAddress;

    handlePoChange(event) {
        console.log('handlePoChange child');

        this.purchaseOrderNumber = event.detail.value;

        const selectedEvent = new CustomEvent('pochange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleBillingAddressChange(event) {

        console.log('handleBillingAddressChange child');

        this.selectedAddress = event.detail.value;

        const selectedEvent = new CustomEvent('billingaddresschange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    }

}