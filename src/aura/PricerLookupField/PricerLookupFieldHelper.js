({
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp,event) {
        // Get the search string, input element and the selection container
        var searchString = cmp.get('v.searchString');
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find('lookuplist');
				var lookupDiv = cmp.find('lookup-div');

        // Clear any errors and destroy the old lookup items container
        inputElement.set('v.errors', null);

        //console.log(event.getParam("keyCode"));
        
        var curMatches=cmp.get('v.matches');
        var curSelector=parseInt(cmp.get('v.selector'));
        var keyCode = event.getParam("keyCode");
        var ctrlKey = event.getParam("ctrlKey"); //true if ctrl is pressed
        //console.log(keyCode);
        if (curMatches!=null && keyCode>=37 && keyCode<=40) {
            if ((keyCode === 40) && (curSelector<curMatches.length-1)) {
            	 cmp.set('v.selector',parseInt(curSelector)+1);
                 cmp.set('v.selectorRecId',curMatches[parseInt(curSelector)+1].SObjectId);
                 cmp.set('v.selectorRecLabel',curMatches[parseInt(curSelector)+1].SObjectLabel);
                 this.scrollInsideItems(cmp);
            } else if ((keyCode === 38 ) && (curSelector>0)) {
                cmp.set('v.selector',parseInt(curSelector)-1);
                cmp.set('v.selectorRecId',curMatches[parseInt(curSelector)-1].SObjectId);
                cmp.set('v.selectorRecLabel',curMatches[parseInt(curSelector)-1].SObjectLabel);
                this.scrollInsideItems(cmp);
            } else {
               //cmp.set('v.selector',-1); 
            }
            curMatches = curMatches.map (function (curr,index){
                return Object.assign({},curr,{kbSelected:(cmp.get('v.selector')==index)});  
            });
            cmp.set('v.matches', curMatches);
            return;
        }
        
        if (keyCode===78 && ctrlKey) {
            //request new section if user press ctrl+n
            var newSectionEvent= cmp.getEvent("newSectionRequested");
	        newSectionEvent.fire();
            return;
        }
        
        if (keyCode===13 && cmp.get('v.selector')>=0 && cmp.get('v.selector')<curMatches.length ) {
            this.handleSelection(cmp,event);
            return;
        }

            
        
        // We need at least 2 characters for an effective search
        if (event.getParam("keyCode") === 27 )

        {
            // Hide the lookuplist
			$A.util.removeClass(lookupDiv, 'slds-is-open');
            cmp.set('v.selector',-1);
            return;
        }

        // Show the lookuplist
		$A.util.addClass(lookupDiv, 'slds-is-open');
        
        // Scroll to lookuplist
		//cmp.set('v.fireScrollEventAfterRendering',true);
        /*
        var cmpEvent = cmp.getEvent("askPricerToScroll");
        cmpEvent.setParams({
            "lookupGid" : cmp.getGlobalId() });
        cmpEvent.fire();
        console.log('askPricerToScroll event fired with gid: '+cmp.getGlobalId());
       */
        
        /*
        var mainDiv=cmp.find('mainDiv').getElement();
        mainDiv.scrollIntoView();
        debugger;
        var rect = mainDiv.getBoundingClientRect();
        console.log(rect);
        console.log('scrollTo:'+document.documentElement.scrollTop);*/
        

        // Get the API Name
        var sObjectAPIName = cmp.get('v.sObjectAPIName');

        // Create an Apex action
        var action = cmp.get('c.lookup');

        // Mark the action as abortable, this is to prevent multiple events from the keyup executing
        action.setAbortable();

        // Set the parameters
        action.setParams({ "searchString" : searchString,
                          "sObjectAPIName" : sObjectAPIName,
                          "pricebookId":cmp.get('v.pricebookId')});

        // Define the callback
        action.setCallback(this, function(response) {
            var state = response.getState();

            // Callback succeeded
            if (cmp.isValid() && state === "SUCCESS")
            {
                // Get the search matches
                var matches = response.getReturnValue();

                // If we have no matches, return nothing
                if (matches.length == 0)
                {
                    cmp.set('v.matches', null);
                    return;
                }
                    
                // Store the results
                cmp.set('v.matches', matches);
                cmp.set('v.selector',-1); 
				//console.log(cmp.get("v.matches"));
                // Scroll to lookuplist
				cmp.set('v.fireScrollEventAfterRendering',true);
            }
            else if (state === "ERROR") // Handle any error by reporting it
            {
                var errors = response.getError();

                if (errors)
                {
                    if (errors[0] && errors[0].message)
                    {
                        this.displayToast('Error', errors[0].message);
                    }
                }
                else
                {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });

        // Enqueue the action if 2 characters at least for an effective search
        if (!(typeof searchString === 'undefined' || searchString.length < 2 ))
        {$A.enqueueAction(action); 
        cmp.set('v.searchMessage','\"'+searchString+'\" '+$A.get("$Label.c.Pricer_in")+' '+cmp.get('v.pluralLabel'));
        }
        else {
          cmp.set('v.matches', null);
          cmp.set('v.searchMessage',$A.get("$Label.c.Pricer_PleaseEnter2CharMin")); 
          cmp.set('v.selector',-1);  
        }
        
    },

     handleMouseOver : function(cmp, event) {
         var hoverIndex = parseInt(event.currentTarget.dataset.index);
         var curMatches = cmp.get('v.matches');
         
         if (parseInt(cmp.get('v.selector'))!=hoverIndex) {
         
             cmp.set('v.selector',hoverIndex);
             // Resolve the Object Id from the events Element Id (this will be the <a> tag)
             cmp.set('v.selectorRecId',this.resolveId(event.currentTarget.id));
             // The Object label is the inner text)
             cmp.set('v.selectorRecLabel',event.currentTarget.innerText);
             
             
             curMatches = curMatches.map (function (curr,index){
                    return Object.assign({},curr,{kbSelected:(cmp.get('v.selector')==index)});  
                });
             cmp.set('v.matches', curMatches);
         
          }
         //console.log(hoverIndex);
     },
    
    
    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
        
        var objectId = cmp.get('v.selectorRecId');

        
        var objectLabel = cmp.get('v.selectorRecLabel');

        // Log the Object Id and Label to the console
        //console.log('objectId=' + objectId);
        //console.log('objectLabel=' + objectLabel);


				// update the selectedItemId and selectedItemLabel attributes
		cmp.set("v.selectedItemId",objectId);
		cmp.set("v.selectedItemLabel",objectLabel);

        // Update the Searchstring with the Label
        cmp.set("v.searchString", objectLabel);

        // Hide the Lookup List
        //var lookupList = cmp.find("lookuplist");
        //$A.util.addClass(lookupList, 'slds-hide');
        var lookupDiv = cmp.find('lookup-div');
        $A.util.removeClass(lookupDiv, 'slds-is-open');
		//HIDE MODAL IF NOT ON DESKTOP
        if ($A.get("$Browser.formFactor")!='DESKTOP') {
            var mainDiv = cmp.find('mainDiv');
	        $A.util.removeClass(mainDiv, 'lookupModal');    
        }

        // Hide the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.addClass(inputElement, 'slds-hide');

        // Show the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');

        // Lookup Div has selection
        var inputElement = cmp.find('lookup-div');
        $A.util.addClass(inputElement, 'slds-has-selection');
        

    },

    handleInitialSelection : function(cmp, event) {
        // Resolve the Object Id from the events Element Id (this will be the <a> tag)
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        var objectId = cmp.get("v.selectedItemId");
        //console.log("apiname: "+sObjectAPIName+" recordid: "+ objectId)
        if ((typeof objectId === 'undefined') || (objectId=="")) {return;} //Exit init action if no selectedItemId was provided

        var action = cmp.get('c.getRecordName');
        action.setParams({ "theRecordId" : objectId, "sObjectAPIName" : sObjectAPIName});

        action.setCallback(this, function(response) {
            var state = response.getState();

            // Callback succeeded
            if (cmp.isValid() && state === "SUCCESS")
            {
                // The Object label is the response of the query)
                var objectLabel = response.getReturnValue();

                // Log the Object Id and Label to the console
               // console.log('objectId=' + objectId);
                //console.log('objectLabel=' + objectLabel);


                // update the selectedItemId and selectedItemLabel attributes
                cmp.set("v.selectedItemId",objectId);
                cmp.set("v.selectedItemLabel",objectLabel);

                // Update the Searchstring with the Label
                cmp.set("v.searchString", objectLabel);

                // Hide the Lookup List
                //var lookupList = cmp.find("lookuplist");
                //$A.util.addClass(lookupList, 'slds-hide');
                var lookupDiv = cmp.find('lookup-div');
                $A.util.removeClass(lookupDiv, 'slds-is-open');


                // Hide the Input Element
                var inputElement = cmp.find('lookup');
                $A.util.addClass(inputElement, 'slds-hide');

                // Show the Lookup pill
                var lookupPill = cmp.find("lookup-pill");
                $A.util.removeClass(lookupPill, 'slds-hide');

                // Lookup Div has selection
                var inputElement = cmp.find('lookup-div');
                $A.util.addClass(inputElement, 'slds-has-selection');

            }
            else if (state === "ERROR") // Handle any error by reporting it
            {
                var errors = response.getError();

                if (errors)
                {
                    if (errors[0] && errors[0].message)
                    {
                        this.displayToast('Error', errors[0].message);
                    }
                }
                else
                {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });

        // Enqueue the action

        $A.enqueueAction(action);



    },


    /**
     * Clear the Selection
     */
    clearSelection : function(cmp) {


        // Clear the Searchstring
        cmp.set("v.searchString", '');

        // Hide the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-hide');

        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');

        // Lookup Div has no selection
        var inputElement = cmp.find('lookup-div');
        $A.util.removeClass(inputElement, 'slds-has-selection');

				if (cmp.get("v.selectedItemId")!=""){ cmp.set("v.selectedItemId","");}
				cmp.set("v.selectedItemLabel","");
    },

    /**
     * Resolve the Object Id from the Element Id by splitting the id at the _
     */
    resolveId : function(elmId)
    {
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i+1);
    },

    /**
     * Create a new record
     */

    createNewRecord : function(cmp)
    {
      var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
          "entityApiName": cmp.get("v.sObjectAPIName")
      });
      createRecordEvent.fire();
    },



    /**
     * Display a message
     */
    displayToast : function (title, message)
    {
        var toast = $A.get("e.force:showToast");

        // For lightning1 show the toast
        if (toast)
        {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "message": message
            });

            toast.fire();
        }
        else // otherwise throw an alert
        {
            alert(title + ': ' + message);
        }
    },
    scrollInsideItems : function (cmp) {
        var lookup=cmp.find('lookuplist-items').getElement();
        var scrollHeight=lookup.scrollHeight;
        var clientHeight=lookup.clientHeight;
       	var curMatches=cmp.get('v.matches');
        var curSelector=parseInt(cmp.get('v.selector'));
        var posToReach=((scrollHeight/curMatches.length)*curSelector)-((scrollHeight/curMatches.length)*2);
        lookup.scrollTop=posToReach;
       // console.log('scroll Heigth'+scrollHeight+' scroll To: '+posToReach);

    },
    
    getPosition : function(element) {
        var xPosition = 0;
        var yPosition = 0;
        
        while(element) {
            xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
            yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
            element = element.offsetParent;
        }
        
        return { x: xPosition, y: yPosition };
        
        
    }
    
})