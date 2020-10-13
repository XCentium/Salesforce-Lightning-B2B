/**
 * @FileName: lineSheetForm
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/26/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLineSheet from '@salesforce/apex/XC_LWC_LineSheetCtrl.getLineSheet';
import getItem from '@salesforce/apex/XC_LWC_LineSheetCtrl.getItem';
import saveLineSheet from '@salesforce/apex/XC_LWC_LineSheetCtrl.saveLineSheet';

const richTextHeaderFormats = ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'color'];
const richTextFormats = ['font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent', 'align', 'link', 'clean', 'table', 'header', 'color'];

export default class LineSheetForm extends LightningElement {
    @api isUpdate = false;
    @api isClone = false;
    @api lineSheetId;
    @api templateOptions;

    @track productResults = [];
    @track productRows = ['row1'];
    @track itemContainers = ['item1', 'item2', 'item3', 'item4'];

    lineSheet = {};

    richTextHeaderFormats = richTextHeaderFormats;
    richTextFormats = richTextFormats;

    // Contact Search Parameters
    cPlaceholder = 'Select Contact';
    cFieldsByObject;
    cQueryFilters;
    cComparisonField;
    cDisplayFields;
    cSearchSoql = true;

    // Product Search Parameters
    pPlaceholder = 'Select Products';
    pFieldsByObject;
    pComparisonField;
    pDisplayFields;
    pSearchSoql = true;
    pOverrideResults = true;

    get cSearchString() {
        return this.lineSheet.contactName;
    }

    get pSearchInput() {
        return this.template.querySelector("c-s-object-lookup[data-id='productLookup']");
    }

    get pQueryFilters() {
        let queryFilters = '';

        // don't query previously added products
        if (this.lineSheet.lineSheetItems) {
            for (let item of this.lineSheet.lineSheetItems) {
                queryFilters += ' AND Id != \'' + item.productId + '\'';
            }
        }

        return queryFilters;
    }

    get noContact() {
        return !this.lineSheet.contactId;
    }

    get hasProducts() {
        return this.productResults.length > 0;
    }

    get lineSheetDisplay() {
        return this.template.querySelector('c-line-sheet-display');
    }

    get hasTemplate() {
        return this.lineSheetId;
    }

    connectedCallback() {
        this.setQueryParameters();
    }

    setQueryParameters() {
        this.cFieldsByObject = {
            'Contact' : 'Id, Name'
        };

        this.cComparisonField = 'Name';
        this.cDisplayFields = ['Name'];

        this.pFieldsByObject = {
            'Product2' : 'Id, Name, StockKeepingUnit'
        };

        this.pComparisonField = 'Name';
        this.pDisplayFields = ['Name', 'StockKeepingUnit'];
    }

    setLineSheet(event) {
        this.lineSheet = event.detail;
        this.pSearchInput.queryFilters = this.pQueryFilters;
    }

    getItem(productId) {
        if (!productId) return;

        getItem({
            productId : productId,
            contactId : this.lineSheet.contactId
        })
        .then(result => {
            this.lineSheet.lineSheetItems.push(JSON.parse(result));
            this.lineSheetDisplay.setLineSheet(this.lineSheet);
            this.pSearchInput.reset();
            this.pSearchInput.queryFilters = this.queryFilters;
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    refreshPreview() {
        this.lineSheetDisplay.setLineSheet(this.lineSheet);
    }

    selectContact(event) {
        this.lineSheet.contactId = event.detail.Id;
        this.lineSheet.contactName = event.detail.Name;
    }

    handleFieldChange(event) {
        this.lineSheet[event.currentTarget.dataset.name] = event.target.value;
        this.lineSheetDisplay.setLineSheet(this.lineSheet);

        if (event.currentTarget.dataset.name === 'template') {
            this.lineSheetDisplay.setTemplate();
        }
    }

    setProductResults(event) {
        if (event.detail) {
            this.productResults = event.detail;
        }
        else {
            this.productResults = [];
        }
    }

    addProduct(event) {
        let productId = event.target.dataset.product;
        this.getItem(productId);
    }

    handleSave(event) {
        for (let i = 0; i < this.lineSheet.lineSheetItems.length; i ++) {
            this.lineSheet.lineSheetItems[i].sortOrder = i;
        }

        saveLineSheet({
            wrapperJSON : JSON.stringify(this.lineSheet)
        })
        .then(result => {
            this.showToast('Success', 'Your line sheet has been saved.', 'success');
            this.hideForm(event);
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    hideForm(event) {
        this.dispatchEvent(new CustomEvent('hide'));
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