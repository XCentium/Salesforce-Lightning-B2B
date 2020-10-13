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
    productPath;

    get hasPrice() {
        return this.product.price !== undefined;
    }

    renderedCallback() {
        this.productPath = "https://lb2b-xc-package1.cs12.force.com/albatrossgolf/s/product/" + this.product.id;
        //this.resolveProductPath();
    }

    addToCartHandler() {
        this.dispatchEvent(new CustomEvent("addtocart", {detail : this.product.id}));
    }

    resolveProductPath() {
//        console.log("here");
//
//        const path = [homePage].concat({
//            name: this.product.name,
//            type: 'standard__recordPage',
//            attributes: {
//                actionName: 'view',
//                recordId: this.product.id
//            }
//        });
//
//        console.log('here' + JSON.stringify(path));
//        this.productPath = path;
    }
}