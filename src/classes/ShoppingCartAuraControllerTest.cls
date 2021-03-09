@IsTest
public with sharing class ShoppingCartAuraControllerTest {

    @TestSetup
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
        SCCTestDataFactory.createAccountCase(1, [SELECT Id FROM Account LIMIT 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
		SCCTestDataFactory.createCase(5, [SELECT Id FROM Contact LIMIT 1].Id, 'Test cases', 'ContactUs','Mr');
    }

    @IsTest
    static void testGetAccessTokenCase() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken([SELECT Id FROM Case WHERE AccountId != NULL LIMIT 1].Id, 'Case');
        Test.stopTest();
    }

    @IsTest
    static void testErrorGetAccessTokenCase() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken('abcd', 'Case');
        Test.stopTest();
    }

    @IsTest
    static void testGetAccessTokenAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken([SELECT Id FROM Case WHERE AccountId != NULL LIMIT 1].Id, 'Account');
        Test.stopTest();
    }

    @IsTest
    static void testErrorGetAccessTokenAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ShoppingCartAuraController.getAccessToken('abcd', 'Account');
        Test.stopTest();
    }

    @IsTest
    static void testGetStoreSessionURL() {
        ShoppingCartAuraController.getStoreSessionURL('RefArch');
    }

    @IsTest
    static void testGetStoreFrontURL() {
        ShoppingCartAuraController.getStoreFrontURL('RefArch');
    }

}