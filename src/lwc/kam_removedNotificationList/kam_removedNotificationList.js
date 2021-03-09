import { LightningElement,wire,track } from "lwc";
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/kam_pubsub';
import getNotifications from "@salesforce/apex/kam_notifications.getRemindMe";
export default class RemovedNotificationList extends LightningElement {
    @track checker='';
    removed = false;
    @wire(CurrentPageReference) pageRef;
    @wire(getNotifications, { temp: "$checker" }) notifications;

    connectedCallback() {
		// subscribe to event
		registerListener('removelist', this.handleremovelist, this);
	}
	disconnectedCallback() {
		// unsubscribe from bearListUpdate event
		unregisterAllListeners(this);
	}
	handleremovelist(idd) {
        console.log('in event'+idd);
		this.checker=idd;
	}
    
}