/**
 * @FileName: lineSheetDisplay
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLineSheet from '@salesforce/apex/XC_LWC_LineSheetCtrl.getLineSheet';

export default class LineSheetDisplay extends LightningElement {
    @api lineSheetId;
    @api isClone = false;
    @api storeFrontDisplay = false;

    @track lineSheet;

    showSpinner = false;
    sourceIndex = -1;
    targetIndex = -1;

    get hasLineSheet() {
        return this.lineSheet !== undefined;
    }

    get hasHeaderImage() {
        return this.lineSheet.headerImageUrl;
    }

    get hasLineSheetText() {
        return this.lineSheet.lineSheetText;
    }

    get hasLineSheetItems() {
        return this.lineSheet.lineSheetItems.length > 0;
    }

    get hasFooterContent() {
        return (this.lineSheet.footerText || this.lineSheet.footerImageUrl);
    }

    get backgroundImageStyle() {
        return 'background-image: url(' + this.lineSheet.headerImageUrl + ');';
    }

    get lineSheetItems() {
        return this.lineSheet.lineSheetItems;
    }

    get templateElement() {
        return this.template.querySelector('.template-container');
    }

    connectedCallback() {
        if (this.lineSheetId) {
            this.getLineSheet();
        }
        else {
            this.resetLineSheet();
        }
    }

    renderedCallback() {
        if (this.hasLineSheet) {
            this.setTemplate();
        }
    }

    @api
    getLineSheet() {
        this.showSpinner = true;

        getLineSheet({
            lineSheetId : this.lineSheetId
        })
        .then(result => {
            this.lineSheet = JSON.parse(result);

            if (this.isClone) {
                this.lineSheet.id = null;

                for (let item of this.lineSheet.lineSheetItems) {
                    item.id = null;
                }
            }

            this.dispatchEvent(new CustomEvent("setlinesheet", {detail : this.lineSheet}));
            this.showSpinner = false;
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
            this.showSpinner = false;
        });
    }

    resetLineSheet() {
        this.lineSheet = {
            'template' : '',
            'contactId' : '',
            'contactName' : '',
            'headerImageUrl' : '',
            'headerText' : '',
            'lineSheetText' : '',
            'footerImageUrl' : '',
            'footerText' : '',
            'lineSheetItems' : []
        };

        this.dispatchEvent(new CustomEvent("setlinesheet", {detail : this.lineSheet}));
    }

    @api
    setLineSheet(lineSheet) {
        this.lineSheet = lineSheet;
    }

    @api
    setTemplate() {
        let templateClass = 'template-container';

        if (this.lineSheet.template) {
            templateClass += ' ' + this.lineSheet.template.toLowerCase().replace(' ', '-')
        }

        this.templateElement.className = templateClass;
    }

    removeProduct(event) {
        this.lineSheet.lineSheetItems = this.removeRecord(this.lineSheet.lineSheetItems, event.detail, 'productId');
        this.dispatchEvent(new CustomEvent("setlinesheet", {detail : this.lineSheet}));
    }

    removeRecord(records, value, property) {
        for (let item of records) {
            if (item[property] === value) {
                let index = records.indexOf(item);
                records.splice(index, 1);
                break;
            }
        }

        return records;
    }

    // DRAG AND DROP EVENTS
    dragEnd(event) {
        this.toggleDraggableClass();
        this.sourceIndex = -1;
        this.targetIndex = -1;
    }

    dragStart(event) {
        event.dataTransfer.setData('productId', event.target.dataset.product);
        this.sourceIndex = event.target.dataset.index;
    }

    allowDrop(event) {
        event.preventDefault();
        event.stopPropagation();

        this.targetIndex = event.target.dataset.index;

        event.target.parentElement.classList.add('xcls-dragover');
    }

    onDrop(event) {
        event.preventDefault();
        event.stopPropagation();

        let productId = event.dataTransfer.getData('productId');
        let index = event.dataTransfer.getData('index');

        if (productId === 'undefined') return;

        this.swapArray(this.sourceIndex, this.targetIndex);

        event.target.parentElement.classList.remove('xcls-dragover');

        this.dispatchEvent(new CustomEvent("setlinesheet", {detail : this.lineSheet}));
    }

    dragLeave(event) {
        let element = event.target.parentElement;

        if (element) {
            element.classList.remove('xcls-dragover');
        }
    }

    swapArray(idx1, idx2) {
        [this.lineSheet.lineSheetItems[idx1], this.lineSheet.lineSheetItems[idx2]] = [this.lineSheet.lineSheetItems[idx2], this.lineSheet.lineSheetItems[idx1]];
    }

    toggleDraggableClass() {
        let elements = this.template.querySelectorAll('c-xc-line-sheet-item');

        elements.forEach(element => {
            if (element.index === this.sourceIndex) {
                element.parentElement.classList.add('xcls-dragover');
            } else {
                element.parentElement.classList.remove('xcls-dragover');
            }
        });
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