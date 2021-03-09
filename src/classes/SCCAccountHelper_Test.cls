/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @IsTest class annotation indicates this class only contains test
 * methods. Classes defined with the @IsTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
public class SCCAccountHelper_Test {

    @TestSetup
    static void setup() {
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createAccount (
            new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'},
            new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'},
            new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'},
            new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'},
            new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'},
            new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'}
        );
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate'}, 'Account');
    }

    @IsTest
    private static void testUpsertAddressBook_One() {
        String addressBody = '[{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "mea","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"},';
        addressBody += '{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "meb","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"}]';
        List<Object> testAddressObj = (List<Object>)System.JSON.deserializeUntyped(addressBody);
        Account acc = [SELECT Id, SFCC_Customer_Number__pc FROM Account LIMIT 1];
        SCCAccountHelper.upsertAddressBook(acc.Id, testAddressObj);
    }

    @IsTest
    private static void testUpsertAddressBook_Two() {
        String addressBody = '[{"_type" : "customer_address","address1" : "10 Presidential Way","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"},';
        addressBody += '{"_type" : "customer_address","address1" : "10 Presidential Way","address_id" : "meb","city" : "Woburn","country_code" : "US","first_name" : "John","full_name" : "John M. Smith","last_name" : "Smith","postal_code" : "018.3","salutation" : "Mr.","state_code" : "MA"}]';
        List<Object> testAddressObj = (List<Object>)System.JSON.deserializeUntyped(addressBody);
        SCCAccountHelper.upsertAddressBook(null, testAddressObj);
    }

    @IsTest
    private static void testUpsertAddressBook_Three() {
        Account acc = [SELECT Id, SFCC_Customer_Number__pc FROM Account LIMIT 1];
        SCCAccountHelper.upsertAddressBook(acc.Id, null);
    }

    @IsTest
    private static void testPatchCustProfile_One() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Map<String, Object> testPatchMap = new Map<String, Object>{'personbirthdate' => '30-08-1981', 'personemail' => 'nirajyadav@gmail.com', 'active__c' => true};
        Account acc = [SELECT Id, SFCC_Customer_Number__pc FROM Account LIMIT 1];
        Test.startTest();
        Boolean result = SCCAccountHelper.patchCustProfile(testPatchMap, acc);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @IsTest
    private static void testPatchCustProfile_Two() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Map<String, Object> testPatchMap = new Map<String, Object>{'personbirthdate' => '30-08-1981', 'personemail' => 'nirajyadav@gmail.com', 'active__c' => true};
        Test.startTest();
        Boolean result = SCCAccountHelper.patchCustProfile(testPatchMap, null);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @IsTest
    private static void testPatchCustProfile_Three() {
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Map<String, Object> testPatchMap = new Map<String, Object>{'personbirthdate' => '30-08-1981', 'personemail' => 'nirajyadav@gmail.com', 'active__c' => true};
        Account acc = [SELECT Id, SFCC_Customer_Number__pc FROM Account LIMIT 1];
        acc.SFCC_Customer_Number__pc = null;
        Test.startTest();
        Boolean result = SCCAccountHelper.patchCustProfile(testPatchMap, acc);
        System.assertEquals(true, result);
        Test.stopTest();
    }
}