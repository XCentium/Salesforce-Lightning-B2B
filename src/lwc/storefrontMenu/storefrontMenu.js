/**
 * @FileName: storefrontMenu
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMenuItems from '@salesforce/apex/XC_LWC_DataCtrl.getMenuItems';

export default class StorefrontMenu extends LightningElement {
    @api menuName;
    @api horizontalMenu;
    @api floatRight;
    menuItems;

    connectedCallback() {
        if (!this.menuName) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'A menu name must be defined',
                    variant: 'error',
                }),
            );

            return;
        }

        getMenuItems({menuName : this.menuName})
        .then(result => {
            this.menuItems = result;
            this.styleMenu();
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        })
    }

    styleMenu() {
        let navContainer = this.template.querySelector('[data-id="nav-container"]')
        let navMenu = this.template.querySelector('[data-id="nav-menu"]')

        navContainer.classList.add(this.menuName.toLowerCase().replace(' ', '-'));

        if (this.horizontalMenu) {
            navMenu.classList.add('slds-list_horizontal');
        }
        else {
            //navMenu.classList.add('slds-align_absolute-center');
        }
        if (this.floatRight) {
            navMenu.classList.add('slds-float_right');
            navContainer.classList.add('slds-clearfix');
        }
    }
}