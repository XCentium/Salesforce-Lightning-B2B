/**
 * @FileName: spotlightProductDisplay
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/2/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';
import { resolve } from "c/cmsResourceResolver";

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class SpotlightProductDisplay extends LightningElement {
    @api product;

    get hasPrice() {
        return this.product.price !== undefined;
    }

    addToCartHandler() {
        this.dispatchEvent(new CustomEvent("addtocart", {detail : this.product.id}));
    }
}