/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    doInit : function(component, event, helper) {
        component.getEvent('getSettings').setParams({
            callback: function(data) {
                var adapterUrl = data['/reqGeneralInfo/reqAdapterUrl'];
                console.log('adapterUrl : ' + adapterUrl);
                var action = component.get("c.getTheDomainName");
                action.setCallback(this, function(a) {
                    var baseUrl = a.getReturnValue();
                    console.log('baseUrl : ' + baseUrl);
                    helper.doCompare(component,adapterUrl, baseUrl);
                });
                $A.enqueueAction(action);
                
                component.set('v.primaryIcon', 'utility:' + data['/buttonIcons/primaryIcon']);
                component.set('v.secondaryIcon', 'utility:' + data['/buttonIcons/secondaryIcon']);
            }
        }).fire();
    },


    // bring up the help window
    showModal : function(cmp, event, helper) {
        // TODO: Try not to reference `document`.
        document.getElementById('backGroundSectionId').style.display = 'block';
    },

    // close the help window
    showHelp : function(cmp, event, helper) {
        // TODO: Try not to reference `document`.
        document.getElementById('backGroundSectionId').style.display = 'none';
    },

    // get the incoming phone number from call center settings, then if there's a matching record
    // bring up a call panel with the record details.
    simulateIncomingCall : function(cmp, event, helper) {
        cmp.getEvent('getSettings').setParams({
            callback: function(data){
                let incomingNumber = data['/reqPhoneDemoSettings/reqIncomingNumber'];

                console.log('Incoming Number', incomingNumber);

                cmp.getEvent('renderPanel').setParams({
                    type : 'c:callInitiatedPanel',
                    attributes : {
                        'state' : 'Incoming',
                        'recordName' : '',
                        'phone' : incomingNumber,
                        'title' : '',
                        'account' : '',
                        'recordId' : '',
                        'presence' : cmp.get('v.presence'),
                        'isPrimary': true
                    }
                }).fire();
            }
        }).fire()
    },
    
    simulateIncomingCall2 : function(cmp, event, helper) {
        cmp.getEvent('getSettings').setParams({
            callback: function(data){
                let incomingNumber = data['/reqPhoneDemoSettings2/reqIncomingNumber'];

                console.log('Incoming Number', incomingNumber);

                cmp.getEvent('renderPanel').setParams({
                    type : 'c:callInitiatedPanel',
                    attributes : {
                        'state' : 'Incoming',
                        'recordName' : '',
                        'phone' : incomingNumber,
                        'title' : '',
                        'account' : '',
                        'recordId' : '',
                        'presence' : cmp.get('v.presence'),
                        'isPrimary': false
                    }
                }).fire();
            }
        }).fire()
    },
})