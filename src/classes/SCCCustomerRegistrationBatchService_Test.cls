@IsTest
public class SCCCustomerRegistrationBatchService_Test {

    @TestSetup
    static void setup() {

        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
    	SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'customer_id'=>'SFCC_Customer_Id__c ', 'customer_no'=>'SFCC_Customer_Number__c ', 'email'=>'Email', 'first_name'=>'FirstName', 'last_name'=>'LastName'}, 'Contact');
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'customer_id'=>'SFCC_Customer_Id__pc ', 'customer_no'=>'SFCC_Customer_Number__pc ', 'email'=>'personEmail', 'first_name'=>'FirstName', 'last_name'=>'LastName'}, 'Account');
    	SCCTestDataFactory.createAccount(1, 'Default', false);
    }

	@IsTest
	static void test_create_one() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"first_name":"test_fname","last_name":"test_lname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"},{"first_name":"test_fnamea","last_name":"test_lnamea","email":"testa@hotmail.com","customer_no":"12346","customer_id":"12456"}]');
        req.requestURI = '/services/apexrest/Contact/Registration/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        List<SCCCustomerRegResponse> stas = SCCCustomerRegistrationBatchService.create();
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();
        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE IsPersonAccount=TRUE];
        for (Account account : accounts){
        	respList.add(SCCCustomerRegResponse.createResponse(account));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));
	}

	@IsTest
	static void test_create_two() {
        SCCTestDataFactory.createAccount (
                new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'},
                new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'},
                new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'},
                new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'}
        );
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"first_name":"test_fname","last_name":"test_lname","email":"test@gmail.com","customer_no":"12345","customer_id":"1245"},{"first_name":"test_fnamea","last_name":"test_lnamea","email":"testa@hotmail.com","customer_no":"12346","customer_id":"12456"}]');
        req.requestURI = '/services/apexrest/Contact/Registration/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        List<SCCCustomerRegResponse> stas = SCCCustomerRegistrationBatchService.create();
        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();
        List<Account> accounts = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE IsPersonAccount=TRUE];
        for (Account account : accounts){
        	respList.add(SCCCustomerRegResponse.createResponse(account));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));
	}

	@IsTest
	static void test_create_three() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[');
        req.requestURI = '/services/apexrest/Contact/Registration/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        List<SCCCustomerRegResponse> stas = SCCCustomerRegistrationBatchService.create();
        System.assertEquals('[{"SFCCCustomerNo":null,"SFCCCustomerId":null,"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unexpected end-of-input: expected close marker for ARRAY (from [line:1, column:3]","errorLine":"11"}}]', System.JSON.serialize(stas));
	}

	@IsTest
	static void test_create_four() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"first_name":"test_fname","last_name":"test_lname","email":"fakeemail","customer_no":"12345","customer_id":"1245"},{"first_name":"test_fnamea","last_name":"test_lnamea","email":"fakeemaila","customer_no":"12346","customer_id":"12456"}]');
        req.requestURI = '/services/apexrest/Contact/Registration/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        List<SCCCustomerRegResponse> stas = SCCCustomerRegistrationBatchService.create();
        System.assert((System.JSON.serialize(stas)).contains('Upsert failed. First exception on row 0; first error: INVALID_EMAIL_ADDRESS, Email: invalid email address: fakeemaila: [PersonEmail]'));
	}

	@IsTest
	static void test_create_five() {
        RestContext.request = null;
        List<SCCCustomerRegResponse> stas = SCCCustomerRegistrationBatchService.create();
        System.assert((System.JSON.serialize(stas)).contains('Attempt to de-reference a null object'));
	}

}