@isTest
public class TestLeadPassController {
    public static RecordType rt = [select id,Name from RecordType where SobjectType='Lead' and Name='Lead' Limit 1]; 
    static testMethod void test() {
    Test.startTest();
        boolean convertLeadToOpportunity = false;
        String ObjectName ='Lead';
        String fieldSetName ='Lead_Pass_PRM';
        String userSelection ='leadInbox';
        String objectFilter = 'Open';
        String recordTypeName = rt.Name; 
        String leadInboxFilterOption ='Assigned to Queues';
        Decimal pageNumber = 1;
        Decimal recordsSize = 8;

        LeadPassController ldCon = new LeadPassController();
        List<Lead> listLead = new List<Lead>();
        Lead Ld1 = new Lead(FirstName='firstTest1', LastName='lastTest', recordTypeId=rt.id, Company='Test1', Status='Open', Accepted__c=false);
        listLead.add(Ld1);
        Lead Ld2 = new Lead(FirstName='firstTest2', LastName='lastTest', recordTypeId=rt.id, Company='Test2', Status='Working - Contacted', Accepted__c=true);
        listLead.add(Ld2);
        insert listLead;
 
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        leadInboxFilterOption ='Assigned to Current User';
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        userSelection ='myAcceptedLeads';
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        ObjectName ='Opportunity';
        fieldSetName ='My_Opportunities_PRM';	
        userSelection = 'myOpptys';
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        ObjectName ='Lead';
        fieldSetName ='Lead_Pass_PRM';	
        userSelection = 'leadInbox';
		objectFilter = '';
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        userSelection ='myAcceptedLeads';
        LeadPassController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,leadInboxFilterOption,pageNumber,recordsSize);
        ObjectName ='Opportunity';
        fieldSetName ='My_Opportunities_PRM';	
        userSelection = 'myOpptys';
        LeadPassController.getLead(listLead[0].Id);
        LeadPassController.saveLead(listLead[1],convertLeadToOpportunity); //Accepted__c=true, convertLeadToOpportunity =false
		convertLeadToOpportunity = true;
        LeadPassController.saveLead(listLead[0],convertLeadToOpportunity); //Accepted__c=false, convertLeadToOpportunity =true
    Test.stopTest();
    }
}