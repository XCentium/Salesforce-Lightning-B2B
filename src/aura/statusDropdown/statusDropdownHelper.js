/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // expand the status dropdown on click
    toggleStatus: function(cmp) {
        var dropdown = cmp.find('dropdownContainer');
        $A.util.toggleClass(dropdown, 'slds-is-open');
    },

    // update the status dropdown (presence and icon)
    setStatusName: function(cmp, selectOption) {
        var newStatus = selectOption.getAttribute('data-value-name');
        var iconType = selectOption.getAttribute('data-value-iconType');
        cmp.set('v.presence', newStatus);
        this.renderIcon(cmp, iconType);
    },

    // update the status icon on the first row of the status dropdown
    renderIcon : function(cmp, iconType) {
        $A.createComponent("lightning:icon",
            {
                "class": 'slds-icon slds-icon--x-small slds-icon-text-'+iconType,
                "aura:id": "statusIcon",
                "variant": iconType,
                "size": "x-small",
                "iconName": "utility:record"
            },
            function(newIcon) {
                if (cmp.isValid()) {
                    cmp.set('v.icon', [ newIcon ]);
                }
            });
    },

    // on logout, disable click to dial and bring up the cti login panel
    handleLogout: function(cmp) {
        var callback = function(result) {
            if (result.success) {
                cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel'
                }).fire();
            } else {
                throw new Error('Click to dial cannot be disabled.');
            }
        };
        sforce.opencti.disableClickToDial({
            callback: callback
        });
    },

    // set the panel label by firing the editPanel event
    setLabel: function (cmp, label) {
        cmp.getEvent('editPanel').setParams({
                label: label
        }).fire();
    },

    // notify the phone panel that the presence has changed
    notifyPhonePanel: function(cmp, helper, newStatus) {
        cmp.getEvent('onlinePresenceChanged').setParams({
            newStatus: newStatus
        }).fire();
    },







    connectCometd: function(component) {
        try {
            var helper = this;
            // Configure CometD
            var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/40.0/';
            var cometd = component.get('v.cometd');

            cometd.configure({
                url: cometdUrl,
                requestHeaders: {
                    Authorization: 'OAuth ' + component.get('v.sessionId')
                },
                appendMessageTypeToURL: false
            });
            cometd.websocketEnabled = false;
            cometd.handshake(function(handshakeReply) {
                if (handshakeReply.successful) {
                    console.log('Connected to CometD.');
                    // Subscribe to platform event
                    var newSubscription = cometd.subscribe('/event/CTI_Status_Changed__e',
                        function(platformEvent) {
                            // console.log('Platform event received: ' + JSON.stringify(platformEvent));
                            helper.statusReceived(component, helper, platformEvent);
                        }
                    );
                    // Save subscription for later
                    var subscriptions = component.get('v.cometdSubscriptions');
                    subscriptions.push(newSubscription);
                    component.set('v.cometdSubscriptions', subscriptions);
                } else
                    console.error('Failed to connected to CometD.');
            });
        } catch(exp) {
            console.log('exception : ' + exp);
        }
    },
    disconnectCometd: function(component) {
        var cometd = component.get('v.cometd');
        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            var subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function(subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);
        // Disconnect CometD
        cometd.disconnect();
        console.log('CometD disconnected.');
    },
    onReceiveNotification: function(component, platformEvent) {
        var helper = this;
        // Extract notification from platform event
        var newNotification = {
            time: $A.localizationService.formatDateTime(
                platformEvent.data.payload.CreatedDate, 'HH:mm'),
            message: platformEvent.data.payload.Status__c
        };
        // Save notification in history
        var notifications = component.get('v.notifications');
        notifications.push(newNotification);
        component.set('v.notifications', notifications);
        // Display notification in a toast if not muted
        if (!component.get('v.isMuted'))
            helper.displayToast(component, 'info', newNotification.message);
    },
    displayToast: function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    statusReceived : function(component, helper, platformEvent) {
        var status = platformEvent.data.payload.Status__c;
        var target = platformEvent.data.payload.Target__c;

        if(target == 'statusDropdown') {
            if(status == 'available') {
                var newStatus = 'Available';
                var iconType = 'success';
                component.set('v.presence', newStatus);
                this.renderIcon(component, iconType);

                helper.setLabel(component, 'Open CTI Softphone: Available');
                helper.notifyPhonePanel(component, helper, 'Available');
            }

            if(status == 'busy') {
                var newStatus = 'Busy';
                var iconType = 'warning';
                component.set('v.presence', newStatus);
                this.renderIcon(component, iconType);

                helper.setLabel(component, 'Open CTI Softphone: Busy');
                helper.notifyPhonePanel(component, helper, 'Busy');
            }
        }
    },

    fireStatusChangedEvent : function(component, selectedOption) {
        var option = selectedOption.getAttribute('data-value-name');
        var message = '';

        if(option == 'Available') {
            message = 'available';
        } else {
            message = 'busy';
        }

        var myArray = [];
        myArray.push(message);

        var action = component.get("c.publishNotifications");
        action.setParams({
            "messages": myArray,
            "target": 'Omni_CTI_Sync'
        });
        action.setCallback(this, function(a) {
            console.log('returned');
        });
        $A.enqueueAction(action);
    }
})