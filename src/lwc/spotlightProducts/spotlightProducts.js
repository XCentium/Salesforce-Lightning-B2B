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
    spotlightProducts;

    @wire(getSpotlightProducts, {})
    spotlightProducts;

//    connectedCallback() {
//        getSpotlightProducts()
//        .then(result => {
//            this.spotlightProducts = result;
//        })
//        .catch(error => {
//            this.error = error;
//            console.log('errors');
//            console.log(error);
//        });
//    }

    addItemToCart(event) {
        addItemToCart({
            productId: event.detail,
            quantity: "1"
        })
        .then(result => {
            console.log(result);
            console.log('no errors');
        })
        .catch(error => {
            this.error = error;
            console.log('errors');
        });
    }
}