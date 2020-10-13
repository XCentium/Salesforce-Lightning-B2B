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

import getProduct from "@salesforce/apex/XC_LWC_ProductCtrl.getProduct";
//import checkProductIsInStock from "@salesforce/apex/XC_LWC_ProductCtrl.checkProductIsInStock";
import getProductPrice from "@salesforce/apex/XC_LWC_ProductCtrl.getProductPrice";
import addItemToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemToCart';
import { resolve } from "c/cmsResourceResolver";

/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetails extends LightningElement {
    @api recordId;
    @api effectiveAccountId;
    @api videoUrl;
    @api showProductAttributes;
    @api showAggregateGrid;
    @api showQuickOrder;
    @api showProductTabs;

    showSpinner = false;

    //The full product information retrieved.
    @wire(getProduct, {
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    product;

    // The price of the product for the user, if any.
    @wire(getProductPrice, {
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
    })
    productPrice;

    // Gets the normalized effective account of the user.
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || "";
        let resolved = null;

        if (effectiveAccountId.length > 0 && effectiveAccountId !== "000000000000000") {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    // Gets whether product information has been retrieved for display.
    get hasProduct() {
        return this.product.data !== undefined;
    }

    // Gets the normalized, displayable product information for use by the display components.
    get displayableProduct() {
        return {
            categoryPath: this.product.data.productDetail.primaryProductCategoryPath.path.map(category => ({
                id: category.id,
                name: category.name
            })),
            description: this.product.data.productDetail.fields.Description,
            image: {
                alternativeText: this.product.data.productDetail.defaultImage.alternativeText,
                url: resolve(this.product.data.productDetail.defaultImage.url)
            },
            brand: this.product.data.productDetail.fields.Brand__c,
            name: this.product.data.productDetail.fields.Name,
            price: {
                currency: (this.productPrice.data || {}).currencyIsoCode,
                negotiated: (this.productPrice.data || {}).unitPrice
            },
            sku: this.product.data.productDetail.fields.StockKeepingUnit,
            videoUrl: this.product.data.productDetail.fields.Video_Url__c,
            productTabs: this.product.data.productTabs,
            childProducts: this.product.data.childProducts
        };
    }

    addItemToCart(event) {
        this.showSpinner = true;

        addItemToCart({
            productId: this.recordId,
            quantity: event.detail,
            effectiveAccountId: this.resolvedEffectiveAccountId
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