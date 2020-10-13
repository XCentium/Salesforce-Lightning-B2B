/**
 * @FileName: sObjectLookupResult
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';

export default class SObjectLookupResult extends LightningElement {
    @api result;

    select(event) {
        this.dispatchEvent(new CustomEvent("select", {detail : this.result}));
    }
}