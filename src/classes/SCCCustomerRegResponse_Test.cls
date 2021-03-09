@IsTest
public class SCCCustomerRegResponse_Test {

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
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
        SCCTestDataFactory.createAccount(1, 'Default', false);
    }

	@IsTest
	static void test_createResponse_one() {
		Account acc = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account LIMIT 1];
		SCCCustomerRegResponse coResp = SCCCustomerRegResponse.createResponse(acc.Id);
	}

	@IsTest
	static void test_createResponse_two() {
		Account acc = [SELECT Id, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account LIMIT 1];
		SCCCustomerRegResponse coResp = SCCCustomerRegResponse.createResponse(acc);
	}

	@IsTest
	static void test_createResponse_three() {
		Contact cont = [SELECT Id, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact LIMIT 1];
		SCCCustomerRegResponse coResp = SCCCustomerRegResponse.createResponse(cont);
	}

	@IsTest
	static void test_createResponse_four() {
		Order ord = [SELECT Id FROM Order LIMIT 1];
		SCCCustomerRegResponse coResp = SCCCustomerRegResponse.createResponse(ord);
	}

	@IsTest
	static void test_createError_one() {
		SCCCustomerRegResponse coResp = SCCCustomerRegResponse.createError(new AsyncException('test exception'));
	}

}