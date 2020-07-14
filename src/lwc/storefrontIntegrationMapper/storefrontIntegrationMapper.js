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

import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveApexClasses from '@salesforce/apex/XC_LWC_DataCtrl.getActiveApexClasses';
import getCheckoutExternalServices from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.getCheckoutExternalServices';
import removeExternalService from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.removeExternalService';
import registerExternalService from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.registerExternalService';
import createStoreIntegratedService from '@salesforce/apex/XC_LWC_IntegrationMapperCtrl.createStoreIntegratedService';

export default class StorefrontIntegrationMapper extends LightningElement {
    @api recordId;
    hasCheckoutExternalServices
    checkoutExternalServices;
    apexClassId;
    apiVersion;
    serviceType;
    registeredIntegrationId;
    messages;
    errorMessages;

    @wire(getActiveApexClasses, {})
    apexClasses;

    connectedCallback() {
        this.messages = [];
        this.errorMessages = [];
        hasCheckoutExternalServices = false;

        this.getCheckoutExternalServices();
    }

    changeHandler(event) {
        this[event.target.name] = event.target.value;
    }

    getCheckoutExternalServices() {
        let criteria = {
            webstoreId : this.recordId
        }

        getCheckoutExternalServices(criteria)
        .then(result => {
            console.log(result);
            this.hasCheckoutExternalServices = result.length > 0;
            this.checkoutExternalServices = result;
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

    removeExternalService(event) {
        let criteria = {
            storeIntegratedServiceId : event.target.value
        }

        removeExternalService(criteria)
        .then(result => {
            this.getCheckoutExternalServices();
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

    registerExternalService() {
        let criteria = {
            webstoreId : this.recordId,
            apexClassId : this.apexClassId,
            apiVersion : this.apiVersion,
            serviceType : this.serviceType
        }

        registerExternalService(criteria)
        .then(result => {
            this.messages = result.messages;
            this.errorMessages = result.errorMessages;

            if (this.errorMessages.length === 0) {
                this.createStoreIntegratedService(result.registeredIntegrationId);
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

    createStoreIntegratedService(registeredIntegrationId) {
        let criteria = {
            webstoreId : this.recordId,
            registeredIntegrationId : registeredIntegrationId,
            serviceType : this.serviceType
        }

        createStoreIntegratedService(criteria)
        .then(result => {
            this.messages.push(result.messages);
            this.errorMessages = result.errorMessages;
            this.getCheckoutExternalServices();
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