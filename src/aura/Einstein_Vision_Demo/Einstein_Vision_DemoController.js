({
    doInit : function(component, event, helper) {
        console.log('Einstein_Vision_Demo:doInit');
        
        //Label the card
        component.set("v.cardLabel", component.get("v.title"));
                
        // Signal to EinsteinPlatform_Card base component that we have data
        component.set('v.hasData', true);
                
    },
    
    recordUpdated: function(component, event, helper) {
        console.log('Einstein_Vision_Demo:recordUpdated');
        
        var leadobj = component.get("{!v.leadRecord}");
        console.log(leadobj);
        
        // Verify there is a street address.  This demo does not actually use the street address,
        // but it would look funny if we predicted a roof type without an address.
        if (leadobj.Street) {
            component.set('v.positionKnown', true);
        } else {
            helper.handleErrors ([{message: "Address has not been defined for this Lead"}]);
        }

        // Verify Shadow_Roof_Type.  This field indicates the type of
        // roof image that should be returned.                
        if (!leadobj.Shadow_Roof_Type__c) {
            console.log('No roof type');
            helper.handleErrors ([{message: "Shadow_Roof_Type__c undefined. See https://salesforce.quip.com/KGIkAUtj7drL for instructions"}]);
        }
        
    },
    
    findHouse : function(component, event, helper) {
        console.log('Einstein_Vision_Demo:findHouse');
        component.set('v.showImage', true);   
    },
    
    analyzeRooftype : function(component, event, helper) {
        console.log('Einstein_Vision_Demo:analyzeRooftype');
        
        var thisLead = component.get('{!v.leadRecord}');
        console.log('thisLead:');
        console.log(thisLead.Roof_Type__c);
        console.log(thisLead.Shadow_Roof_Type__c);
        if (thisLead != null && thisLead.Shadow_Roof_Type__c != null){
            thisLead.Roof_Type__c = thisLead.Shadow_Roof_Type__c;
        }

        console.log('local updated');
        
        component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            console.log('saved');
            component.set('{!v.showResults}', true);
            // use the recordUpdated event handler to handle generic logic when record is changed
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
        
        component.find("recordLoader").reloadRecord (true, $A.getCallback(function(reloadResult) {
            console.log('reloaded');
        }));
        
        component.set('{!v.showResults}', true);
    }
})