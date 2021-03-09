(
    {
        doInit : function(component, event, helper) {
            component.set('v.cardLabel','Einstein Discovery')
            console.log('updateData');
            var action = component.get("c.getEDInfo");
            action.setParams({
                "opptyId": component.get("v.recordId")
            });
            action.setCallback(component, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
                
                if (state === 'SUCCESS'){
                    
                    if(result.Exec_Meeting__c == true){
                    	document.getElementsByClassName('meetingButton')[0].style.display = 'none';
                    }
                    
                    if(result.ED_Close_Date_Delta__c < 0){
                        console.log('1st if' + result.ED_Close_Date_Delta__c);
                    	document.getElementById('plus').style.display = 'none';
                        document.getElementById('space').style.display = 'relative';
                    }
                    
                    else if(result.ED_Close_Date_Delta__c >= 0){
                        console.log('2nd if' + result.ED_Close_Date_Delta__c);
                    	document.getElementById('plus').style.display = 'relative';
                        document.getElementById('space').style.display = 'none';
                    }
                    
                    $('.slds-card__header slds-grid').hide();
                    $('#ttc').html(myUtil.round(result.ED_Outcome__c) + " Days");
                    $('#csat').html(myUtil.formatDate(result.ED_Predicted_Close_Date__c));
                    $('#diff').html(result.ED_Close_Date_Delta__c + " Days");
                    $('#leadingCauses').html(myUtil.populateTable(result.ED_Leading_Causes__c));
                    $('#recommendedImprovements').html(myUtil.populateTable(result.ED_Prescription__c));
                } 
            });
            $A.enqueueAction(action);
            
        },
        
        
        
        refresh : function(component, event, helper) {
            var action = component.get('c.getEDInfo');
            action.setCallback(component, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS'){
                    
                    $A.get('e.force:refreshView').fire();
                } else {
                    //do something
                }
            });
            $A.enqueueAction(action);
        },
        
        showModal : function(component, event, helper) {
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Event",
                'defaultFieldValues': {
                	'WhatId': component.get("v.recordId"),
                    'Type__c': 'Meeting'
          		},
                "panelOnDestroyCallback": function(){helper.panelDestroy(component);}
               
            });
            createRecordEvent.fire();
            
            
            
            var action = component.get("c.checkExecMeeting");
            action.setParams({
                "opptyId": component.get("v.recordId")
            });
            
            
            
            action.setCallback(component, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
                
                if (state === 'SUCCESS'){
                    
                    var refresh = component.get('c.getEDInfo');
                    refresh.setCallback(component, function(response) {
                         $A.get('e.force:refreshView').fire();
                    });
                    $A.enqueueAction(refresh);
                    
                } 
            });
            $A.enqueueAction(action);
            
			document.getElementsByClassName('meetingButton')[0].style.display = 'none';
            
        }
        
        
    
    })