@IsTest
public class SCCCustomerCaseMgmtService_Test {

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
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createAccountOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'contact_id'=>'SFCC_Customer_Id__c', 'order_no'=>'SFCC_Order_No__c', 'case_type'=>'Type', 'description'=>'Description', 'title'=>'Subject', 'enquiry_type'=>'Status'}, 'Case');
        //SCCTestDataFactory.createCase(1, [SELECT Id FROM Contact LIMIT 1].Id, 'test description', 'Contact us', 'test title');
        SCCTestDataFactory.createAccountCase(1, [SELECT Id FROM Account LIMIT 1].Id, 'test description', 'Contact us', 'test title');
    }

    @IsTest
    static void testCreate_one() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = [SELECT Id, SFCC_Customer_Id__pc, FirstName, LastName, PersonEmail FROM Account LIMIT 1];
        req.requestBody = Blob.valueOf('{"account_id":"'+acc.Id+'","first_name":"' + acc.FirstName + '","last_name":"' + acc.LastName + '","email":"' + acc.PersonEmail + '","order_no":"12345","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Customer_Id__c = :acc.SFCC_Customer_Id__pc AND SFCC_Order_No__c = '12345'].Id)), System.JSON.serialize(stas));

    }

    @IsTest
    static void testCreate_two() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@testing.com","order_no":"98765","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Order_No__c = '98765'].Id)), System.JSON.serialize(stas));
    }

    @IsTest
    static void testCreate_three() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@yahoo.com","order_no":"98765","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Order_No__c = '98765'].Id)), System.JSON.serialize(stas));
    }

    @IsTest
    static void testCreate_four() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","email":"test@testing.com","order_no":"98765","title":"test title case","description":"test description case","case_type":"Contact us","test":"test","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Order_No__c = '98765'].Id)), System.JSON.serialize(stas));
    }

    @IsTest
    static void testCreate_five() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Broken Json
        req.requestBody = Blob.valueOf('{"');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unexpected end-of-input: was expecting closing \'\\"\' for name at [line:1, column:5]","errorLine":"11"}}', System.JSON.serialize(stas));
    }

    @IsTest
    static void testCreate_six() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@testing.com","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","order_no":"12345","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Customer_Id__c = '5000Q000000rFSiQAM' AND SFCC_Order_No__c = '12345'].Id)), System.JSON.serialize(stas));

    }

    @IsTest
    static void testCreate_seven() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","order_no":"12345","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.SObjectException","status":"500","errorMessage":"Mandatory field email is missing","errorLine":"188"}}', System.JSON.serialize(stas));

    }

    @IsTest
    static void testCreate_eight() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","email":"test@yahoo.com","contact_id":"5000Q000000rFSiQAM","customer_id":"5000Q000000rFSiQAM","order_no":"12345","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals(System.JSON.serialize(SCCReturnResponse.createResponse([SELECT Id FROM Case WHERE SFCC_Customer_Id__c = '5000Q000000rFSiQAM' AND SFCC_Order_No__c = '12345'].Id)), System.JSON.serialize(stas));

    }

    @IsTest
    static void testCreate_nine() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"first_name":"testFName","last_name":"testLName","customer_id":"5000Q000000rFSiQAM","order_no":"12345","title":"test title case","description":"test description case","case_type":"Contact us","enquiry_type":"New"}');
        req.requestURI = '/services/apexrest/Case';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        SCCReturnResponse stas = SCCCustomerCaseMgmtService.create();
        System.assertEquals('{"recordId":null,"objectType":null,"errors":{"typeOfError":"System.SObjectException","status":"500","errorMessage":"Mandatory field email is missing","errorLine":"188"}}', System.JSON.serialize(stas));

    }

    @IsTest
    static void testShow_one() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Case/' + [SELECT Id FROM Case LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Case> stas = SCCCustomerCaseMgmtService.show();
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('Case')
            .setAllFields()
            .getQuery();
        List<Case> caseList = SCCQueryUtilClass.getRecords(query);
        System.assertEquals(caseList, stas);

    }

    @IsTest
    static void testShow_two() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Case/' + [SELECT Id FROM Contact LIMIT 1].Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        List<Case> stas = SCCCustomerCaseMgmtService.show();
        String query = SCCQueryUtilClass.getInstance()
                                      .getQueryInstance()
                                      .setObjectName('Case')
                                      .setRelatedFields(new Set<String>{'Id', 'Subject', 'Status', 'LastModifiedDate'})
                                      .setClause('ContactId = \'' + [SELECT Id FROM Contact LIMIT 1].Id + '\'')
                                      .getQuery();
        List<Case> caseList = SCCQueryUtilClass.getRecords(query);
        System.assertEquals(caseList, stas);
    }

}