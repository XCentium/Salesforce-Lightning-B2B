/**
 * @FileName: productImage
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/4/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api, wire } from 'lwc';
import getProductImage from "@salesforce/apex/XC_LWC_ProductCtrl.getProductImage";
import { resolve } from "c/cmsResourceResolver";

export default class ProductImage extends LightningElement {
    @api recordId;
    @api effectiveAccountId;

    //The full product information retrieved.
    @wire(getProductImage, {
        recordId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    product;

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAccountId.length > 0 && effectiveAccountId !== "000000000000000") {
            resolved = effectiveAccountId;
        }

        return resolved;
    }

    // Gets whether product information has been retrieved for display.
    get showImage() {
        return this.product.data !== undefined;
    }

    get image() {
        return {
            alternativeText: this.product.data.productDetail.defaultImage.alternativeText,
            url: resolve(this.product.data.productDetail.defaultImage.url)
        }
    }
}