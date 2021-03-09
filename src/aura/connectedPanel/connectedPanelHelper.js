/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // log a task for the call
    logCall : function(cmp) {
        var component = cmp;
        console.log('seconds : ' + cmp.find("ticker").get("v.seconds"));
        var theRecordId = component.get('v.recordId');

        cmp.find("ticker").getDurationInSeconds(function(duration) {
            duration = Math.round(duration);

            var action = component.get("c.createMyTask");
            action.setParams({
                "theId": theRecordId,
                "myDescription": component.find('note').get('v.value')
            });
            action.setCallback(this, function(a) {
                console.log('Task Created : ' + a.getReturnValue());

                console.log(cmp.get('v.popTask'));
                if(cmp.get('v.popTask') == 'true') {
                    sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, params: { recordId: a.getReturnValue() }, callback: function() {
                        console.log('Popped the task');
                    }});
                }

                cmp.getEvent('renderPanel').setParams({
                    type : 'c:phonePanel',
                    toast : {'type': 'normal', 'message': 'Call was ended.'},
                    attributes : { presence : cmp.get('v.presence')}
                }).fire();
            });
            $A.enqueueAction(action);
        });
    },

    popItems : function(component) {
        var recordId = component.get('v.recordId');
        var popNewCase = component.get('v.popCase');
        var popNewLead = component.get('v.popLead');
        var url1 = component.get('v.url1');
        var url2 = component.get('v.url2');
        var telephoneNumber = component.get('v.telephone');

        if(popNewCase == 'true') {
            if(recordId == null) {
                recordId = ' ';
            }
            var action = component.get("c.createMyCase");
            action.setParams({
                "targetId": recordId
            });
            action.setCallback(this, function(a) {
                var result = a.getReturnValue();
                if(result.length == 15 || result.length == 18) {
                    sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, params: { recordId: a.getReturnValue() }, callback: function() {
                        console.log('screen pop worked!');
                    }});
                }
            });
            $A.enqueueAction(action);
        }

        if(popNewLead == 'true') {
            var action = component.get("c.createMyLead");
            action.setParams({
                "telephoneNumber": telephoneNumber
            });
            action.setCallback(this, function(a) {
                var result = a.getReturnValue();
                if((result.length == 15 || result.length == 18) && result != null) {
                    sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, params: { recordId: a.getReturnValue() }, callback: function() {
                        console.log('screen pop worked!');
                    }});
                }
            });
            $A.enqueueAction(action);
        }


        if(url1 != null && url1.length > 0) {
            sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: url1 }, callback: function() {
                console.log('screen pop worked!');
            }});
        }

        if(url2 != null && url1.length > 0) {
            sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: url2 }, callback: function() {
                console.log('screen pop worked!');
            }});
        }

    },
    
    
    doTheInitialCallStuff: function(component) {
        console.log('doTheInitialCallStuff');
        var popNewCase_2 = component.get('v.popCase_2');
        var popNewLead_2 = component.get('v.popLead_2');
        var recordId = component.get('v.recordId');
        var url1_2 = component.get('v.url1_2');
        var url2_2 = component.get('v.url2_2');
        var telephoneNumber = component.get('v.telephone');
        
        console.log('popNewCase_2 : ' + popNewCase_2);
        console.log('popNewLead_2 : ' + popNewLead_2);
        
        if(popNewCase_2 == 'true') {
            if(recordId == null) {
               recordId = ' ';
            }
            var action = component.get("c.createMyCase");
            action.setParams({
               "targetId": recordId
            });
           	action.setCallback(this, function(aa) {
           		var result = aa.getReturnValue();
           		if(result.length == 15 || result.length == 18) {
                 	sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, params: { recordId: aa.getReturnValue() }, callback: function() {
                       console.log('screen pop worked!');
                  	}});
           		}
           });
           $A.enqueueAction(action);
        }
        
        if(popNewLead_2 == 'true') {
        	var action = component.get("c.createMyLead");
            action.setParams({
               "telephoneNumber": telephoneNumber
            });
            action.setCallback(this, function(a) {
                console.log('GOT INTO CALLBACK');
               var result = a.getReturnValue();
               if(result.length == 15 || result.length == 18) {
                  sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, params: { recordId: a.getReturnValue() }, callback: function() {
                    console.log('screen pop worked!');
                  }});
               }
            });
            $A.enqueueAction(action);
         }

         if(url1_2 != null && url1_2.length > 0) {
         	sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: url1_2 }, callback: function() {
              	console.log('screen pop worked!');
            }});
         }

         if(url2_2 != null && url2_2.length > 0) {
            sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: url2_2 }, callback: function() {
               console.log('screen pop worked!');
            }});
        }
	}
    
    

})