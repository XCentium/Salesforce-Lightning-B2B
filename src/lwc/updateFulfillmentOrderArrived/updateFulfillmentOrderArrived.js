import { LightningElement, api, track, wire } from 'lwc';
import updateFO from '@salesforce/apex/updateFOArrivedController.updateFO';
import { refreshApex } from '@salesforce/apex';

export default class UpdateFulfillmentOrderArrived extends LightningElement {
    @api encryptedToken = '';
    @api successMessage = '';
    @api failureMessage = '';

    @track resultMessage;

    //wire functions
    /*wireUpdateFO;
    @wire(updateFO,{encryptedToken: '$encryptedToken'})
    imperativeWiring(result) 
    {
        if (result.data && result.data === 'success') {
            this.resultMessage = this.successMessage;
            
        } else if (result.error) {
            this.resultMessage = this.failureMessage;
        }
    }
    */

    connectedCallback() {
        updateFO({
            encryptedToken: this.encryptedToken
        })
        .then((data) => {
            if(data === 'success')
            {
                this.resultMessage = this.successMessage;
            }
            else 
            {
                this.resultMessage = this.failureMessage;
            }
        })
        .catch((error) => {
            this.resultMessage = this.failureMessage;
        });
    }

}