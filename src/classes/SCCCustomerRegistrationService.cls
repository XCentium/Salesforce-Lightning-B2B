/**
* Rest Service class for post contact informations' details => Customer Registration
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(UrlMapping='/Contact/Registration/*')
global with sharing class SCCCustomerRegistrationService {

    static final String OBJECT_NAME = 'Account';

    /**
    * This is the method using on "GET" requests.
    * @return List<Account>.
    */
    @HttpGet
    global static List<Account> show() {
        Id recordId = RestContext.request.requestURI.replace('/Contact/Registration/', '');
        List<Account> returnList = new List<Account>();
        String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName(OBJECT_NAME)
                .setAllFields()
                .setClause('Id = \'' + recordId + '\'')
                .getQuery();
        returnList = (List<Account>)SCCQueryUtilClass.getRecords(query);
        return returnList;
    }

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    @HttpPost
    global static SCCCustomerRegResponse create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        SCCCustomerRegResponse response;
        try{
            if(SCCUtilityClass.isPersonAccountEnabled()){
                response = createAccountRecord(RestContext.request, logger);
            } else {
                logger.debug('SCCCustomerRegistrationService.create', 'Supplied data in incorrect. OR this Org doesnt support person account');
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());
            }
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        }finally{
            logger.flush();
        }
        return response;
    }

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    static SCCCustomerRegResponse createAccountRecord(RestRequest request, SCCFileLogger logger){

        // Create an instance of the CommerceCloud Connector
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        try {

            // Initialize the logger
            ccConnect.logger = logger;

            Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues(OBJECT_NAME, logger);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
			Set<String> relatedFields;
            String clause;

            // Initialize the customer / site properties
            String customerNo = (String)jsonMap.get('customer_no');
            String customerId = (String)jsonMap.get('customer_id');
            String siteId = (String)jsonMap.get('site_id');
            String customerListId = (String)jsonMap.get('customerlist_id');

            // First, evaluate if a customer-number was included in the registration details
            if (jsonMap.get('customer_no') != null && jsonMap.get('customer_no') != ''){

                // Resolution criterion 1: search via customer_no
                relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};

                // Either match specifically on the customer number
                clause = 'SFCC_Customer_Number__pc = \'' + (String)jsonMap.get('customer_no') + '\' ';

                // Or, match where the customer numbers are not the same -- but we have matching email addresses and no login exists
                clause += 'or ( SFCC_Customer_Number__pc != \'' + (String)jsonMap.get('customer_no') + '\' and PersonEmail = \'' + (String)jsonMap.get('email') + '\'  and SFCC_Customer_Id__pc = null)';

            } else if (jsonMap.get('customer_id') != null && jsonMap.get('customer_id') != ''){

                // Resolution criterion 2: search via customer_id
                relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};
                clause = 'SFCC_Customer_Id__pc = \'' + (String)jsonMap.get('customer_id') + '\'';

            } else {

                // Resolution criterion 3: if neither of customer_no or customer_id present in request, resolve via email
                relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};
                clause = 'PersonEmail = \'' + (String)jsonMap.get('email') + '\'';

            }

			String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName(OBJECT_NAME)
                .setRelatedFields(relatedFields)
                .setClause(clause)
                .getQuery();
			List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);

            Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, OBJECT_NAME, fieldMappings, logger);
            record.From_SFCC__pc = true;
            record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);

            if (!accountList.isEmpty()) {
                logger.debug('SCCCustomerRegistrationService.createAccountRecord', 'Updating existing account: '+accountList);
                record.Id = accountList[0].Id;
                record.Contact_Status__pc  = 'Updated';
                record.SFCC_update__c = true;
            } else {
                logger.debug('SCCCustomerRegistrationService.createAccountRecord', 'Creating new account');
                RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
                record.RecordTypeId = recordType.Id;
                record.Contact_Status__pc  = 'Created';
            }

            Database.upsert(record, true);

            // This method reference HAS to be static
            SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, OBJECT_NAME);

            // Return the created account response
            return SCCCustomerRegResponse.createResponse(record);

        } catch(Exception e) {

            // Set the error / status code
            RestContext.response.statusCode = 500;

            // Audit any errors or exceptions caught during processing
            logger.error('SCCCustomerRegistrationService.createAccountRecord', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());

            // Return the caught error as a customer response
            return SCCCustomerRegResponse.createError(e);

        }
    }
}