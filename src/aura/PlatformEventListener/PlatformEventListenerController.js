({
    
    onCometdLoaded : function(component, event, helper) {
        var cometd = new org.cometd.CometD();
        component.set('v.cometd', cometd);
        if (component.get('v.sessionId') != null) {
            helper.connectCometd(component);
        }
        
    },
    
    onInit : function(component, event, helper) {
        
        //generate a unique id for the chart so that many charts can exist on the same page without conflict
        let chartId  = "chart" + Math.round(Math.random() * 10000);
        component.set("v.chartId", chartId);
        
        helper.loadFields(component, event, helper);
        
        /*
       component.set('v.cometdSubscriptions', []);
        
    
        
        // Disconnect CometD when leaving page
        window.addEventListener('unload', function(event) {
            helper.disconnectCometd(component);
        });
        
      
        
        // Retrieve session id
        var action = component.get('c.getSessionId');
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                component.set('v.sessionId', response.getReturnValue());
                if (component.get('v.cometd') != null)
                    helper.connectCometd(component);
            }
            else
                console.error(response);
        });
        $A.enqueueAction(action);
        */
        var myEventHub = component.find('SampleEventListenerHub');
        
        // The arguments to subscribe are:
        //     component - this lightning component.  component will be
        //         passed into the callback so that it has access to 
        //         get/set attributes
        //     eventName - the simple name of the Platform Event to which
        //         you are subscribing. Include the '__e' suffix
        //     callback - the callback routine to be invoked when the 
        //         Platform event occurs.  IMPORTANT:  Use the exact syntax
        //         provided here to avoid problems with scope and problems
        //         with asynchronous actions in the callback.
        myEventHub.subscribe(
            component, 
            component.get("v.eventName"), 
            $A.getCallback(function(component, platformEvent) {
                let title = component.get('v.title');
                
                 let deviceId = component.get('v.deviceId');
                let recordId = component.get('v.recordId');
                
                
                 let eventDataList = component.get("v.eventDataList");
                let payload = platformEvent.data.payload;
            
                if(deviceId != null && recordId != null) {
                    
                    let dataId =  payload[deviceId];
                   if(dataId == null) {
                        helper.displayToast(component, "warning", "Unable to find event key field " + deviceId + ". Please have the administrator check the configuration on chart '" + title + "'.");
               			return;
                   }
                    if(dataId != recordId) {
                        return;
                    } 
                }
			                
                //console.log('Platform event ' + title + ' received: '+ JSON.stringify(platformEvent));
                
               
                eventDataList.push(payload);
                
                component.set("v.payload", payload);
            })
        );
        
    },
    
    toggleOptions : function(component, event, helper) {	
        
        
        let el = component.find("options-container");
        $A.util.toggleClass(el, "hidden");    
        
        let optionsLabel  = component.get("v.optionsLabel");
        optionsLabel = optionsLabel === "Show Options" ? "Hide Options" : "Show Options";
        component.set("v.optionsLabel", optionsLabel); 
        
        
    },
    updateLabel : function(component, event, helper) {
        helper.saveLabel(component, event, helper);
    }
    
    
    
    
})