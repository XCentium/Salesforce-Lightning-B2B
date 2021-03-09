public with sharing class DealRegistrationController {
    //Class Name: DealRegistrationController - Used with DealRegistration Lightning Component
    //Author : Raj Rao, Principal Solution Engineer, Salesforce.com
    //Date Released : May 12, 2016
    public static RecordType rt;
    
    @AuraEnabled
    //get Deal Registration RecordTypeId to pass as a param to Register New Deals
    public static String getRecordTypeId(String recordTypeName) {
        rt = [select id,Name from RecordType where SobjectType='Lead' and RecordType.DeveloperName =:recordTypeName Limit 1];
        return rt.Id;
    }

    @AuraEnabled
    // Retrieve records based on passed in parameters 
    public static DealRegistrationPagedResult getRecords(String ObjectName, String fieldSetName, String userSelection, String objectFilter, String recordTypeName, Decimal pageNumber, Decimal recordsSize) {
        String currentUserId = UserInfo.getUserId();
        String str = objectFilter;
        //String recordTypeId = getRecordTypeId(recordTypeName);
        String query = 'SELECT ';
        String queryCount = 'SELECT';        
        List<String> objectFilterList = new List<String>();
        if(str.trim().length()==0){ // if no filter value(s) were passed
        }else{
	        for(String key : str.trim().split(',')){
            	objectFilterList.add(key.trim());
        	}
        }

        //get field lablel, field name, and field type
        List<String> fldLabels = new List<String>();
        List<String> fldNames = new List<String>();
        List<String> fldTypes = new List<String>();

        for(Schema.FieldSetMember f : getFieldSet(fieldSetName, ObjectName)) {
            if(f.getFieldPath()=='AccountId'){
            	query +=  'Account.Name, ';
                fldLabels.add('Account');
                fldNames.add('Account.Name');
                //TO DO account for other field types such as DateTime or Double ??? 
                if(f.getType()== Schema.DisplayType.Date){
                    fldTypes.add('Date');
                }else if(f.getType()== Schema.DisplayType.Currency){
                    fldTypes.add('Currency');  
                }else{
                    fldTypes.add('String');        
                }
            }else{
            	query += f.getFieldPath() + ', ';
                fldLabels.add(f.getLabel());
                fldNames.add(f.getFieldPath());
                //TO DO account for other field types such as DateTime or Double ??? 
                if(f.getType()== Schema.DisplayType.Date){
                    fldTypes.add('Date');
                }else if(f.getType()== Schema.DisplayType.Currency){
                    fldTypes.add('Currency');  
                }else{
                    fldTypes.add('String');        
                }
            }
        }

		//Integer pageSize = 8;
        Integer pageSize = (Integer)recordsSize;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        DealRegistrationPagedResult r =  new DealRegistrationPagedResult();
        r.pageSize = pageSize;
        r.page = (Integer) pageNumber;
        r.fldLabels = fldLabels;
        r.fldNames = fldNames;
        r.fldTypes = fldTypes;
        
        if(ObjectName=='Lead' && userSelection=='myRegisteredDeals'){
            if(objectFilterList.isEmpty()){
	            query += 'Id FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' LIMIT '+pageSize+' OFFSET '+offset;
	        	queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\'';
            }else{
	            query += 'Id FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' AND Status IN:objectFilterList LIMIT '+pageSize+' OFFSET '+offset;
	        	queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' AND Status IN:objectFilterList';
//            query += 'Id, Name FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND Status IN:objectFilterList LIMIT '+pageSize+' OFFSET '+offset;
//        	queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND Status IN:objectFilterList';
            }
        }else if(ObjectName=='Lead' && userSelection=='myRejectedDeals'){
            if(objectFilterList.isEmpty()){
                query += 'Id FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' LIMIT '+pageSize+' OFFSET '+offset ;
            	queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\'';
            }else{
            	query += 'Id FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' AND Status IN:objectFilterList LIMIT '+pageSize+' OFFSET '+offset ;
            	queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND RecordType.DeveloperName=\''+recordTypeName+'\' AND Owner.Id=\''+currentUserId+'\' AND Status IN:objectFilterList';
            	//query += 'Id, Name FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND Status IN:objectFilterList LIMIT '+pageSize+' OFFSET '+offset ;
            	//queryCount += ' count() FROM '+ObjectName+' Where Accepted__c = False AND isConverted = False AND Status IN:objectFilterList';
            }
        }
        else if(ObjectName=='Opportunity' && userSelection=='myOpptys'){
             if(objectFilterList.isEmpty()){
	            query += 'Id FROM '+ObjectName+' Where isClosed=False AND Owner.Id=\''+currentUserId+'\' ORDER BY CloseDate DESC LIMIT '+pageSize+' OFFSET '+offset;
	            queryCount += ' count() FROM '+ObjectName+' Where isClosed=False AND Owner.Id=\''+currentUserId+'\'';
             }else{
	            query += 'Id FROM '+ObjectName+' Where isClosed=False AND Owner.Id=\''+currentUserId+'\' AND StageName IN:objectFilterList ORDER BY CloseDate DESC LIMIT '+pageSize+' OFFSET '+offset;
	            queryCount += ' count() FROM '+ObjectName+' Where isClosed=False AND Owner.Id=\''+currentUserId+'\' AND StageName IN:objectFilterList';
//            query += 'Id, Name FROM '+ObjectName+' Where StageName IN:objectFilterList ORDER BY CloseDate DESC LIMIT '+pageSize+' OFFSET '+offset;
//            queryCount += ' count() FROM '+ObjectName+' Where StageName IN:objectFilterList';
             }
        }
        r.total = Database.countQuery(queryCount);
        r.records = Database.query(query);
        return r;
    }

    @AuraEnabled
    // Retrieve lead for record detail 
    public static List<Lead> getLead(String leadID) {
        List<Lead> lead = 
                [SELECT Id, Name, FirstName, LastName, MobilePhone, Title, RatingColor__c,  Project_Amount__c, Days_Remaining__c, Company, Email, Phone, LeadSource,  Description, Accepted__c FROM Lead Where Id = :leadID ];
        return lead;
    }    
    
    @AuraEnabled
    public static Lead saveLead(Lead lead, boolean convertLeadToOpportunity) {
        Id uid = UserInfo.getUserId();
        
        if(convertLeadToOpportunity){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess()); 
            return lead;
        }else{
            lead.OwnerId = uid;
            lead.Accepted__c = true;
            upsert lead;
            Task t = new Task();
            t.OwnerId = uid;
            t.Subject = 'Follow-up';
            t.Status = 'Open';
            t.Priority = 'Normal';
            t.WhoId = lead.Id; // since this a lead we need to use the WhoId and NOT the WhatId
            t.IsReminderSet = true;
            t.ActivityDate = date.today().addDays(2);//this is the task due date
            insert t;
            return lead;
        }
    }
    
    public static List<Schema.FieldSetMember> getFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    } 
}