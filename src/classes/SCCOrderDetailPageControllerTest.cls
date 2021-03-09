@IsTest
public class SCCOrderDetailPageControllerTest {

    @TestSetup
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'Default', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'status'=>'status', 'order_no'=>'SFCC_Orde_Number__c', 'order_total'=>'SFCC_Order_Total__c', 'customer_info'=>'Contact__c'}, 'Order');
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);

    }

    @IsTest
    static void test_method_one() {

        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Test.startTest();
        Order c = [SELECT Id, SFCC_Site_ID__c, SFCC_CustomerList_ID__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        SCCOrderDetailPageController handler = new SCCOrderDetailPageController(std);
        List<SCCOrderDetailPageController.OrderWrapper> inner_handler = handler.getOrders();
        Test.stopTest();

    }

    @IsTest
    static void test_method_two() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Order c = [SELECT Id, SFCC_Site_ID__c, SFCC_CustomerList_ID__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        SCCOrderDetailPageController handler = new SCCOrderDetailPageController(std);
        List<SCCOrderDetailPageController.OrderWrapper> inner_handler = handler.getOrders();
        Test.stopTest();

    }

    @IsTest
    static void test_method_three() {

        Test.startTest();
        Order c = [SELECT Id, SFCC_Order_Number__c FROM Order LIMIT 1];
        c.SFCC_Order_Number__c = '';
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        SCCOrderDetailPageController handler = new SCCOrderDetailPageController(std);
        Test.stopTest();

    }

}