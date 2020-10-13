/**
 * @FileName: orderPad
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/18/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';
import getOrderPadOptions from '@salesforce/apex/XC_LWC_DataCtrl.getOrderPadOptions';
import refreshOrderPadOptions from '@salesforce/apex/XC_LWC_DataCtrl.refreshOrderPadOptions';
import addItemToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemToCart';

export default class OrderPad extends LightningElement {
    @api effectiveAccountId;
    options;
    category;
    brand;
    product;

    connectedCallback() {
        getOrderPadOptions()
        .then(result => {
            this.options = result;
        })
        .catch(error => {
            console.log(error);
        })
    }

    changeHandler(event) {
        this[event.target.name] = event.target.value;

        if (event.target.name === 'category') {
            this.brand = '';
            this.product = '';
        }

        if (event.target.name === 'brand') {
            this.product == '';
        }

        if (event.target.name !== 'product') {
            this.refreshOptions(event.target.name);
        }
    }

    refreshOptions(activeFilter) {
        let criteria = {
            activeFilter : activeFilter,
            category : this.category,
            brand : this.brand
        }

        refreshOrderPadOptions(criteria)
        .then(result => {
            this.options = result;
        })
        .catch(error => {
            console.log(error);
        })
    }
}