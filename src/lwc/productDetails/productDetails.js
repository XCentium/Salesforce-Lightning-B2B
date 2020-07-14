/**
 * @FileName: productDetails
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/10/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, wire, api } from "lwc";

import communityId from '@salesforce/community/Id';
import getProduct from "@salesforce/apex/XC_LWC_ProductCtrl.getProduct";
import checkProductIsInStock from "@salesforce/apex/XC_LWC_ProductCtrl.checkProductIsInStock";
import addToCart from "@salesforce/apex/XC_LWC_ProductCtrl.addToCart";
import getProductPrice from "@salesforce/apex/XC_LWC_ProductCtrl.getProductPrice";
import { resolve } from "c/cmsResourceResolver";

/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetails extends LightningElement {

    /**
     * Gets or sers the effective account - if any - of the user viewing the product.
     */
    @api
    effectiveAccountId;

    /**
     *  Gets or sets the unique identifier of a product.
     */
    @api
    recordId;

    /**
     * The stock status of the product, i.e. whether it is "in stock."
     */
    @wire(checkProductIsInStock, {
        productId: "$recordId"
    })
    inStock;

    /**
     * The full product information retrieved.
     */
    @wire(getProduct, {
        communityId: communityId,
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    product;

    /**
     * The price of the product for the user, if any.
     */
    @wire(getProductPrice, {
        communityId: communityId,
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    productPrice;

    /**
     * Gets the normalized effective account of the user.
     */
    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAcocuntId.length > 0 && effectiveAcocuntId !== "000000000000000") {
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }

    /**
     * Gets whether product information has been retrieved for display.
     */
    get hasProduct() {
        return this.product.data !== undefined;
    }

    /**
     * Gets the normalized, displayable product information for use by the display components.
     */
    get displayableProduct() {
        return {
            categoryPath: this.product.data.primaryProductCategoryPath.path.map(category => ({
                id: category.id,
                name: category.name
            })),
            description: this.product.data.fields.Description,
            image: {
                alternativeText: this.product.data.defaultImage.alternativeText,
                url: resolve(this.product.data.defaultImage.url)
            },
            inStock: this.inStock.data === true,
            name: this.product.data.fields.Name,
            price: {
                currency: (this.productPrice.data || {}).currencyIsoCode,
                negotiated: (this.productPrice.data || {}).unitPrice
            },
            sku: this.product.data.fields.StockKeepingUnit
        };
    }

    /**
     * Handles a user request to add the product to their active cart.
     */
    addtoCart() {
        addToCart({
            communityId: communityId,
            productId: this.recordId,
            quantity: "1",
            effectiveAccountId: this.resolvedEffectiveAccountId
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