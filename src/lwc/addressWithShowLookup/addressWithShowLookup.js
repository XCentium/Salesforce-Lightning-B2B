import { LightningElement, api } from 'lwc';




export default class AddressWithShowLookup extends LightningElement {

    @api myCardTitle="";
    @api myState="";
    @api myStreet="";
    @api myCity="";
    @api myCountry="";
    @api myPostalCode="";
    @api addressFieldHelp="";
    @api addressLabel="";


    handleChange(event){

this.myState = event.detail.province;
this.myStreet = event.detail.street;
this.myCity = event.detail.city;
this.myCountry = event.detail.country;
this.myPostalCode = event.detail.postalCode;



    }


}