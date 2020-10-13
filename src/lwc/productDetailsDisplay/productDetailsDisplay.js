/**
 * @FileName: productDetailsDisplay
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/10/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class ProductDetailsDisplay extends NavigationMixin(LightningElement) {
    @api productId;
    @api effectiveAccountId;
    @api description;
    @api displayableProduct;
    @api showProductAttributes;
    @api showAggregateGrid;
    @api showQuickOrder;
    @api showProductTabs;

    hasVideo;
    showStandardActions = false;
    showDescription = false;
    quantity;

    _categoryPath;
    _resolvedCategoryPath = [];

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    connectedCallback() {
        this.hasVideo = this.videoUrl != undefined;
        this._resolveConnected();

        if (!this.displayableProduct.productTabs || this.displayableProduct.productTabs.length === 0 || !this.showProductTabs) {
            this.showDescription = true;
        }

        if (!this.displayableProduct.childProducts || this.displayableProduct.childProducts.length === 0) {
            this.showProductAttributes = false;
            this.showAggregateGrid = false;
            this.showQuickOrder = false;
            this.showStandardActions = true;
        }

        if (!this.showAggregateGrid && !this.showProductAttributes && !this.showQuickOrder) {
            this.showStandardActions = true;
        }
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }

    /**
     * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
     *
     * @type {Category[]}
     */
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        return ((this.displayableProduct.price || {}).negotiated || "").length > 0;
    }

    changeHandler(event) {
        this[event.target.name] = event.target.value;
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */
    notifyAddToCart() {
        this.dispatchEvent(new CustomEvent("addtocart", { detail : this.quantity }));
    }

    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
    resolveCategoryPath(newPath) {
        const path = [homePage].concat(newPath.map((level) => ({
            name: level.name,
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                recordId: level.id
            }
        })));

        this._connected.then(() => {
            const levelsResolved = path.map(level =>
                this[NavigationMixin.GenerateUrl]({
                    type: level.type,
                    attributes: level.attributes
                }).then(url => ({
                    name: level.name,
                    url: url
                }))
            );

            return Promise.all(levelsResolved);
        }).then((levels) => {
            this._resolvedCategoryPath = levels;
            console.log(this._resolvedCategoryPath);
        });
    }
}