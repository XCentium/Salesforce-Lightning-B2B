import { LightningElement, api, track } from 'lwc';

// CCOPTIONS = [
// { label: 'Visa', value: 'Visa' }
// ,{ label: 'MasterCard', value: 'MasterCard' }
// ,{ label: 'AmericanExpress', value: 'AmericanExpress' }
// ,{ label: 'DinersClub', value: 'DinersClub' }
// ,{ label: 'JCB', value: 'JCB' }
// ];

// MONTHS = [{ label: '1', value: '1' }
// ,{ label: '2', value: '2' }
// ,{ label: '3', value: '3' }
// ,{ label: '4', value: '4' }
// ,{ label: '5', value: '5' }
// ,{ label: '6', value: '6' }
// ,{ label: '7', value: '7' }
// ,{ label: '8', value: '8' }
// ,{ label: '9', value: '9' }
// ,{ label: '10', value: '10' }
// ,{ label: '11', value: '11' }
// ,{ label: '12', value: '12' }
// ];

// YEARS = [
// { label: '2020', value: '2020' }
// ,{ label: '2021', value: '2021' }
// ,{ label: '2022', value: '2022' }
// ,{ label: '2023', value: '2023' }
// ,{ label: '2024', value: '2024' }
// ,{ label: '2025', value: '2025' }
// ];

export default class B2bCheckoutPaymentCc extends LightningElement {

    @api cartId;
    @api contactPointAddressId;
    
    @api hideCardExpirationMonth;
    @api hideCardHolderName;
    @api hideCardType;
    @api hideCreditCardBillingAddress;
    @api hideCVV;
    @api hideExpirationYear;
    
    @api requireCardExpirationMonth;
    @api requireCardExpirationYear;
    @api requireCardType;
    @api requireCardholderName;
    @api requireCreditCardBillingAddress;
    @api requireCVV;

    @api nameOnCard;
    @api cardType;
    @api cardNumber;
    @api cvv;
    @api expiryMonth;
    @api expiryYear;

    // To be displayed in a combo box
    @api options = [];
    @api defaultAddress;
    @api selectedAddress;

    get ccOptions() {
        const theOptions = [
            { label: 'Visa', value: 'Visa' }
            ,{ label: 'MasterCard', value: 'MasterCard' }
            ,{ label: 'AmericanExpress', value: 'AmericanExpress' }
            ,{ label: 'DinersClub', value: 'DinersClub' }
            ,{ label: 'JCB', value: 'JCB' }
            ];
        return theOptions;
    }

    get months() {
        const theOptions = [{ label: '1', value: '1' }
        ,{ label: '2', value: '2' }
        ,{ label: '3', value: '3' }
        ,{ label: '4', value: '4' }
        ,{ label: '5', value: '5' }
        ,{ label: '6', value: '6' }
        ,{ label: '7', value: '7' }
        ,{ label: '8', value: '8' }
        ,{ label: '9', value: '9' }
        ,{ label: '10', value: '10' }
        ,{ label: '11', value: '11' }
        ,{ label: '12', value: '12' }
        ];
        return theOptions;
    }

    get years() {
        const theOptions = [
            { label: '2020', value: '2020' }
            ,{ label: '2021', value: '2021' }
            ,{ label: '2022', value: '2022' }
            ,{ label: '2023', value: '2023' }
            ,{ label: '2024', value: '2024' }
            ,{ label: '2025', value: '2025' }
            ];
        return theOptions;
    }

    handleNameOnCardChange(event) {
        console.log('handleNameOnCardChange child');

        const selectedEvent = new CustomEvent('nameoncardchange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleCardTypeChange(event) {
        console.log('handleCardTypeChange child');

        const selectedEvent = new CustomEvent('cardtypechange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleCardNumberChange(event) {
        console.log('handleCardNUmberChange child');

        const selectedEvent = new CustomEvent('cardnumberchange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleCVVChange(event) {
        console.log('handleCVVChange child');

        const selectedEvent = new CustomEvent('cvvchange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleExpiryMonthChange(event) {
        console.log('handleExpiryMonthChange child');

        const selectedEvent = new CustomEvent('expirymonthchange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleExpiryYearChange(event) {
        console.log('handleExpiryYearChange child');

        const selectedEvent = new CustomEvent('expiryyearchange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(selectedEvent);

    };

    handleBillingAddressChange(event) {

        console.log('handleBillingAddressChange child');

        this.selectedAddress = event.detail.value;

        const customEvent = new CustomEvent('billingaddresschange', { detail: event.detail.value, bubbles : true, composed: true });

        this.dispatchEvent(customEvent);

    }

}