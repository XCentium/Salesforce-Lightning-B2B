/**
 * @FileName: productDetailsTab
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/21/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';

export default class ProductDetailsTab extends LightningElement {
    @api tab;

    text = false;
    video = false;

    connectedCallback() {
        if (this.tab.Type__c == 'Description') {
            this.text = true;
        }
        if (this.tab.Type__c == 'Video') {
            this.video = true;
        }
    }
}