/**
 * @FileName: productDetailsAttributes
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/20/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, wire } from 'lwc';

import getProductAttributes from '@salesforce/apex/XC_LWC_ProductCtrl.getProductAttributes';
import addItemToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemToCart';

export default class ProductDetailsAttributes extends LightningElement {
    @api productId;
    @api effectiveAccountId;
    @api orderPad;

    showSpinner = false;
    productAttributes;
    displayAttributes;
    availableAttributes;
    selectedAttributes = {};
    quantity;

    @wire(getProductAttributes, {productId: '$productId'})
    setAttributes({error, data}){
        console.log(data);
        if (data) {
            this.productAttributes = data;
            this.displayAttributes = data.attributes;
            this.availableAttributes = {};

            for (var att of data.attributes) {
                this.availableAttributes[att.name] = att.values;
            }
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

    attributeChangeHandler(event) {
        this.selectedAttributes[event.target.name] = event.target.value;

        var attValues = [];

        for (var productId in this.productAttributes.attributesByProduct) {
            var attributesByProduct = this.productAttributes.attributesByProduct[productId];

            // bypass products that do not have the selected attribute value
            if (attributesByProduct[event.target.name] !== event.target.value) continue;

            for (var att in this.displayAttributes) {
                var attName = this.displayAttributes[att].name;

                // do not reconstruct available options in the event picklist
                if (attName === event.target.name) continue;

                var option = {};
                option['label'] = attributesByProduct[attName];
                option['value'] = attributesByProduct[attName];

                var options = [];

                if (attValues.includes(attName)) {
                    options = this.availableAttributes[attName];
                }

                attValues.push(attName);
                options.push(option);

                this.availableAttributes[attName] = options;
            }
        }

        this.displayAttributes = [];

        for (var key in this.availableAttributes) {
            var att = {
                name: key,
                values: this.availableAttributes[key]
            };
            this.displayAttributes.push(att);
        }
    }

    changeHandler(event) {
        this[event.target.name] = event.target.value;
    }

    addToCart() {
        var selectedProductId;

        for (var productId in this.productAttributes.attributesByProduct) {
            var valid = false;
            var attributesByProduct = this.productAttributes.attributesByProduct[productId];

            for (var attribute in attributesByProduct) {
                if (attributesByProduct[attribute] === this.selectedAttributes[attribute]) {
                    valid = true;
                }
                else {
                    valid = false;
                    break;
                }
            }

            if (valid) {
                selectedProductId = productId;
                break;
            }
        }

        if (!selectedProductId) {
            selectedProductId = this.productId;
        }

        this.showSpinner = true;

        addItemToCart({
            productId : selectedProductId,
            quantity : this.quantity,
            effectiveAccountId : this.resolvedEffectiveAccountId
        })
        .then(result => {
            console.log(result);
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
        });
    }
}