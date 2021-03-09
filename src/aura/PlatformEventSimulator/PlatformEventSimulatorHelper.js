({
 getEventFields : function(component, event, helper) {
         //console.log("- Init loading IoT Event object fields");
        
         var action = component.get("c.getEventFields");
		action.setParams({
        	eventName : component.get("v.eventName")
    	});

    	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
              //  console.log("Loaded Event Object Fields");
                //console.log(a.getReturnValue());
                var fieldsNames = a.getReturnValue();
                var deviceKey = component.get("v.deviceId");
            
               var index = fieldsNames.indexOf(deviceKey.substring(0, deviceKey.length-3));
            	//console.log(index);
                 if (index > -1) {
                    fieldsNames.splice(index, 1);
                }
                
                component.set("v.objectFields", fieldsNames);
              
            } else if (a.getState() === "ERROR") {
                 console.log("Loading Event Object Fields Failed! ");
               //  console.log(a.getError());
                $A.log("Errors", a.getError());
                  helper.displayToast(component, "error", "Loading Event Object Fields Failed! " + a.getError());
            }
   		});

    	$A.enqueueAction(action);
     
        
    },
    getParentLookup : function(component, event, helper) {
    	
        var action = component.get("c.getLookupFieldName");
		action.setParams({
        	objectName : component.get("v.objectName"),
            recordId : component.get("v.recordId")
    	});

    	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
              //  console.log("Loaded Parent Object lookup field");
              //  console.log(a.getReturnValue());
                var parentName = a.getReturnValue();
                component.set("v.parentField", parentName);
 
            } else if (a.getState() === "ERROR") {
                 console.log("Loading Parent Object lookup Failed! ");
              //   console.log(a.getError());
                $A.log("Errors", a.getError());
                helper.displayToast(component, "error", "Loading Parent Object lookup Failed! " + a.getError());
            }
   		});

    	$A.enqueueAction(action);
        
    },
    
    selectTab : function(component, tabNum) {
        // console.log("Selected tab " + tabNum);
        
        var tabList = [];
        tabList[0] =  component.find('tab-default-1');
        tabList[1] =  component.find('tab-default-2');
        //  tabList[2] =  component.find('tab-default-3');
        
        var contentList = [];
        contentList[0] =  component.find('tab-content-1');
        contentList[1] =  component.find('tab-content-2');
        //  contentList[2] =  component.find('tab-content-3');
        
        for(var i=0; i<tabList.length; i++ ) {
            $A.util.removeClass(tabList[i], 'slds-is-active'); 
        }
        $A.util.addClass(tabList[tabNum-1], 'slds-is-active');
        
        for(var i=0; i<contentList.length; i++ ) {
            $A.util.removeClass(contentList[i], 'slds-show'); 
            $A.util.addClass(contentList[i], 'slds-hide');
        }
        $A.util.removeClass(contentList[tabNum-1], 'slds-hide');
        $A.util.addClass(contentList[tabNum-1], 'slds-show');
        
    },
    upload: function(component, fileContents, helper) {
        var action = component.get("c.saveTheFile"); 
        
        action.setParams({
            parentId: component.get("v.recordId"),
            base64Data: encodeURIComponent(fileContents), 
            objectName: component.get("v.objectName"),
            url : component.get("v.url"),
            token : component.get("v.token")
        });
        
        action.setCallback(this, function(a) {
            console.log("Success! File loaded.");
            helper.sendCsvToIoT(component, fileContents, helper);
        });
        
          $A.enqueueAction(action); 
        
    },
    sendCsvToIoT: function(component, fileContents, helper) {
         
        console.log("---Converting CSV---");
        
        var inputKey = component.get("v.deviceId");
        var recordId = component.get("v.recordId");
        
        var lines=fileContents.split("\n");
        var result = []; 
        var headers=lines[0].split(",");
        
        var timestamp=0;
        var sendToIoTMsg = function (cmp, fieldList, iotData) {   
          
          // console.log("Timeout ended, sending IOT Event "  + " " + iotData);
            helper.sendToIOT(cmp, fieldList, iotData);
        }   

        var timestamp;
        
       //  console.log("---Starting loop---");
        for(var i=1;i<lines.length;i++){
            var obj = {};
            var currentline=lines[i].split(",");  
            
            obj[inputKey] = recordId;
            
            for(var j=0;j<headers.length;j++){
               //console.log(headers[j] );
                if(headers[j].includes("IOTtimestamp")) {
                     
                    timestamp = timestamp +  currentline[j]*1000;
                	
                } else {
               	 obj[headers[j]] = currentline[j];
                 }
            }
           
            console.log("---Sending timeout " + timestamp);
            setTimeout(sendToIoTMsg,  timestamp, component, headers, obj);
          
        }       
       
        
        return ; //JSON
    },
    
    sendToIOT : function(component, fieldList, iotMsg) {
        console.log("---Sending IoT Msg ---");
        var spinner = component.find("eventSpinner");
        $A.util.toggleClass(spinner, "slds-show");
       // console.log(iotMsg);
        
       //    console.log("---getting data ---");
        var recordId = component.get("v.recordId");
        var inputKey = component.get("v.deviceId");
         var eventName = component.get("v.eventName");
        
        var action = null;
    
      /***** Generate Platform Event ********/     
        var eventMsg = "{\"sobjectType\":\"" + eventName + "\",\"" + inputKey + "\":\"" + recordId  + "\"";    
 		for(var i=0; i< fieldList.length; i++) {   
			var header = fieldList[i];             
            eventMsg = eventMsg +  ",\"" + header + "__c\": \"" + iotMsg[header] + "\"";
        }  
        eventMsg = eventMsg + "}";
 	   
        console.log(eventMsg);
        
        /***** Persist Event Data ********/
         var objectName = component.get("v.objectName");
        var parentField = component.get("v.parentField"); 
        var objVal = null;
        
         if(objectName != null && objectName.length > 0) {
               objVal = "{\"sobjectType\":\"" + objectName + "\",\"" + inputKey + "\":\"" + recordId  + "\"";
           
            for(var i=0; i< fieldList.length; i++) {      
                var header = fieldList[i];           
                objVal = objVal +  ",\"" + header + "__c\": \"" + iotMsg[header] + "\"";  
             
            }
             if(parentField != null) {
            	objVal = objVal +  ",\"" + parentField + "\": \"" + recordId + "\"";
           	}
            
            objVal = objVal + "}";
             action = component.get("c.publishAndPersistEvent");
            
        } else {
               action = component.get("c.publishEvent");
        }
 		
		action.setParams({
           eventValue : eventMsg,
            objValue : objVal         
    	});

        
    	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log("Sending IOT Event Success! ");
                
            } else if (a.getState() === "ERROR") {
                 console.log("Sending IOT Event Failed! ");
               //  console.log(a.getError());
                $A.log("Errors", a.getError());
            }
   		});

          
    	$A.enqueueAction(action);
        
    },
     displayToast : function(component, type, message) {
        
     //   console.log(message);
            $A.createComponents([
                ["ui:message",{ "title" : "Error",  "severity" : type, }],
                ["ui:outputText",{ "value" : message}]
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        var message = components[0];
                        var outputText = components[1];
                        // set the body of the ui:message to be the ui:outputText
                        message.set("v.body", outputText);
                        var div1 = component.find("msgDiv");
                        // Replace div body with the dynamic component
                        div1.set("v.body", message);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
                }
            );
        
    }
})