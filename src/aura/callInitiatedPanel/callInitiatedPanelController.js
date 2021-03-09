/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // screen pop to the contact home, and use the call provider to make a call
    init : function(cmp, event, helper) {
        var wasSearched = cmp.get('v.wasSearched');
        console.log('wasSearched : ' + wasSearched);

        cmp.getEvent('getSettings').setParams({
			callback: function(data){
                var incomingName;
                
                if(cmp.get('v.isPrimary')) {
                    incomingName = data['/reqPhoneDemoSettings/incomingName'];
                } else {
                    incomingName = data['/reqPhoneDemoSettings2/incomingName'];
                }
                
                var incomingRingtone = data['/callRingtones/incomingRingtone'];
                var outboundRingtone = data['/callRingtones/outgoingRingtone'];

                if(incomingName != null) {
                    cmp.set('v.incomingName', incomingName);
                } else {
                    cmp.set('v.incomingName', ' ');
                }


                if(incomingRingtone != null) {
                    cmp.set('v.incomingRingtone', '/resource/' + incomingRingtone);
                } else {
                    cmp.set('v.incomingRingtone', '/resource/SlickCTI_InboundRing/SlickCTI_InboundRing.mp3');
                }

                if(outboundRingtone != null) {
                    cmp.set('v.outboundRingtone', '/resource/' + outboundRingtone);
                    console.log('outboundRingtone : ' + '/resource/' + outboundRingtone);
                } else {
                    cmp.set('v.outboundRingtone', '/resource/SlickCTI_Outbound/SlickCTI_Outbound.mp3');
                }
			}
		}).fire();
    },

    // On incoming calls, this is a handler for the Accept button
    accept : function(cmp, event, helper) {
        helper.renderConnectedPanel(cmp);
    },

    // On incoming calls, this is a handler for the Decline button
    // taking you back to the phone panel
    decline : function(cmp, event, helper) {
        cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'warning', 'message': 'Call was declined.'},
            attributes : { presence : cmp.get('v.presence') }
        }).fire();
    },

    // On dialing calls, this is a handler for the End button
    // taking you back to the phone panel
    end : function(cmp, event, helper) {
        cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'Call was ended.'},
            attributes : { presence : cmp.get('v.presence') }
        }).fire();
    },
})