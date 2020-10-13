/**
 * @FileName: lineSheetManager
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/26/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplateOptions from '@salesforce/apex/XC_LWC_LineSheetCtrl.getTemplateOptions';
import getLineSheets from '@salesforce/apex/XC_LWC_LineSheetCtrl.getLineSheets';
import deleteLineSheet from '@salesforce/apex/XC_LWC_LineSheetCtrl.deleteLineSheet';

const actions = [
    {label: 'Update', name:'update'},
    {label: 'Clone', name:'clone'},
    {label: 'Delete', name:'delete'}
];

const columns = [
    {label: 'Line Sheet Name', fieldName: 'name', type: 'text'},
    {label: 'Line Sheet Contact', fieldName: 'contactName', type: 'text'},
    {
        type: 'action',
        typeAttributes: {rowActions: actions}
    }
];

export default class LineSheetManager extends LightningElement {
    @track lineSheets;
    @track lineSheetId;

    showForm = false;
    isClone = false;
    columns = columns;
    templateOptions = [];

    get isUpdate() {
        return this.lineSheetId !== undefined;
    }

    connectedCallback() {
        this.getTemplateOptions();
        this.getLineSheets();
    }

    getTemplateOptions() {
        getTemplateOptions()
        .then(result => {
            this.templateOptions = JSON.parse(result);
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    getLineSheets() {
        getLineSheets()
        .then(result => {
            this.lineSheets = JSON.parse(result);
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    create(event) {
        this.toggleForm();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;

        switch(actionName) {
            case 'update':
                this.update(event);
                break;
            case 'clone':
                this.clone(event);
                break;
            case 'delete':
                this.delete(event);
                break;
            default:
        }
    }

    update(event) {
        this.lineSheetId = event.detail.row.id;
        this.toggleForm();
    }

    clone(event) {
        this.lineSheetId = event.detail.row.id;
        this.isClone = true;
        this.toggleForm();
    }

    delete(event) {
        deleteLineSheet({
            lineSheetId : event.detail.row.id
        })
        .then(result => {
            this.getLineSheets();
        })
        .catch(error => {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    hideForm(event) {
        this.lineSheetId = undefined;
        this.isClone = false;
        this.toggleForm();
        this.getLineSheets();
    }

    toggleForm(event) {
        this.showForm = !this.showForm;
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