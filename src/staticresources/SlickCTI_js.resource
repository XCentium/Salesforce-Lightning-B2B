        var j$ = jQuery.noConflict(); 
        var callType = '';
        var callStartTime;
        var phoneHeight = 350;
        sforce.interaction.cti.enableClickToDial();
        sforce.interaction.cti.onClickToDial(clickToDialCallback);                    
        sforce.interaction.cti.enableClickToDial();        
        var recordUrlToPop = ''; 
        var notesPlaceHolder = 'Notes...';                    
        var seconds = null;
        var ticker = null;  
        var callerVerified = false; 
        var transferUrl = '';
        var transferPrimaryTabObjectId = '';

/**Add verification of var that should have been set in VF*/
		if (typeof transferEndCall === 'undefined')var transferEndCall=false;
		if (typeof emptyNotes === 'undefined')var emptyNotes='Notes...';
		if (typeof localizedCallType === 'undefined')var localizedCallType={'Inbound':'Inbound call on','Outbound call on':'Outbound','Internal':'Internal call on'}



        /**
         *
         * Local object to store and abstract the call centre definition settings  
         *
         **/
        var callCentreDefObject = {
            windowHeight: '',
            callButtonsUrl: '',
            button1Url: '',
            button2Url: '',
            button3Url: '',
            button4Url: '',
            button5Url: '',
            button6Url: '',
            button7Url: '',
            button8Url: '',
            button9Url: ''
        }   
                
        function startTimer() {
            seconds = -1;            
            j$("#elapsed").html('00:00:00');
        }
        
        function stopTimer() {
            seconds = -1;
            j$("#elapsed").html('');            
        }
        
        function tick() {
            ++seconds;
            var secs = seconds;
            var hrs = Math.floor( secs / 3600 );
            secs %= 3600;
            var mns = Math.floor( secs / 60 );
            secs %= 60;
            var pretty = ( hrs < 10 ? "0" : "" ) + hrs
                       + ":" + ( mns < 10 ? "0" : "" ) + mns
                       + ":" + ( secs < 10 ? "0" : "" ) + secs;

            j$("#elapsed").html(pretty);
        }         
               
        /**
         *
         *
         *
         **/                                              
       function clickToDialCallback(response) {
            sforce.interaction.setVisible(true);
            callType = 'Outbound'; 
            outboundAudio.play();
            callStartTime = new Date();            
            j$("#dialPad").toggle();
            j$("#callNotes").toggle();  
            j$("#callButtons").toggle();
            j$("#hangUpBtn").toggle();  
            j$('#transferBtn').toggle();
            startTimer();                  
        }
            
        /**
         *
         *
         *
         **/                
        function saveLog(response) {
            var currentDate = new Date();           
            //var saveParams = 'Subject=' + callType + ' call on ' + generateCallTimeStamp();
           	//using localizedCallType to support multilingual
            var saveParams = 'Subject=' + localizedCallType[callType] +' '+ generateCallTimeStamp();
            saveParams += '&Status=completed';                 
            saveParams += '&CallType=' + callType;
            saveParams += '&Activitydate=' + generateTaskDueDate();
            saveParams += '&CallObject=' + currentDate.getTime();
            saveParams += '&Description=' + j$("#callNotesField").val();
            saveParams += '&Type=Call&TaskSubtype=Call';
            var callDisposition = j$("#callDisposition").val();            
            if(callDisposition) {
                saveParams += '&CallDisposition=' + callDisposition;       
            }                                  
            saveParams += '&CallDurationInSeconds=' + Math.floor((currentDate.getTime() - callStartTime)/ 1000);
            
            var result = JSON.parse(response.result);
            if(result.objectId.substr(0,3) == '003' || result.objectId.substr(0,3) == '00Q') {
                saveParams += '&whoId=' + result.objectId;                    
            } else {
                saveParams += '&whatId=' + result.objectId;            
            }
            
            //console.log('Save params are: ' + saveParams);
            sforce.interaction.saveLog('Task', saveParams);
            sforce.interaction.entityFeed.refreshObject(result.objectId, true, true, false);            
            j$("#callNotesField").val(notesPlaceHolder); 
            j$(this).addClass('emptyNotes');         
            sforce.console.getFocusedPrimaryTabId(function(response){
                sforce.console.refreshPrimaryTabById(response.id, true);
            });            
        }   
       

        function generateTaskDueDate() {
            var currentDate = new Date();           
            var currentDay = currentDate.getDate();
            var currentMonth = currentDate.getMonth()+1;
            var currentYear = currentDate.getFullYear();

            return currentYear+ '-' + currentMonth + '-' + currentDay;
        }

        function generateCallTimeStamp() {
        	var timeStamp = new Date().toString();
           //-- using moment.js to format the timestamp ; supporting multilingual --
            if(typeof moment === 'undefined')timeStamp = timeStamp.substring(0, timeStamp.lastIndexOf(':') + 3); 
            else timeStamp = moment().format('llll');            
            var currentDate = new Date();           
            var currentDay = currentDate.getDate();
            var currentMonth = currentDate.getMonth()+1;
            var currentYear = currentDate.getFullYear();

            return timeStamp;            
        }
        
        /**
         *
         *
         *
         **/                       
        var loadCallCentreSettings = function(response) {        
            var adaptorURL;
            callCentreString = response.result;
            // The return Call Centre Settings JSON object is not properly formatted so hack/fix it
            callCentreString = callCentreString.split(',');

            for (var i = 0; i < callCentreString.length; i++) {
                var curArrayValue = callCentreString[i];                
                if ( curArrayValue.indexOf('popRecordUrl') != -1 ) {
                    callCentreDefObject.callButtonsUrl = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('reqSoftphoneHeight') != -1 ) {
                    callCentreDefObject.windowHeight = parseCallCentreItem(curArrayValue);
                    phoneHeight = callCentreDefObject.windowHeight;
                } else if ( curArrayValue.indexOf('Button1PopUrl') != -1 ) {
                    callCentreDefObject.button1Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button2PopUrl') != -1 ) {
                    callCentreDefObject.button2Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button3PopUrl') != -1 ) {
                    callCentreDefObject.button3Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button4PopUrl') != -1 ) {
                    callCentreDefObject.button4Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button5PopUrl') != -1 ) {
                    callCentreDefObject.button5Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button6PopUrl') != -1 ) {
                    callCentreDefObject.button6Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button7PopUrl') != -1 ) {
                    callCentreDefObject.button7Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button8PopUrl') != -1 ) {
                    callCentreDefObject.button8Url = parseCallCentreItem(curArrayValue);
                } else if ( curArrayValue.indexOf('Button9PopUrl') != -1 ) {
                    callCentreDefObject.button9Url = parseCallCentreItem(curArrayValue);
                }
            }

            if (phoneHeight == '' || phoneHeight == 0) {
                    phoneHeight = 350;                
            }                                                                     
        } 

        /**
         *
         * Name:Value pair passed in and returns Value item
         *
         **/
        function parseCallCentreItem(callCentreNameValuePair) {
            NAME_INDEX = 0;
            VALUE_INDEX = 1;
            nameValueArray = callCentreNameValuePair.split(':');

            //console.log('^^^^^ parseCallCentreItem - Name: ' + nameValueArray[NAME_INDEX] + ' with Value: ' + nameValueArray[VALUE_INDEX]);
            valueItem = nameValueArray[VALUE_INDEX];
            //Trimming the junk off the value pair
            valueItem = valueItem.substring(1,valueItem.length-1);        

            return valueItem;
        }

        /**
         *
         * Object to hold parse the rawPopUrl from the Call Centre Definition and hold the values if defined
         *
         **/
        var popAction = {
            action: 'popRecord',
            recordUrl: '',
            actionParameters: '',
            init: function(rawUrl) {
                // Parse the inbound string and do things with it....
                //console.log('^^^^^ Inside popAction init function with RAWUrl of: ' + rawUrl);

                // Look for the pretense of action=
                // If that doesn't exist assume it is just  regular record URL
                if ( rawUrl.indexOf('action=') == -1 ) {
                    //console.log('No action parameter so this is just a straight up URL');
                    this.action = 'popRecord';
                    this.recordUrl = rawUrl;
                } else {
                    // expecting rawUrl to be of the format: action=<actionName>&recordUrl=<ID>&actionParams=[PARAMS SPECIFIC TO ACTION]
                    rawUrlArray = rawUrl.split('&');
                    for(y=0; y < rawUrlArray.length; y++) {
                        // now processing a single name/value pair i.e. action=WHATEVER or recordUrl=SOME_ID or actionParams=SOME_PARAMETER_ARRAY
                        nameValueArray = rawUrlArray[y].split('=');
                        curName = nameValueArray[0];
                        curVal = nameValueArray[1];

                        //console.log('^^^^^ Processing popAction item - NAME: ' + curName + ' with VALUE: ' + curVal);

                        if (curName == 'action') {
                            this.action = curVal;
                        } else if (curName == 'recordUrl') {
                            this.recordUrl = curVal;
                        } else if (curName == 'actionParams') {
                            // Have to do some massaging into a proper JSON object of the passed in action parameters b/c of the 
                            // manual string handling of the call centre definition object....  Hack on a hack on a hack...
                            curVal = curVal.replace(/~/g,':');
                            curVal = curVal.replace(/\^/g,',');
                            this.actionParameters = curVal;                 
                        } else {
                            console.log('Unknown URL parameter ' + curName + ' - I only understand action, recordUrl, callerVerified and actionParams. Shame on you for making me look bad!');
                        }
                    }
                }
            }
        } // END - var popAction

        /**
         *
         * Inbound pop URL will likely have the following format:
         * /action=<actionName>&recordUrl=<ID>&actionParams=[PARAMS SPECIFIC TO ACTION]
         * You will need to implement 
         *
         **/
        function parsePopUrl(rawPopUrl) {
            //console.log('^^^^ Inside parsePopUrl function with rawPopURL of: ' + rawPopUrl);
            if ('' != rawPopUrl) {
                popAction.init(rawPopUrl);
                window[popAction.action](popAction.recordUrl, popAction.actionParameters);
            }
        }

        function popRecord(recordId, otherParams) {
            otherParams = otherParams.replace(/\\/g,'');
            otherParams = otherParams.replace(/~/g,':');
            otherParams = otherParams.replace(/\^/g,',');

            if ('' != otherParams) {
                otherParams = JSON.parse(otherParams);    
            }                            
            doRecordPop(recordId);                    
        }

        function doRecordPop(recordId) {
            callType = 'Inbound';                
            phoneRingAudio.play();     
            callStartTime = new Date();                                      
            // This pause plays the entire ring before the screen pop                                
            setTimeout(
                function() {
                    //console.log('Record URL is: ' + recordId);
                    j$("#dialPad").toggle();
                    j$("#callNotes").toggle();
                    j$("#callButtons").toggle();
                    j$("#hangUpBtn").toggle();  
                    j$('#transferBtn').toggle();
                    startTimer();

                    sforce.interaction.screenPop('/'+recordId);
                 }
             ,1250);   
            sforce.interaction.runApex('SlickCtiController', 'getRecordDetails', 'recordId=' + recordId, loadRecordCallback);          
        }

    
        /**
         *
         *
         *
         **/
        var loadRecordCallback = function(response) {        
            //console.log('Inside loadRecordCallback');        
            if (response.result) {
                var resultObject = j$.parseJSON(response.result);                
                var htmlToInsert = '';
                if (resultObject.objectType == 'Contact') {
                    htmlToInsert = ich.contactTemplate(resultObject);
                } else if (resultObject.objectType == 'Lead') {
                    htmlToInsert = ich.leadTemplate(resultObject);                    
                } else if (resultObject.objectType == 'Account') {
                    htmlToInsert = ich.accountTemplate(resultObject);     
                } else if (resultObject.objectType == 'Case') {
                    htmlToInsert = ich.caseTemplate(resultObject);                                      
                } else {
                    console.log('This is not a Contact or Lead object it is an: ' + resultObject.objectType);
                }                
                j$('.dialbox').html(htmlToInsert);                               
            } else {
                console.log('Error in remote call: ' + response.error);
            }                
        };


