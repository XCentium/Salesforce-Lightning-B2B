import { LightningElement, api } from 'lwc';

export default class B2bCheckoutLoadingSpinner extends LightningElement {

    @api showLoadingSpinner = false;

    // Custom Labels
    labels = {
        toast: {
            processingErrorTitle: 'Processing Error'
        },
        component: {
            altPleaseWait: 'Please wait...'
        }
    };

}