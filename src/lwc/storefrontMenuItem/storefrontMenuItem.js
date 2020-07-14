/**
 * @FileName: storefrontMenuItem
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/1/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class NavigationTab extends NavigationMixin(LightningElement) {
    @api menuName;
    @api menuItem;

    connectedCallback() {
        this.styleMenuItem();
    }

    navigate() {
        var navItem = this.template.querySelector('[data-id="nav-item"]');

        if (navItem) {
            this.template.querySelector('[data-id="nav-item"]').classList.toggle('mm-hide');
            this.template.querySelector('[data-id="nav-item"]').classList.toggle('mm-show');
        }

        let type = this.menuItem.type;
        let attributes = {};

        if (type == 'comm__namedPage') {
            attributes.name = this.menuItem.pageName;
        }

        if (type == 'standard__recordPage') {
            attributes.recordId = this.menuItem.recordId;
            attributes.objectApiName = this.menuItem.objectApiName;
            attributes.actionName = 'view';
        }

        this[NavigationMixin.Navigate]({
            type: type,
            attributes: attributes
        });
    }

    styleMenuItem() {
        let template = this.querySelector('#nav-item-template');
        console.log(this.menuName);
        let navItemContainer = this.template.querySelector('[data-id="nav-item"]')
        console.log(navItemContainer);
        //navItemContainer.classList.add(this.menuName.toLowerCase().replace(' ', '-'));
        console.log(navItemContainer);
    }
}