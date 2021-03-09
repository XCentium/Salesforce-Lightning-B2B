import { LightningElement, api } from 'lwc';

export default class B2bCheckoutPaymentAch extends LightningElement {

    @api nameOnAccount;
    @api accountNumber;
    @api routingNumber;

    handleNameChange(event) {
        this.nameOnAccount = event.detail.value;
    }

    handleAccountChange(event) {
        this.accountNumber = event.detail.value;
    }

    handleRoutingChange(event) {
        this.routingNumber = event.detail.value;
    }

}