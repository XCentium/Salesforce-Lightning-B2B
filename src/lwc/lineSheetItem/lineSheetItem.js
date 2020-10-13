/**
 * @FileName: lineSheetItem
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';

export default class LineSheetItem extends LightningElement {
    @api item;
    @api storeFrontDisplay = false;

    get hasItem() {
        return this.item.productId;
    }

    removeProduct(event) {
        this.dispatchEvent(new CustomEvent("removeproduct", {detail : event.target.value}));
    }
}