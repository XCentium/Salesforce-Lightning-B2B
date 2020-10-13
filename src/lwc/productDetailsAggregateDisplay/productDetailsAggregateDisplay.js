/**
 * @FileName: productDetailsAggregateDisplay
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/19/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, wire } from 'lwc';
import getProductAggregates from '@salesforce/apex/XC_LWC_ProductCtrl.getProductAggregates';
import addItemsToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemsToCart';

export default class ProductDetailsAggregateDisplay extends LightningElement {
    @api productId;
    @api effectiveAccountId;

    showSpinner = false;
    productAggregates;
    items = {};

    @wire(getProductAggregates, {productId: '$productId'})
    setAggregates({error, data}){
        if (data) {
            this.productAggregates = {};
            this.productAggregates.colName = data.colName;
            this.productAggregates.rowName = data.rowName;
            this.productAggregates.colValues = data.colValues;

            let rowValues = [];

            for (var row of data.rowValues) {
                let keys = [];

                for (var key in row.keyMap) {
                    keys.push({
                        key: key,
                        value: row.keyMap[key]
                    });
                }

                rowValues.push({
                    value: row.value,
                    keyMap: keys
                });
            }

            this.productAggregates.rowValues = rowValues;
        }
        else if (error) {
            console.log(error);
        }
    }

    // Gets the normalized effective account of the user.
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAccountId.length > 0 && effectiveAccountId !== "000000000000000") {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    quantityChangeHandler(event) {
        if (event.target.value && event.target.value !== 0) {
            this.items[event.target.name] = event.target.value;
        }
        else {
            delete this.items[event.target.name];
        }
    }

    addToCart() {
        this.showSpinner = true;

        addItemsToCart({
            items : this.items,
            effectiveAccountId : this.resolvedEffectiveAccountId
        })
        .then(result => {
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
        });
    }
}