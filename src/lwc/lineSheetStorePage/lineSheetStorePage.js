/**
 * @FileName: lineSheetStorePage
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       10/6/2020       Created
 *-----------------------------------------------------------
 */

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactLineSheets from '@salesforce/apex/XC_LWC_LineSheetCtrl.getContactLineSheets';
import saveLineSheet from '@salesforce/apex/XC_LWC_LineSheetCtrl.saveLineSheet';

export default class LineSheetStorePage extends LightningElement {
    lineSheet;
    @track lineSheets;

    get lineSheetDisplay() {
        return this.template.querySelector('c-line-sheet-display');
    }

    connectedCallback() {
        this.getContactLineSheets();
    }

    getContactLineSheets() {
        getContactLineSheets()
        .then(result => {
            this.lineSheets = JSON.parse(result);
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    selectLineSheet(event) {
        this.lineSheetDisplay.lineSheetId = event.currentTarget.dataset.id;

        let btns = this.template.querySelectorAll('.xcls-line-sheet-btn');

        for (let btn of btns) {
            btn.classList.remove('active');
        }

        event.target.classList.add('active');

        this.lineSheetDisplay.getLineSheet();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });

        this.dispatchEvent(event);
    }

    getErrorMessage(error) {
        return error.body !== undefined ? error.body.message : error;
    }
}