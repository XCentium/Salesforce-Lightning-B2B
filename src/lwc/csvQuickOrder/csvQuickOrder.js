/**
 * @FileName: csvQuickOrder
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import fillCartFromCSV from '@salesforce/apex/XC_LWC_CartCtrl.fillCartFromCSV';

export default class CsvQuickOrder extends LightningElement {
    @api recordId;
    @api effectiveAccountId;

    showSpinner = false;

    get acceptedFormats() {
        return ['.csv'];
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAccountId.length > 0 && effectiveAccountId !== "000000000000000") {
            resolved = effectiveAccountId;
        }

        return resolved;
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
        this.showSpinner = true;

        fillCartFromCSV({
            csvContents : csvContents,
            effectiveAccountId : this.resolvedEffectiveAccountId
        })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Products have been added to your cart',
                    variant: 'success',
                }),
            );

            input.value = '';

            this.showSpinner = false;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );

            this.showSpinner = false;
        })
    }
}