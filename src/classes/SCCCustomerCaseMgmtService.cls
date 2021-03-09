/**
* Rest Service class for get/post case informations' details(Contact us/Service Request)
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-03
*/
@RestResource(UrlMapping='/Case/*')
global with sharing class SCCCustomerCaseMgmtService  {

    /**
    * This is the method using on "GET" requests.
    * @return List<Case>.
    */
    @HttpGet
    global static List<Case> show() {
        Id recordId = RestContext.request.requestURI.replace('/Case/', '');
        String objectName = recordId.getSobjectType().getDescribe().getName();
        List<Case> returnList = new List<Case>();
        if(objectName == 'Contact') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setRelatedFields(new Set<String>{'Id', 'Subject', 'Status', 'LastModifiedDate'})
                    .setClause('ContactId = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>)SCCQueryUtilClass.getRecords(query);
        } else if(objectName == 'Account') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setAllFields()
                    .setClause('AccountId = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>) SCCQueryUtilClass.getRecords(query);
        } else if(objectName == 'Case') {
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Case')
                    .setAllFields()
                    .setClause('Id = \'' + recordId + '\'')
                    .getQuery();
            returnList = (List<Case>)SCCQueryUtilClass.getRecords(query);
        }
        return returnList;
    }

    /**
    * This is the method using on "POST" requests.
    * @return SCCReturnResponse.
    */
    @HttpPost
    global static SCCReturnResponse create() {

        // Initialize the logger
        SCCFileLogger logger = SCCFileLogger.getInstance();
        logger.debug('SCCCustomerCaseMgmtService.create', 'calling create()');

        try {

            // Retrieve all case-mappings from the custom-setting property-list
            Map<String, SObject> caseFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Case', logger);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            // Initialize the case object using the rest payload and the case field-mappings
            Case record = (Case)SCCUtilityClass.initializeObject(jsonMap, 'Case', caseFieldMappings, logger);

            // Capture the first and last-names
            String firstName = (String)jsonMap.get('first_name');
            String lastName = (String)jsonMap.get('last_name');

            String accountId = (String)jsonMap.get('account_id');

            for (String k : jsonMap.keySet())
            {
                System.debug('values are ' + jsonMap.get(k));

            }

            // Append them to the full-name if a lastname is provided
            String fullName = firstName;
            if (String.isNotEmpty(lastName)) {
                fullName += ' ' + lastName;
            }

            // Attach the full-name to the suppliedName case property
            record.SuppliedName = fullName.trim();

            if(jsonMap.containsKey('account_id') && String.isNotBlank((String)jsonMap.get('account_id'))) {
                logger.debug('SCCCustomerCaseMgmtService.create', '-- Processing a case from a registered customer');

                // Scope account searches by the specified customer-list (supports multi-site)
                String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Account')
                    .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                    .setClause('Id = \'' + (String)jsonMap.get('account_id') + '\' and SFCC_CustomerList_ID__pc = \'' + (String)jsonMap.get('customerlist_id') + '\'')
                    .getQuery();

                // Retrieve the account specified in the rest payload
                List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);

                // Was an account found?
                if (!accountList.isEmpty()) {

                    // If so, map the account to the case and create-it
                    record.AccountId = accountList[0].Id;
                    Database.insert(record, true);
                    return SCCReturnResponse.createResponse(record.Id);

                } else {

                    // Otherwise, call out that the account could not be validated
                    logger.debug('SCCCustomerCaseMgmtService.create', 'Provided account_id is invalid: '+jsonMap.containsKey('account_id'));

                    // Does the case contain an email address from the customer submitting?
                    if (jsonMap.containsKey('email')) {

                        // Look for an account using the email address and customerList provided
                        query = SCCQueryUtilClass.getInstance()
                            .getQueryInstance()
                            .setObjectName('Account')
                            .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                            .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\' and SFCC_CustomerList_ID__pc = \'' + (String)jsonMap.get('customerlist_id') + '\'')
                            .getQuery();

                        // Pull the account details
                        accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);

                        // Was an account found?
                        if (!accountList.isEmpty()) {

                            // If so, map the account to the case -- and create it
                            record.AccountId = accountList[0].Id;
                            Database.insert(record, true);
                            return SCCReturnResponse.createResponse(record.Id);

                        } else {

                            // Otherwise, create a new account leveraging the profile provided
                            Account acc = createAccount(jsonMap);
                            record.AccountId = acc.Id;
                            Database.insert(record, true);
                            return SCCReturnResponse.createResponse(record.Id);

                        }

                    } else {

                        // Otherwise, throw an error explaining that an email is required for case processing
                        throw new SObjectException('Mandatory field email is missing and provided salesforce contact_id is invalid');

                    }
                }

            } else {

                // Debugging: audit that the source of this case in a guest / anonymous user
                logger.debug('SCCCustomerCaseMgmtService.create', '-- Processing a case from a guest customer');

                // Was an email included in the profile details?
                if(jsonMap.containsKey('email')) {

                    // Scope account searches by the specified customer-list (supports multi-site)
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Account')
                        .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'PersonContactId'})
                        .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\' and SFCC_CustomerList_ID__pc = \'' + (String)jsonMap.get('customerlist_id') + '\'')
                        .getQuery();
                    List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);

                    // Was a record found representing the customer?
                    if(!accountList.isEmpty()) {

                        // If so, map it to the case -- and create it
                        record.AccountId = accountList[0].Id;
                        Database.insert(record, true);
                        return SCCReturnResponse.createResponse(record.Id);

                    } else {

                        // Otherwise, create a new personAccount representing the customer and attach
                        // the new account record to the case -- and then create it
                        Account acc = createAccount(jsonMap);
                        record.AccountId = acc.Id;
                        Database.insert(record, true);
                        return SCCReturnResponse.createResponse(record.Id);

                    }

                } else {

                    // Otherwise, throw an error explaining that email is required for processing
                    throw new SObjectException('Mandatory field email is missing');

                }

            }

        } catch (Exception e) {

            // Audit any errors / exceptions caught during case processing
            logger.error('SCCCustomerCaseMgmtService.create', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            RestContext.response.statusCode = 500;
            return SCCReturnResponse.createError(e);

        } finally {

            logger.flush();

        }

    }

    /**
    * This method creates new Account using the provided email id
    * and related account properties provided by Commerce Cloud.
    * @return Account.
    */
    static Account createAccount(Map<String, Object> jsonMap){

        // Initialize the account record
        Account record = new Account();

        // Attach the personAccount record-type to the account
        RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
        record.RecordTypeId = recordType.Id;

        // Attach the core identification information
        record.FirstName = (String)jsonMap.get('first_name');
        record.PersonEmail = (String)jsonMap.get('email');

        // Evaluate if a lastname is present
        String lastName = (String)jsonMap.get('last_name');
        if (String.isEmpty(lastName)) {
            lastName = (String)jsonMap.get('first_name');
        }

        // Complete the profile properties
        record.LastName = lastName;

        // Evaluate if the home-phone is present
        String personPhone = (String)jsonMap.get('phone');
        if (!String.isEmpty(personPhone)) {
            record.PersonHomePhone = personPhone;
        }

        // Evaluate if the site / customer identifiers are present
        String customerId = (String)jsonMap.get('customer_id');
        String customerNo = (String)jsonMap.get('customer_no');
        String siteId = (String)jsonMap.get('site_id');
        String customerListId = (String)jsonMap.get('customerlist_id');

        // Attach the SFCC customer identifier to the account
        if (!String.isEmpty(customerId)) {
            record.SFCC_Customer_Id__pc = customerId;
        }

        // Attach the SFCC customer number to the account
        if (!String.isEmpty(customerNo)) {
            record.SFCC_Customer_Number__pc = customerNo;
        }

        // Attach the site / storefront source to the account
        if (!String.isEmpty(siteId)) {
            record.SFCC_Site_ID__pc = siteId;
        }

        // Attach the site's customerlist-id to the account
        if (!String.isEmpty(customerListId)) {
            record.SFCC_CustomerList_ID__pc = customerListId;
        }

        // Create the new personAccount record
        record.Contact_Status__pc  = 'Created';
        Database.insert(record, true);
        return record;

    }

}