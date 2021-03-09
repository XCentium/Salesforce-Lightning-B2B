({
	    
	doInit : function(component, event, helper) {
         // console.log("Loading IoT Simulator Component ");
       
        var deviceId =  component.get("v.deviceId");
        if(deviceId == null || deviceId.length == 0) {return;}
        
 		if(!deviceId.includes("__c")) {
              //  console.log("deviceId (" + deviceId + ") does not include __c");
                helper.displayToast(component, "error", "deviceId (" + deviceId +") name should be the API name (including '__c')");
            return;
        }
        
        var eventName =   component.get("v.eventName");
         if(eventName == null || eventName.length == 0) {return;}
 		if(!eventName.includes("__e")) {
              //  console.log("event name (" + eventName + ") does not include __e");
                helper.displayToast(component, "error", "event name (" + eventName + ")  should be the API name (including '__e')");
            return;
        }
        
      	helper.getEventFields(component, event, helper);
        
        var objectName =  component.get("v.objectName");

        if(objectName != null && objectName.length > 0) {  
             
            if(!objectName.includes("__c")) {
               // console.log("__c not included");
                helper.displayToast(component, "error", "object name (" + objectName + ") should be the API name (including '__c')");
            }
            
        	helper.getParentLookup(component, event, helper);
        }      
            
    },
    handleSend : function(component, event, helper) {
		 //console.log("Handle Send");
        
        var recordId = component.get("v.recordId");
        var inputKey = component.get("v.deviceId");  
        var eventName = component.get("v.eventName");
        var objectFields = component.get("v.objectFields");
      
        var itemId = null;
         var action = null;
        
     /***** Generate Platform Event ********/
      	var eventMsg = "{\"sobjectType\":\"" + eventName + "\",\"" + inputKey + "\":\"" + recordId  + "\"";	 
        for(var i=0; i< objectFields.length; i++) {
             itemId = document.getElementById(objectFields[i]);
             eventMsg = eventMsg +  ",\"" + objectFields[i] + "__c\": \"" + itemId.value + "\"";  
        }
 		eventMsg = eventMsg + "}";
        
        var objectName = component.get("v.objectName");
        var parentField = component.get("v.parentField"); 
        var objVal = null;
        
        if(objectName != null && objectName.length > 0) {
            
               /***** Persist Event Data ********/
            objVal = "{\"sobjectType\":\"" + objectName + "\",\"" + inputKey + "\":\"" + recordId  + "\"";
          
            for(var i=0; i< objectFields.length; i++) {
                 itemId = document.getElementById(objectFields[i]);
                objVal = objVal +  ",\"" + objectFields[i] + "__c\": \"" + itemId.value + "\"";  
            }
            
            if(parentField != null) {
            	objVal = objVal +  ",\"" + parentField + "\": \"" + recordId + "\"";
           	}
            
            objVal = objVal + "}";
            
            component.set("v.objectValue", objVal);
        	objVal = component.get("v.objectValue");
            
           // console.log("Publish and Persist");
             action = component.get("c.publishAndPersistEvent");
            
        } else {
          //   console.log("Publish Only");
               action = component.get("c.publishEvent");
        }
 		
        
        console.log("Sending Event to IOT cloud");
         console.log(eventMsg);
       
		action.setParams({
            objValue : objVal,
            eventValue : eventMsg
    	});

    	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
              //  console.log("Sending IOT Event Success! ");
                
            } else if (a.getState() === "ERROR") {
                 console.log("Sending IOT Event Failed! ");
                console.log( a.getError());
                //$A.log("Errors", a.getError());
                  helper.displayToast(component, "error", "Sending IOT Event Failed! " + a.getError());
            }
   		});

    	$A.enqueueAction(action);
     
    },
      selectTab1 : function(component, event, helper) {
         helper.selectTab(component, 1);
      },
      selectTab2 : function(component, event, helper) {
          helper.selectTab(component, 2);
          

      },
      selectTab3 : function(component, event, helper) {
           helper.selectTab(component, 3);
      },
     save : function(component, event, helper) {
         
          var spinner = component.find("eventSpinner");
        $A.util.toggleClass(spinner, "slds-show");
         
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   
        if (file.size > 750000) {
            alert('File size cannot exceed ' + 750000 + ' bytes.\n' + 'Selected file size: ' + file.size);
    	    return;
        }
    
        var fr = new FileReader();
        
       
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';

    	    helper.sendCsvToIoT(component, fileContents, helper);
    	   
    		
    	  
        };

      fr.readAsText(file);
    }
        
})