// -- Place to put your VERY own SlickIVR Actions!!!

        /**
         *
         * Example of a custom call center definition ACTION 
         *
         **/
        function createCase(recordId, otherParams) {            
            //Wow... this hack is getting silly.... double quoted parameters are escaped and I need to remove the escape
            otherParams = otherParams.replace(/\\/g,'');
            otherParams = otherParams.replace(/~/g,':');
            otherParams = otherParams.replace(/\^/g,',');

            console.log('createCase function with other params of: ' + otherParams);

            //change this froma string into a JSON object so it'll be easier to manage
            otherParams = JSON.parse(otherParams);
            parameterString = 'personAccountId=' + recordId + '&caseType=' + otherParams.caseType + '&subType=' + otherParams.subType;
            parameterString += '&callerVerified=' + otherParams.callerVerified + '&waitTime=' + otherParams.WaitTime;
            parameterString += '&ivrPath=' + otherParams.IVRPath;
            //console.log('About to call runApex to create a case with params of: ' + parameterString);

            sforce.interaction.runApex('SlickCtiController', 'createCase', parameterString, 
                function(response){
                    newlyMintedCaseId = response.result;
                    doRecordPop(newlyMintedCaseId);                    
                }
            );
        } // END function createCase      
// END -- SlickIVR Actions 

        j$(document).ready(function() {  
            ticker = setInterval("tick( )", 1000);                                                 
            //phoneRingAudio = new Audio('{!$Resource.SlickCTI_InboundRing}');                             
            sforce.interaction.cti.getCallCenterSettings(loadCallCentreSettings);   
                     
            j$(".popButton").on("click", function(event) {
                //console.log('Pop Button Pressed - button ID is: ' + j$(this).attr('id') );

                // The URLs have been defined within the Call Centre Definition and already loaded into
                // the callCentreDefObject object which has variables that match the button IDs
                // we dynamically pull the defined URL parameter based on the button pushed and follow through
                // with whatever action is defined by that button
                popButtonFunction = j$(this).attr('id') + 'Url';
                parsePopUrl( callCentreDefObject[popButtonFunction] );
            }); // END .popButton CLICK event
            
            j$("#hangUpBtn").on("click", function(event) {
                        j$("#dialPad").toggle();
                        j$("#callNotes").toggle();  
                        j$("#callButtons").toggle();
                        j$("#hangUpBtn").toggle(); 
                        j$('#transferBtn').toggle();
                        j$('.dialbox').html('');                        
                        sforce.interaction.getPageInfo(saveLog);
            }); // END j$("#hangUpBtn").on("click"

            j$("#transferBtn").on("click", function(event) {      
                     
 // New comment: added a switch in VF to avoid coming in js... Old comment:   Uncomment this if you want to transfer to automagically close everything down....
         if(transferEndCall){
                j$("#dialPad").toggle();
                j$("#callNotes").toggle();
                j$("#callButtons").toggle();
                j$("#hangUpBtn").toggle();
                j$('#transferBtn').toggle();
                j$('.dialbox').html('');
                sforce.interaction.getPageInfo(saveLog);
                //Call to find and close primary Tab???
                }

                 sforce.console.getFocusedPrimaryTabObjectId(function(result){
                    transferPrimaryTabObjectId = result.id;
                 });

                 sforce.console.getFocusedPrimaryTabId(function(response){
                    sforce.console.getTabLink(sforce.console.TabLink.PARENT_AND_CHILDREN, 
                    response.id, function(response){
                        transferUrl = response.tabLink;
                        transferUrl = transferUrl.substring(transferUrl.lastIndexOf('/'), transferUrl.length);
                        //console.log('Have just set the transfer link to: ' + transferUrl);
                    });
                 });
            }); // END j$("#transferBtn").on("click"

            j$("#pickupTransfer").on("click", function(event) {
                console.log('Simulating picking up a transfer at URL: ' + transferUrl);
                sforce.interaction.screenPop(transferUrl, true);
                sforce.interaction.runApex('SlickCtiController', 'getRecordDetails', 'recordId=' + transferPrimaryTabObjectId, loadRecordCallback);

                callType = 'Inbound';                
                phoneRingAudio.play();          
                callStartTime = new Date(); 
                j$("#dialPad").toggle();
                j$("#callNotes").toggle();
                j$("#callButtons").toggle();
                j$("#hangUpBtn").toggle();  
                j$('#transferBtn').toggle();
                startTimer();                     
            }); // END j$("#pickupTransfer").on("click"

            j$('.callNoteBlock').on("focus", 
                function(event) {
                    //console.log('callNotesBlock on focus: ' + j$(this).val());
                    if (j$(this).val() == emptyNotes) {
                        j$(this).val("");
                        j$(this).removeClass('emptyNotes');
                    }
                }
            ); // END j$('.callNoteBlock').on("focus",
            
            j$('.callNoteBlock').on("blur",
                function(event) {
                    //console.log('callNotesBlock on blur: ' + j$(this).val());
                    if (j$(this).val() == "") {
                        j$(this).addClass('emptyNotes');
                        j$(this).val(emptyNotes);
                    }
                }
            ); // END  j$('.callNoteBlock').on("blur",
            
            sforce.interaction.isInConsole(function(response){
                sforce.interaction.cti.getCallCenterSettings(loadCallCentreSettings);            
                var isInConsole = response.result;                             
                if ( !isInConsole) {
                    // If we are NOT in the console set it a height of zero because 
                    // we do not support the side bar yet
                    sforce.interaction.cti.setSoftphoneHeight(0, function(event) {
                        //console.log('We are not in the console and the thing should be a height of zero now...');
                    });
                } else {
                    sforce.interaction.cti.setSoftphoneHeight(phoneHeight, function(event) {
                        //console.log('We ARE in the console and the thing should have a proper height now of ' + phoneHeight);
                    });                                      
                }
            });
        }); // End of document.Ready 