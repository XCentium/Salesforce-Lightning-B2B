/**
* Rest Service class for post order informations' details => Customer Place Order
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(UrlMapping='/Order/Placement/*')
global with sharing class SCCCustomerPlaceOrderService {

    static final String OBJECT_NAME = 'Order';

    /**
    * This is the method using on "GET" requests.
    * @return List<Order>.
    */
    @HttpGet
    global static List<Order> show() {
        Id recordId = RestContext.request.requestURI.replace('/Order/Placement/', '');
        List<Order> returnList = new List<Order>();
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName(OBJECT_NAME)
            .setAllFields()
            .setClause('Id = \'' + recordId + '\'')
            .getQuery();
        returnList = (List<Order>)SCCQueryUtilClass.getRecords(query);
        return returnList;
    }

    /**
    * This is the method using on "POST" requests.
    * @return SCCReturnResponse.
    */
    @HttpPost
    global static SCCReturnResponse create() {

        // Initialize local variables
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCReturnResponse response;
        SObject sobj;

        try {

            // Create a map containing the key / value pair properties from the rest payload
        	Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            // Was an accountId specified in the rest-payload?
            if(!String.isEmpty((String)jsonMap.get('account_id'))){

                // If so, then attempt to retrieve the account-object via the id
 				sobj = SCCUtilityClass.getSojectByRefId((String)jsonMap.get('account_id'));

            }

            // Are personAccounts enabled?  If so, then move forward with creating the account / order record
            if (SCCUtilityClass.isPersonAccountEnabled() && (sobj instanceof Account || sobj == null)) {

                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account enabled. Creating account order: '+sobj);
                response = createAccountOrderRecord(jsonMap, logger);

            // Otherwise, throw an error -- having Person Account enablement is a mandate for B2C CC Connectors
            } else {

                logger.debug('SCCCustomerPlaceOrderService.create', 'Supplied data in incorrect. OR this Org doesnt support person account');
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());

            }

        } catch(Exception e) {

            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            response = SCCReturnResponse.createError(e);

        } finally {

            logger.flush();

        }

        return response;

    }

    /**
    * This is the method using on "POST" requests
    * @return SCCReturnResponse.
    */
    static SCCReturnResponse createAccountOrderRecord(Map<String, Object> jsonMap, SCCFileLogger logger){

        try {

            // First, retrieve an instance of the defaultAccount
	        Account defaultAccount = SCCUtilityClass.getDefaultAccount();

            // Initialize the customerId / customerNo properties
            String customerlist_id = (String)jsonMap.get('customerlist_id');
            String site_id = (String)jsonMap.get('site_id');
            String customer_id = (String)jsonMap.get('customer_id');
            String customer_no = (String)jsonMap.get('customer_no');

            // Was the defaultAccount found?
	        if (defaultAccount == null) {

                // If not, throw an error calling out that the account wasn't found
	        	logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', ' -- missing defaultAccount error');
                return SCCReturnResponse.createDefaultAccountError();

	        }

            // Did the rest payload include an order_no?
			if (jsonMap.containsKey('order_no')) {

                // If so, search for the order within the current site
                String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName(OBJECT_NAME)
                    .setRelatedFields(new Set<String>{'Id', 'AccountId', 'Name', 'OrderNumber', 'SFCC_Order_Number__c'})
                    .setClause('SFCC_Site_ID__c = \'' + (String)jsonMap.get('site_id') + '\' and SFCC_Order_Number__c = \'' + (String)jsonMap.get('order_no') + '\'')
                    .getQuery();

                // Retrieve the order (scoped by the current site)
                List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);

            	Map<String, SObject> orderFieldMappings = SCCUtilityClass.getAllCustomSettingValues(OBJECT_NAME, logger);
            	Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, OBJECT_NAME, orderFieldMappings, logger);

                if(!orderList.isEmpty()) {

                    // Existing order processing
                    record = orderList.get(0);

                    // Evaluate and write the customer / site properties if they exist
                    // Write the customerList back to the order
                    if (String.isEmpty(record.SFCC_CustomerList_ID__c)) {
                        record.SFCC_CustomerList_ID__c = customerlist_id;
                    }

                    // Write the siteId back to the order
                    if (String.isEmpty(record.SFCC_Site_ID__c)) {
                        record.SFCC_Site_ID__c = site_id;
                    }

                    // Write the customerId back to the order
                    if (String.isEmpty(record.SFCC_Customer_ID__c)) {
                        record.SFCC_Customer_ID__c = customer_id;
                    }

                    // Write the customerNumber back to the order
                    if (String.isEmpty(record.SFCC_Customer_Number__c)) {
                        record.SFCC_Customer_Number__c = customer_no;
                    }

                    // Set the update state of the order -- and process the update
                    record.Order_SCCSync_Status__c = 'Updated';
                    Database.update(record, true);

                    //Initiate a asynch request to SFCC to get Payment, Shipping, Line Items and other additional details.
                    SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, OBJECT_NAME);

                    return SCCReturnResponse.createResponse(record.Id);

                } else {

                    // Evaluate and write the customer / site properties if they exist
                    if (String.isNotEmpty(customerlist_id)) { record.SFCC_CustomerList_ID__c = customerlist_id; }
                    if (String.isNotEmpty(site_id)) { record.SFCC_Site_ID__c = site_id; }
                    if (String.isNotEmpty(customer_id)) { record.SFCC_Customer_ID__c = customer_id; }
                    if (String.isNotEmpty(customer_no)) { record.SFCC_Customer_Number__c = customer_no; }

                    // New Order processing; ensuring successful sync
                    if(jsonMap.containsKey('account_id') && jsonMap.get('account_id') != null) {

                        // Evaluate if the createdBy was written as part of the overall request
                        if (jsonMap.containsKey('created_by') && jsonMap.get('created_by') != null) {

                            // Was an agent user-name included in the request?
                            if ((String)jsonMap.get('created_by') != 'Customer') {
                                record.SFCC_OrderSourceType__c = (String)jsonMap.get('created_by');
                            }

                        }

                        query = SCCQueryUtilClass.getInstance()
                            .getQueryInstance()
                            .setObjectName('Account')
                            .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                            .setClause('Id = \'' + (String)jsonMap.get('account_id') + '\'')
                            .getQuery();
                        List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                        if(!accountList.isEmpty()) {
                            record = additionalFieldsforNewOrder(record);
                            record.isContactIdExist__c = true;
                            record.Order_Contact__c = accountList[0].PersonContactId;
                            record.AccountId = accountList[0].Id;
                            Database.insert(record, true);

                            //Initiate a asynch request to SFCC to get Payment, Shipping, Line Itema and other additional details.
                            SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, OBJECT_NAME);
                        } else {
                            record = additionalFieldsforNewOrder(record);
                            record.Order_Contact__c = null;
                            record.AccountId = defaultAccount.Id;
                            Database.insert(record, true);

                            //Initiate a asynch request to SFCC to get Payment, Shipping, Line Itema and other additional details.
                            SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, OBJECT_NAME);
                        }
                    } else {
                        record = additionalFieldsforNewOrder(record);
                        record.AccountId = defaultAccount.Id;
                        Database.insert(record, true);

                        //Initiate a asynch request to SFCC to get Payment, Shipping, Line Itema and other additional details.
                        SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, OBJECT_NAME);
                    }
                    return SCCReturnResponse.createResponse(record.Id);
                }
            }else{
				logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', ' -- missing default account exception');
				return SCCReturnResponse.createDefaultAccountError();
            }
        } catch(Exception e) {
            logger.error('SCCCustomerPlaceOrderService.createAccountOrderRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return SCCReturnResponse.createError(e);
        }
    }



    /**
    * This method used for populating additional and required fields for order object
    * @param record: Order
    * @return Order.
    */
    public static Order additionalFieldsforNewOrder(Order record) {

        // Seed the default collection of order properties
        record.EffectiveDate = System.today();
        record.from_SFCC__c = true;
        record.Order_SCCSync_Status__c = 'Created';

        // Only apply a default status if one hasn't been defined
        if (String.isNotEmpty(record.Status)) {
            record.Status = 'Draft';
        }

        // Return the updated record detail
        return record;

    }

}