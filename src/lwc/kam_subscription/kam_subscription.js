import { LightningElement,track } from 'lwc';

export default class Demo_subscription extends LightningElement {
    @track value = ''; 

    get options() {
        return [
            { label: 'Weekly', value: 'option1' },
            { label: 'Monthly', value: 'option2' },
            { label: 'Quaterly', value: 'option3' },
        ];
    }
}