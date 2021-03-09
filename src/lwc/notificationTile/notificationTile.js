import { LightningElement,api } from 'lwc';

export default class NotificationTile extends LightningElement {
    @api notification;
    @api removed;

    get pClass() {
        let colour;
        if(this.notification.Priority__c=='Medium'){
            colour='slds-m-bottom_xx-small orange tile';
        }else if(this.notification.Priority__c=='Low'){
            colour='slds-m-bottom_xx-small green tile';
        }else{
            colour='slds-m-bottom_xx-small red tile';
        }
        return colour;

    }
    handleOpenRecordClick() {
        let objId;
        if(this.notification.Notification_origin__c==null){
            objId=this.notification.Id
        }else{
            objId=this.notification.Notification_origin__c;
        }
        const selectEvent = new CustomEvent('tonotification', {
            detail: objId
        });
        this.dispatchEvent(selectEvent);
    };

    handleRemindMeLater() {
        console.log('not here');
        const selectEvent = new CustomEvent('remindme', {
            detail: this.notification.Id
        });
        this.dispatchEvent(selectEvent);
    }
}