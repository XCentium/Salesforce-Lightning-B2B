({
    connectCometd : function(component) {
        var helper = this;
        
        // Configure CometD
        // Register streaming extension
  
        var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
        var cometd = component.get('v.cometd');
        cometd.configure({
            url: cometdUrl,
            requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
            appendMessageTypeToURL : false
        });
        cometd.websocketEnabled = false;
         let title = component.get('v.title');
        console.log('Connecting to CometD: '+ title + ' ' + cometdUrl);

        helper.handshake(component);
        
    },
    
    handshake : function(component) {
       // console.log("New Handshake");
        var cometd = component.get('v.cometd');
        var helper = this;
        // Establish CometD connection
        
        
        var _connected = false;
        let  metaConnectListener = cometd.addListener('/meta/connect', function(message) {        
            if (cometd.isDisconnected()) {
                 let title = component.get('v.title');
                console.log('Disconnected: '+ title + ' ' +JSON.stringify(message)+'');
                return;
            }
            
            var wasConnected = _connected;                
            _connected = message.successful;
            
            if (!wasConnected && _connected) {
                console.log('DEBUG: Connection Successful : '+JSON.stringify(message)+'');                    
            } else if (wasConnected && !_connected) {
                console.log('DEBUG: Disconnected from the server'+JSON.stringify(message)+'');
            }
        }); 
        
        
        
        let   metaDisconnectListener = cometd.addListener('/meta/disconnect', function(message) {  
            console.log('DEBUG: /meta/disconnect message: '+JSON.stringify(message));
        });
        
        
        
        let   metaHandshakeListener = cometd.addListener('/meta/handshake', function(message) {
            if (message.successful) {
                console.log('DEBUG: Handshake Successful: '+JSON.stringify(message));                            
                
            } else
                console.error('DEBUG: Handshake Unsuccessful: '+JSON.stringify(message));
        });
        
        
        
        let   metaSubscribeListener = cometd.addListener('/meta/subscribe', function(message) {  
            if (message.successful) {
                console.log('DEBUG: Subscribe Successful '+': '+JSON.stringify(message));
            } else {
                console.error('DEBUG: Subscribe Unsuccessful '+': '+JSON.stringify(message));                
            }    
        });     
        
        let    metaUnSubscribeListener = cometd.addListener('/meta/unsubscribe', function(message) {  
            if (message.successful) {
                console.log('DEBUG: Unsubscribe Successful '+JSON.stringify(message));
            } else {
                console.error('DEBUG: Unsubscribe Unsuccessful '+JSON.stringify(message));                
            }
        });    
        
        
        // notifies any failures
        
        let  metaUnSucessfulListener = cometd.addListener('/meta/unsuccessful', function(message) {  
            console.error('DEBUG:  /meta/unsuccessful Error: '+JSON.stringify(message));
        });
        
         let showHistorical = component.get("v.showHistorical");
        if(showHistorical) {
            helper.getHistorical(cometd, component);
        }
        
        cometd.handshake(function(handshakeReply) {
             let title = component.get('v.title');
            if( component.get('v.cometdSubscribed') == true) {
                  
                console.log("Already subscribed " + title);
                return;
            }
           
            if (handshakeReply.successful) {
                  
                console.log('Connected to CometD. ' + title);
                // Subscribe to platform event
                
                component.set('v.cometdSubscribed', true);
                var newSubscription = cometd.subscribe('/event/' + component.get("v.eventName"),
                                                       function(platformEvent) {
                                                           let title = component.get('v.title');
                                                           console.log('Platform event ' + title + ' received: '+ JSON.stringify(platformEvent));
                                                           
                                                           let eventDataList = component.get("v.eventDataList");
                                                           let payload = platformEvent.data.payload;
                                                           eventDataList.push(payload);
                                                           
                                                           component.set("v.payload", payload);
                                                       }
                                                      );
                
                
                
                /*      // Save subscription for later
                var subscriptions = component.get('v.cometdSubscriptions');
                subscriptions.push(newSubscription);
                component.set('v.cometdSubscriptions', subscriptions);
                */
            }
            else {
                console.error('Failed to connected to CometD.');
            }
        });
        
    },
    
    getHistorical : function(cometd, component) {
        
        var cometdReplayExtension = function() {
            var REPLAY_FROM_KEY = "replay";
            
            var _cometd;
            var _extensionEnabled;
            var _replay;
            var _channel;
            
            this.setExtensionEnabled = function(extensionEnabled) {
                _extensionEnabled = extensionEnabled;
            }
            
            this.setReplay = function (replay) {
                _replay = parseInt(replay, 10);
            }
            
            this.setChannel = function(channel) {
                _channel = channel;
            }
            
            this.registered = function(name, cometd) {
                _cometd = cometd;
            };
            
            this.incoming = function(message) {
               
                if (message.channel === '/meta/handshake') {
                    if (message.ext && message.ext[REPLAY_FROM_KEY] == true) {
                        _extensionEnabled = true;
                    }
                } else if (message.channel === _channel && message.data && message.data.event && message.data.event.replayId) {
                    _replay = message.data.event.replayId;
                }
            }
            
            this.outgoing = function(message) {
               // console.log("outgoing");
               
                if (message.channel === '/meta/subscribe') {
                    if (_extensionEnabled) {
                        if (!message.ext) { message.ext = {}; }
                        
                        var replayFromMap = {};
                        replayFromMap[_channel] = _replay;
                        
                        // add "ext : { "replay" : { CHANNEL : REPLAY_VALUE }}" to subscribe message
                        message.ext[REPLAY_FROM_KEY] = replayFromMap;
                    }
                }
            };
        }; 
        
        var replayExtension = new cometdReplayExtension();
        replayExtension.setChannel('/event/' + component.get("v.eventName"));
        replayExtension.setReplay(-2);
        
        replayExtension.setExtensionEnabled(true);    
       // cometd.registerExtension('myReplayExtensionName', replayExtension);
        let extensionName = component.get("v.chartId");
        cometd.registerExtension(extensionName, replayExtension);
    },
    
    disconnectCometd : function(component) {
        var cometd = component.get('v.cometd');
        
        // Unsuscribe all CometD subscriptions
        cometd.batch(function() {
            var subscriptions = component.get('v.cometdSubscriptions');
            subscriptions.forEach(function (subscription) {
                cometd.unsubscribe(subscription);
            });
        });
        component.set('v.cometdSubscriptions', []);
        
        // Disconnect CometD
        cometd.disconnect();
        
        let title = component.get('v.title');
        console.log('CometD disconnected. ' + title);
    },
    
    onReceiveNotification : function(component, platformEvent) {
        var helper = this;
        
        // helper.displayToast(component, 'info', newNotification.message);
    },
    
    displayToast : function(component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },
      loadFields : function(component, event, helper) {
        
         let selectedEvent  = component.get("v.eventName");
            
            //to be used in fireApex callback
          let args = arguments;
     
          helper.fireApex(component,  "c.getFields", {eventName: selectedEvent}, (res) => {
                 let eventNameFieldsMap = {};
                let eventLabelsAndNames = [];
                let nameLabelMap = {};
                                  
                  let parsedResponse = JSON.parse(res);
            	//extract field names from array
             	let fieldNames = parsedResponse.map(fn => {return Object.keys(fn)[0]});
              
                // use this to create a friendlier shape, then filter out system generated fields
                //while we're in there let's make a map for setting the field label too
                let fieldNamesToLabelsMap = {};
                let selectedFields = fieldNames.map((fn, i) => {
                    fieldNamesToLabelsMap[fn] = parsedResponse[i][fn]
                    return {fieldName: fn, fieldLabel: parsedResponse[i][fn]}
                })
                .filter(fn => {return fn.fieldName.indexOf("__c") > -1})
                .reverse();
                component.set("v.fieldNamesToLabelsMap",fieldNamesToLabelsMap);
                
                //to populate field dropdown
                component.set("v.selectedFields", selectedFields);
                
                //Set the field Label for use in the title header
               
				let defaultField =  component.get("v.selectedField");
          		let defaultFieldLabel =  component.get("v.selectedEventLabel");
           
         		if(selectedFields.length > 0 && (defaultField == null || defaultField.length==0)) {   
                	
                     defaultField = selectedFields[0].fieldName;
                     component.set("v.selectedField", defaultField);
                     component.set("v.selectedEventLabel", selectedFields[0].fieldLabel);
                  
                } else {
                   helper.saveLabel(component, event, helper);
                }
          			
              
        	}); 
         
     },
  
     fireApex : function(component, ApexFunctionName, params, option ){
       // console.log("Fire APEX");
      // let [component, event, helper] = args;
       
     //   console.log(ApexFunctionName) ;
       //  console.log(params) ;
         // console.log(component) ;
         
         let action = component.get(ApexFunctionName);
        action.setParams(params);
          
        action.setCallback(this, function(a) {
            if(a.getState() === 'ERROR'){
                console.log("There was an error:");
                console.log(a.getError());
            } else if (a.getState() === 'SUCCESS'){
               // console.log("Fire APEX Success");
                if(typeof option === "string"){
                    component.set(option, a.getReturnValue());
                }else{
                    option(a.getReturnValue());
                }
                //console.log(a.getReturnValue())	;
            }
            
        });
         //  console.log("Send Acount");
        $A.enqueueAction(action); 
    },
        saveLabel : function(component, event, helper) {
        	let selectedFields = component.get("v.selectedFields");
            let defaultField = component.get("v.selectedField");
            let foundLabel = false;
            for(var i=0; i<selectedFields.length; i++) {
                        if(selectedFields[i].fieldName == defaultField) {
                            component.set("v.selectedEventLabel", selectedFields[i].fieldLabel);
                            foundLabel = true;
                 }
              }
            if(foundLabel == false) {
                let title = component.get("v.title");
                helper.displayToast(component, "warning", "Unable to find default field " + defaultField + ". Please have the administrator check the configuration on chart '" + title + "'.");
                defaultField = selectedFields[0].fieldName;
                component.set("v.selectedField", defaultField);
                component.set("v.selectedEventLabel", selectedFields[0].fieldLabel);
            }
          
        }
})