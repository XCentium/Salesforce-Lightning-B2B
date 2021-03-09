({

    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
    
    loadRecordTypeId : function(cmp) {
    	var action = cmp.get("c.getRecordTypeId");
        action.setParams({ 
            "recordTypeName": cmp.get("v.LeadRecordTypeName")
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.newDealLeadRecordTypeId",response.getReturnValue());
            }
        });    
        $A.enqueueAction(action);
    },
 
    loadRecords : function(cmp,evt,page) {
        page = page || 1;
        var optionSelected;
        var sObjectName;
        var fieldSetName; 
        var objectFilter;
        var recordTypeName = cmp.get("v.LeadRecordTypeName");
        var pageNumber;
        var pageSize = cmp.get("v.pageSize");
        var optionLabel;
        if($A.util.isEmpty(evt.target)){
            optionSelected = 'myRegisteredDeals';
            sObjectName = 'Lead';
            fieldSetName = cmp.get("v.RegisteredDealsFieldSetName");
            objectFilter = cmp.get("v.RegisteredDealsFilter");
            recordTypeName = recordTypeName;
            pageNumber = page;
            optionLabel = cmp.get("v.RegisteredDeals");
        }else{
            optionSelected = evt.target.getAttribute('id');
            sObjectName = evt.target.getAttribute('data-objectName');
            fieldSetName = evt.target.getAttribute('data-fieldSetName');
            objectFilter = evt.target.getAttribute('data-objectFilter');
            recordTypeName = recordTypeName;
            pageNumber = page;
            //optionLabel = evt.target.value;
            optionLabel = evt.target.getAttribute('data-optionLabel');
        }
//		this.loadFieldLabelsandNames(cmp,evt);
        console.log('recordTypeName : '+cmp.get('v.LeadRecordTypeName'));
        var action = cmp.get("c.getRecords");
            //display spinner
            cmp.set("v.displayLoader",true); 
            action.setParams({ 
                "ObjectName" : sObjectName,
                "fieldSetName" : fieldSetName,
                "userSelection" : optionSelected,
                "objectFilter" : objectFilter,
                "recordTypeName" : recordTypeName,
                "pageNumber" : page,
                "recordsSize" : pageSize
        	});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    cmp.set("v.fldLabels",result.fldLabels);//new
                	cmp.set("v.fldNames",result.fldNames);//new
                    cmp.set("v.fldTypes",result.fldTypes);//new
                    cmp.set("v.records", result.records);
                    cmp.set("v.page", result.page);
            		cmp.set("v.total", result.total);
            		cmp.set("v.pages", Math.ceil(result.total/pageSize));
                    cmp.set("v.userSelection", optionSelected);
                    cmp.set("v.userSelectedOption",optionLabel);
                    cmp.set("v.currentFilter",objectFilter);
                    cmp.set("v.currentObject",sObjectName);
                    cmp.set("v.currentfieldsetName",fieldSetName);
                    //hide spinner
                    cmp.set("v.displayLoader",false);
                }
            });    
            $A.enqueueAction(action);
    },

    pageChange : function(cmp,page) {
        var action = cmp.get("c.getRecords");
        //display spinner
        cmp.set("v.displayLoader",true); 
        action.setParams({ 
                "ObjectName" : cmp.get("v.currentObject"),
                "fieldSetName" : cmp.get("v.currentfieldsetName"),
                "userSelection" : cmp.get("v.userSelection"),
                "objectFilter" : cmp.get("v.currentFilter"),
            	"recordTypeName" : cmp.get("v.LeadRecordTypeName"),
                "pageNumber" : page,
            	"recordsSize" : cmp.get("v.pageSize")
        	});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var pageSize = cmp.get("v.pageSize");
                    cmp.set("v.fldLabels",result.fldLabels);//new
                	cmp.set("v.fldNames",result.fldNames);//new
                    cmp.set("v.fldTypes",result.fldTypes);//new
                    cmp.set("v.records", result.records);
                    cmp.set("v.page", result.page);
            		cmp.set("v.total", result.total);
            		cmp.set("v.pages", Math.ceil(result.total/pageSize));
                    //hide spinner
                    cmp.set("v.displayLoader",false);
                }
            });    
            $A.enqueueAction(action);
    },

})