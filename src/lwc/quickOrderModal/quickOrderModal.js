import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import addItemToCartWithId from '@salesforce/apex/XC_LWC_QuickOrderModal.addItemToCartWithId';
import getAllProductsSimilarToProduct from '@salesforce/apex/XC_LWC_QuickOrderModal.getAllProductsSimilarToProduct';

export default class QuickOrderModal extends LightningElement {

    @track isModalOpen = false;
    @track columnHeaders = [];
    @track rows = [];
    @track products = [];

    @track record;
    @track error;

    @api productId;

    @wire(getAllProductsSimilarToProduct, {productId: '$productId'})
    getProductsWithKey({error, data}){
        if (data) {
            this.record = data;
            this.error = undefined;
            this.extractProductData(data);
        } else if (error) {
            this.record = undefined;
            this.error = error;
            console.log(error);
        }
    }

    extractProductData(data){
        //console.log("-------Data Coming back-----");
        console.log(data);
        if(data.listOfCustomMetaData){
            this.columnHeaders = data.listOfCustomMetaData[0].Values__c.split(',');
            //console.log('Column Headers');
            //console.log(JSON.parse(JSON.stringify(this.columnHeaders)));
        }
        if(data.listOfProducts){
            //console.log('Data. Products');
            //console.log(data.listOfProducts);
            data.listOfProducts.forEach(product => {
                //console.log('Product');
                let colValues = product.xc_Att_1__c.split(':')[1].replace(/"/g, '').split(',');
                /*let colHeaders = this.columnHeaders;
                console.log('colValues', colValues);
                console.log('colHeaders', JSON.parse(JSON.stringify(this.columnHeaders)));
                console.log('colHeadersSet', colHeaders);*/
                this.products.push(product);
                this.rows.push({
                    id: product.Id,
                    name: product.Name,
                    values: this.columnHeaders,
                    cols: this.columnHeaders.map(col => {
                        /*console.log('prodName', product.Name);
                        console.log('col', col);
                        console.log(colValues.includes(col));*/
                        return {
                            value: !colValues.includes(col),
                            id: col,
                        }
                    })
                });
            })
            /*console.log('this Products');
            console.log(JSON.parse(JSON.stringify(this.products)));
            console.log('Row');
            console.log(JSON.parse(JSON.stringify(this.rows)));*/
        }
        //console.log("-----------------------");
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
}