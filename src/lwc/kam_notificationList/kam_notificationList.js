import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/kam_pubsub';
import { LightningElement, wire,track } from "lwc";

import getNotifications from "@salesforce/apex/kam_notifications.getAllNotifications";
import updNotifications from "@salesforce/apex/kam_notifications.updRemindMe";
export default class notificationList extends NavigationMixin(LightningElement) {
    removed = true;
    @track notifications;
    
    @wire(CurrentPageReference) pageRef;
    @wire(getNotifications)
    wiredNotifications(result) {
        this.notifications = result;
    }
	appResources = {
		bearSilhouette: 'https://w1.pngwave.com/png/887/970/446/ui-icon-notification-icon-bell-icon-yellow-sign-png-clip-art.png',
    };

    handleNotificationView(event) {
		// Get bear record id from bearview event
        const notificationId = event.detail;
        console.log('in there');
		// Navigate to bear record page
	    this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: notificationId,
				actionName: 'view',
			},
        });
    }

    handleRemoveEvent(event){
        const notificationId = event.detail;
        console.log(notificationId);
        updNotifications({idd : notificationId})
            .then(result => {
                this.notifications.data = result;
                console.log(result);
                fireEvent(this.pageRef, 'removelist', notificationId);
            })
            .catch(error => {
                console.log('error'+error);
            });

    }
    
	/*connectedCallback() {
		this.loadNotifications();
	}
	loadNotifications() {
		getNotifications()
			.then(result => {
				this.notifications = result;
			})
			.catch(error => {
				this.error = error;
			});
	}*/
}