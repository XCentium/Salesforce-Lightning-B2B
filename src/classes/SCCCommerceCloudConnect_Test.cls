@IsTest
public class SCCCommerceCloudConnect_Test {

    @TestSetup
    static void setup() {

        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount(1, 'test account', false);
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
    }

    @IsTest
    static void testSearchCustomerByEmail() {

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        ccConnect.searchCustomerByEmail('test@hotmail.com', 'abcedfghij');
        Test.stopTest();

	}

    @IsTest
    static void testConnectToCommerceCloud2ProfileOperations() {

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ccConnect.connectToCommerceCloud2ProfileOperations();
        Test.stopTest();
	}

    @IsTest
    static void testGetCustomerAuthToken() {

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        ccConnect.getCustomerAuthToken('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
	}

    @IsTest
    static void testConnectToCommerceCloud(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        ccConnect.connectToCommerceCloud();
        Test.stopTest();

    }

    @IsTest
    static void testGetOrderDetails(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Establish the mock / test data set to use
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));

        Test.startTest();
        ccConnect.getOrderDetails('00001603', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @IsTest
    static void testGetCustomerDetails(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Establish the mock / test data set to use
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));

        Test.startTest();
        ccConnect.getCustomerDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testGetAddressDetails(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Establish the mock / test data set to use
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddresses'));

        Test.startTest();
        ccConnect.getAddressDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testPostAddressDetails() {

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Establish the mock / test data set to use
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddress'));

        // Build out the order-post request representing the address to test
        String reqBody = '{"address_id":"my_home_address""salutation":"","title":"","company_name":"",';
        reqBody += '"first_name":"","second_name":"","last_name":"","postal_code":"","address1":"",';
        reqBody += '"address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';

        Test.startTest();
        ccConnect.postAddressDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testUpdateCCCustomerProfile_One(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Establish the mock data-set that will be used by this test
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));

        // Define the request details representing the customer's details being posted
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';

        Test.startTest();
        ccConnect.updateCCCustomerProfile(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();

    }

    @IsTest
    static void testPushOrderDetails(){

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the customer-list and site identifiers
        ccConnect.setCustomerListId('RefArch');
        ccConnect.setSiteId('RefArch');

        // Attach the logger to the connect-class
        ccConnect.logger = logger;

        // Initialize the mock data-set used by this test
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));

        // Define the request body that will be pushed to Commerce Cloud
        String reqBody = '{"_resource_state" : "847f9c3c5867f641470b3046aeec31f07757991b792d722e10079926f7a289fb","status" : "replaced"}';

        Test.startTest();
        ccConnect.pushOrderDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testinitiateAsynchOperation() {

        // Initialize the test with mock data
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));

        // Retrieve the test order
		Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        SCCCommerceCloudConnect.initiateAsynchOperation(order.Id, null, 'Order');
        Test.stopTest();

    }

}