@isTest
public class TestDealRegistrationController {
    public static RecordType rt = [select id,Name from RecordType where SobjectType='Lead' and Name='Lead' Limit 1];
    static testMethod void test() {
    	Test.startTest();
        	DealRegistrationController dealRegCon = new DealRegistrationController();
        	String ObjectName ='Lead';
        	String fieldSetName ='Deal_Reg_PRM'; 
        	String userSelection ='myRegisteredDeals';
        	String objectFilter = 'Open';
       		String recordTypeName = rt.Name; 
            Decimal pageNumber = 1;
            Decimal recordsSize = 8;
        	Date closeDate = Date.parse('4/12/16');

       		Lead dealReg1 = new Lead(FirstName='firstTest2', LastName='lastTest', recordTypeId=rt.Id, Company='Test2', Status='Open', Accepted__c=false);
       		insert dealReg1;
            Opportunity oppty1 = new Opportunity(Name='Test Oppty1',CloseDate=closeDate,StageName='Prospecting');
        	insert oppty1;
        	DealRegistrationController.getRecordTypeId(recordTypeName);	
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
        	userSelection = 'myRejectedDeals';
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
    	   	ObjectName ='Opportunity';
        	fieldSetName ='My_Opportunities_PRM';	
        	userSelection = 'myOpptys';
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
        	ObjectName ='Lead';
        	fieldSetName ='Deal_Reg_PRM';
        	userSelection = 'myRegisteredDeals';
        	objectFilter='';
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
           	userSelection = 'myRejectedDeals';
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
        	ObjectName ='Opportunity';
        	fieldSetName ='My_Opportunities_PRM';	
        	userSelection = 'myOpptys';
        	DealRegistrationController.getRecords(ObjectName,fieldSetName,userSelection,objectFilter,recordTypeName,pageNumber,recordsSize);
			DealRegistrationController.getLead(dealReg1.Id);	
        	DealRegistrationController.saveLead(dealReg1, false);
        	DealRegistrationController.saveLead(dealReg1, true);
        Test.stopTest();
    }
}