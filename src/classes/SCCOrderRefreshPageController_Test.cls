@IsTest
public class SCCOrderRefreshPageController_Test {

    @TestSetup
    static void setup() {
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount (
                new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'},
                new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'},
                new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'},
                new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'}
        );
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate', 'customer_no'=>'SFCC_Customer_Number__pc', 'customer_id'=>'SFCC_Customer_Id__pc'}, 'Account');
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'Email', 'birthday'=>'BirthDate', 'customer_no'=>'SFCC_Customer_Number__c', 'customer_id'=>'SFCC_Customer_Id__c'}, 'Contact');
        SCCTestDataFactory.createAccountCase(1, [SELECT Id FROM Account LIMIT 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
        SCCTestDataFactory.createCase(1, [SELECT Id FROM Contact LIMIT 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
        SCCTestDataFactory.createOrder(1, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
        SCCTestDataFactory.createAccount(1, 'Default', false);
    }

    @IsTest
    private static void testGetOrders_One(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Order order = [SELECT Id, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
		SCCOrderRefreshPageController.getOrders(order.Id);
        Test.stopTest();
    }

    @IsTest
    private static void testGetOrders_Two(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Test.startTest();
		SCCOrderRefreshPageController.getOrders(null);
        Test.stopTest();
    }

    @IsTest
    private static void testSyncOrder(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Order order = [SELECT Id, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
		SCCOrderRefreshPageController.syncOrder(order.Id);
        Test.stopTest();
    }
}