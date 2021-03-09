({
    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
    
    doInit : function(component, helper) {
		var record = component.get('v.record');
        var FieldName = component.get('v.fieldName');
        component.set("v.fieldValue",record[FieldName]);
       	var idx = component.get('v.index');
        var fldLabels = component.get('v.fieldLabels');
       	var fldLabel = fldLabels[idx]; 
        component.set("v.fieldLabel",fldLabel);
        var fldTypes = component.get('v.fieldTypes');
        var fldType = fldTypes[idx];
        component.set("v.fieldType",fldType);
        
    },
    
    update: function(component, evt, helper) {
        var record = component.get("v.record");
        record.Accepted__c = true;
      	// Note that updateLead matches the name attribute in <aura:registerEvent>
      	var updateEvent = component.getEvent("updateRecord");
        updateEvent.setParams({ "record": record }).fire();
    },

    //navigate to Detail Page
    recordDetail : function (component, event, helper) {
    	var navEvt = $A.get("e.force:navigateToSObject");
        var id = event.target.parentElement.getAttribute("data-id");//since ui:output text generates a span tag we need to get the data-id from the parent element which is the <a tag
        navEvt.setParams({
            "recordId": id
    	});
    	navEvt.fire();
	}
})