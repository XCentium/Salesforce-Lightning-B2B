public class DE_CustomerSurveyController {
    public Customer_Survey__c cs {get;set;}
    public String contactId {get;set;}
    public String caseId {get;set;}
    public String q4 {get;set;}
    public List<Case> caseRecord {get;set;}
    public String cName {get;set;}
    public DE_CustomerSurveyController(){
        cs = new Customer_Survey__c();
        contactId = ApexPages.CurrentPage().getParameters().get('contactid');
        caseId = ApexPages.CurrentPage().getParameters().get('caseid');
        caseRecord = [SELECT Contact.FirstName From Case WHERE id =: caseId LIMIT 1];
        if(caseRecord.size() > 0){
            cName = caseRecord[0].Contact.FirstName;
        }
    }
    
    /* Populate List with picklist values from custom field 'Question_4__c' */
    public List<SelectOption> getQ4Types(){
        Schema.sObjectType sobject_type = Customer_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();

        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Question_4__c').getDescribe().getPickListValues();
        
        List<selectOption> options = new List<selectOption>();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getValue(), a.getLabel()));
            
        }
        return options;
    }
    
    public PageReference saveCS(){
        cs.Question_4__c = q4;
        if(contactId != null || contactId != ''){
            cs.Contact__c = contactId;
        }
        if(caseId != null || caseId != ''){
            cs.Case__c = caseId;
        }
        insert cs;
        return new PageReference('/apex/DE_CustomerSurveyThanks');
    }
}