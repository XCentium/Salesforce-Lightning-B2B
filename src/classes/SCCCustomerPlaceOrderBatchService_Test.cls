@IsTest
public class SCCCustomerPlaceOrderBatchService_Test {

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
        SCCTestDataFactory.createAccount(1, 'Default', false);
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'order_no'=>'SFCC_Order_Number__c', 'crmcontact_id'=>'Order_Contact__c', 'status'=>'Status', 'order_total'=>'SFCC_Order_Total__c'}, 'Order');
        SCCTestDataFactory.createAccount(1, 'Default', false);
    }

    @IsTest
    static void test_create_one() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"' + accounts[0].Id + '","order_total":5},{"order_no":"23456","status":"Draft","crmcontact_id":"' + accounts[0].Id + '","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        List<Order> orders = [SELECT Id, SFCC_Order_Number__c FROM Order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));

    }

    @IsTest
    static void test_create_two() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String body = '[{"order_no":"12345","status":"Draft","order_total":5},{"order_no":"23456","status":"Draft","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        List<Order> orders = [SELECT Id, SFCC_Order_Number__c FROM Order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));

    }

    @IsTest
    static void test_create_three() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"qerqweffdadfasf","order_total":5},{"order_no":"23456","status":"Draft","crmcontact_id":"qerqweffdadfadf","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        List<Order> orders = [SELECT Id, SFCC_Order_Number__c FROM Order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));

    }

    @IsTest
    static void test_create_four() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"asdfasd","order_total":5},{"order_no":"23456","status":"Draft","crmcontact_id":"asdfas","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        System.assertEquals('[{"SFCCOrderNo":"12345","recordId":null,"objectType":null,"errors":{"typeOfError":"System.QueryException","status":"500","errorMessage":"invalid ID field: asdfasd","errorLine":"193"}},{"SFCCOrderNo":"23456","recordId":null,"objectType":null,"errors":{"typeOfError":"System.QueryException","status":"500","errorMessage":"invalid ID field: asdfas","errorLine":"193"}}]', System.JSON.serialize(stas));

    }

    @IsTest
    static void test_create_five() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"' + accounts[0].Id + '","order_total":5},{"order_no":"12346","status":"Draft","crmcontact_id":"' + accounts[0].Id + '","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        List<Order> orders = [SELECT Id, SFCC_Order_Number__c FROM Order];
        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();
        for (Order order : orders){
        	respList.add(SCCCustomerOrderResponse.createResponse(order));
        }
        System.assertEquals(System.JSON.serialize(respList), System.JSON.serialize(stas));
    }

    @IsTest
    static void test_create_six() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"' + contacts[0].Id + '","order_total":5},{"order_no":"12345","status":"Draft","crmcontact_id":"' + contacts[0].Id + '","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        System.assertEquals('[{"SFCCOrderNo":null,"recordId":null,"objectType":null,"errors":{"typeOfError":"System.SObjectException","status":"500","errorMessage":"Invalid data, Is PersonAccount Enabled: true","errorLine":"38"}}]', System.JSON.serialize(stas));

    }


    @IsTest
    static void test_create_seven() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY CreatedDate DESC];
        String body = '[';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        System.assertEquals('[{"SFCCOrderNo":null,"recordId":null,"objectType":null,"errors":{"typeOfError":"System.JSONException","status":"500","errorMessage":"Unexpected end-of-input: expected close marker for ARRAY (from [line:1, column:3]","errorLine":"11"}}]', System.JSON.serialize(stas));

    }

    @IsTest
    static void test_missingDefaultAccount() {
        List<Account> defaultAccs = [SELECT Id FROM Account WHERE Name='Default'];
        delete defaultAccs;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        String body = '[{"order_no":"12345","status":"Draft","crmcontact_id":"asdfasd","order_total":5},{"order_no":"23456","status":"Draft","crmcontact_id":"asdfas","order_total":5}]';
        req.requestBody = Blob.valueOf(body);
        req.requestURI = '/services/apexrest/Order/Placement/Batch';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        List<SCCCustomerOrderResponse> stas = SCCCustomerPlaceOrderBatchService.create();
        System.assertEquals('[{"SFCCOrderNo":null,"recordId":null,"objectType":null,"errors":{"typeOfError":"Missing Default Account.","status":"500","errorMessage":"Order synchronization has failed due to missing default account in CRM. Please contact Admin of CRM.","errorLine":""}}]', System.JSON.serialize(stas));
    }
}