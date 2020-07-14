/**
 * @FileName: quickOrder
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/8/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import fillCartFromCSV from '@salesforce/apex/XC_LWC_CartCtrl.fillCartFromCSV';

export default class QuickOrder extends LightningElement {
    @api recordId;

    get acceptedFormats() {
        return ['.csv'];
    }

    processCSV(event) {
        var that = this;
        var input = this.template.querySelector('[data-id="csv-file"]');
        const file = input.files[0];

        if(file === undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload a file',
                    variant: 'error',
                }),
            );
            return;
        }

        let reader = new FileReader();
        reader.readAsText(file);
        reader.onload = function (event) {
            let csvContents = event.target.result;
            that.fillCart(csvContents, input);
        };
    }

    fillCart(csvContents, input) {
        fillCartFromCSV({csvContents : csvContents})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Products have been added to your cart',
                    variant: 'success',
                }),
            );

            input.value = '';
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        })
    }
}