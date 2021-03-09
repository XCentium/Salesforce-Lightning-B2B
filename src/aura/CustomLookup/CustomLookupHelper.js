({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method
     var action = component.get("c.fetchLookUpValues");
      // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
			'fieldName' : component.get("v.objectFieldName")
          });
      // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }

        });
      // enqueue the Action
        $A.enqueueAction(action);

	},
	predefinedValue : function(component,event) {
		var predefinedRecordId = component.get('v.predefinedRecordId');
		if(predefinedRecordId) {
			console.log('predefined value found');
			var action = component.get("c.getMySingleObject");
			action.setParams({
	            'objectName' : component.get("v.objectAPIName"),
				'fieldName' : component.get("v.objectFieldName"),
				'recordId' : predefinedRecordId
	          });
			action.setCallback(this, function(a) {
				//component.set("v.myAttribute", a.getReturnValue());
				var selectedAccountGetFromEvent = a.getReturnValue();
			  component.set("v.selectedRecord" , selectedAccountGetFromEvent);

			  console.log('selectedRecord : ' , component.get("v.selectedRecord"));

			  var selectedRecordName = selectedAccountGetFromEvent[component.get('v.objectFieldName')];
			  component.set('v.selectedRecordName', selectedRecordName);

				 var forclose = component.find("lookup-pill");
					$A.util.addClass(forclose, 'slds-show');
					$A.util.removeClass(forclose, 'slds-hide');


				 var forclose = component.find("searchRes");
					$A.util.addClass(forclose, 'slds-is-close');
					$A.util.removeClass(forclose, 'slds-is-open');

				 var lookUpTarget = component.find("lookupField");
					 $A.util.addClass(lookUpTarget, 'slds-hide');
					 $A.util.removeClass(lookUpTarget, 'slds-show');
			});
			$A.enqueueAction(action);
		}
	}
})