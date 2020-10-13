/**
 * @FileName: spotlightProducts
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/30/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSpotlightProducts from '@salesforce/apex/XC_LWC_ProductCtrl.getSpotlightProducts';
import addItemToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemToCart';

export default class SpotlightProducts extends LightningElement {
    @api title;
    @api effectiveAccountId;
    @api locationKey;

    //@wire(getSpotlightProducts, {effectiveAccountId : "$resolvedEffectiveAccountId", locationKey : "$resolvedLocationKey"})
    spotlightProducts;

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

    connectedCallback() {
        this.getSpotlightProducts();
    }

    getSpotlightProducts() {
        console.log(this.locationKey);
        getSpotlightProducts({
            effectiveAccountId : this.effectiveAccountId,
            locationKey : this.locationKey
        })
        .then(result => {
            console.log(result);
            this.spotlightProducts = result;
        })
        .catch(error => {
            console.log(error);
//            this.showToast('Error', this.getErrorMessage(error), 'error');
        });
    }

    addItemToCart(event) {
        addItemToCart({
            productId: event.detail,
            quantity: "1",
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
        .then(result => {
            console.log(result);
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });
    }
}