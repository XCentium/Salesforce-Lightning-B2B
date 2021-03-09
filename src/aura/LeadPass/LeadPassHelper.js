({

    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
     
    loadRecords : function(cmp,evt,page) {
        page = page || 1;
        var optionSelected;
        var sObjectName;
        var fieldSetName; 
        var objectFilter;
        var leadInboxFilterOption = cmp.get('v.LeadInboxFilterOption'); 
        var pageNumber;
        var pageSize = cmp.get("v.pageSize");
        var optionLabel;
        if($A.util.isEmpty(evt.target)){
            optionSelected = 'leadInbox';
            sObjectName = 'Lead';
            fieldSetName = cmp.get("v.LeadFieldSetName");
            objectFilter = cmp.get("v.MyLeadsFilter");
            leadInboxFilterOption = leadInboxFilterOption;
            pageNumber = page;
            optionLabel = cmp.get("v.MyLeads");
        }else{
            optionSelected = evt.target.getAttribute('id');
            sObjectName = evt.target.getAttribute('data-objectName');
            fieldSetName = evt.target.getAttribute('data-fieldSetName');
            objectFilter = evt.target.getAttribute('data-objectFilter');
            leadInboxFilterOption = leadInboxFilterOption;;
            pageNumber = page;
            //optionLabel = evt.target.value;
            optionLabel = evt.target.getAttribute('data-optionLabel');
        }
//		this.loadFieldLabelsandNames(cmp,evt);
        var action = cmp.get("c.getRecords");
            //display spinner
            cmp.set("v.displayLoader",true); 
        	//console.log(cmp.get('v.LeadInboxFilterOption'));//NEW - Need pass this through to getRecords
        	action.setParams({ 
                "ObjectName" : sObjectName,
                "fieldSetName" : fieldSetName,
                "userSelection" : optionSelected,
                "objectFilter" : objectFilter,
                "leadInboxFilterOption" : leadInboxFilterOption,
                "pageNumber" : page,
                "recordsSize" : pageSize
        	});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
//                    cmp.set("v.records", result.records);
                    console.log('SUCCESS '+result.fldNames);
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
            	"leadInboxFilterOption" : cmp.get('v.LeadInboxFilterOption'),
                "pageNumber" : page,
            	"recordsSize" : cmp.get("v.pageSize")
        	});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var pageSize = cmp.get("v.pageSize");
                    cmp.set("v.fldLabels",result.fldLabels);
                	cmp.set("v.fldNames",result.fldNames);
                    cmp.set("v.fldTypes",result.fldTypes);
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
    
    upsertLead : function(component, event, record, callback) {
        var action = component.get("c.saveLead");
        //display spinner
        component.set("v.displayLoader",true); 
        var convertLead = component.get("v.convertLeadToOpportunity");
        action.setParams({ 
            "lead": record,
            "convertLeadToOpportunity": convertLead
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //hide spinner
                var page = component.get("v.page");//testing
                this.loadRecords(component,event,page);
                component.set("v.displayLoader",false); 
            }
        });    
        $A.enqueueAction(action);
    },
  
    setActive: function(cmp, evt){
        var leadButton = cmp.find('leadInbox');
        var acceptedButton = cmp.find('myAcceptedLeads');
        var opptyButton = cmp.find('myOpptys');
		var activeTab = evt.source;
        $A.util.removeClass(leadButton, 'active');
        $A.util.removeClass(acceptedButton, 'active');
        $A.util.removeClass(opptyButton, 'active');
        $A.util.addClass(activeTab, 'active');
    }  
 })