/**
 * @FileName: storefrontIntegrationMapper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/25/2020         Created
 *-----------------------------------------------------------
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveApexClasses from '@salesforce/apex/XC_LWC_DataCtrl.getActiveApexClasses';
import registerCheckoutApexClass from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.registerCheckoutApexClass';
import mapCheckoutService from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.mapCheckoutService';

export default class StorefrontIntegrationMapper extends LightningElement {
    @api recordId;
    apexClasses;
    apexClassId;
    apiVersion;
    serviceType;
    registeredIntegrationId;
    messages;
    errorMessages;

    connectedCallback() {
        getActiveApexClasses()
        .then(result => {
            this.apexClasses = result;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        })
    }

    changeHandler(event) {
        this[event.target.name] = event.target.value;
    }

    registerCheckoutApexClass() {
        this.messages = [];
        this.errorMessages = [];

        let criteria = {
            webstoreId : this.recordId,
            apexClassId : this.apexClassId,
            apiVersion : this.apiVersion,
            serviceType : this.serviceType
        }

        registerCheckoutApexClass(criteria)
        .then(result => {
            this.messages = result.messages;
            this.errorMessages = result.errorMessages;

            if (this.errorMessages.length === 0) {
                this.mapCheckoutService(result.registeredIntegrationId);
            }
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

    mapCheckoutService(registeredIntegrationId) {
        let criteria = {
            webstoreId : this.recordId,
            registeredIntegrationId : registeredIntegrationId,
            serviceType : this.serviceType
        }

        mapCheckoutService(criteria)
        .then(result => {
            this.messages.push(result.messages);
            this.errorMessages = result.errorMessages;
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
}