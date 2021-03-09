/**
* This is a helper class to support the Account specific Synch operations with SFCC.
* @author Neeraj Yadav
* @version 1.0
* @since 2018-01-15
*/
public with sharing class SCCAccountHelper  {

    public Boolean continueWithObject(Id accountId){

        // Initialize an instance of the current logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // Retrieve the collection of field mappings for personAccounts
            Map<String, SObject> accountFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);

            // Create a new instance of the SCCCommerceCloudConnect class
            SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

            // Retrieve the account details -- and include the siteId / customerlistId
            String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Account')
                .setRelatedFields(new Set<String>{'Id', 'FirstName', 'LastName', 'PersonEmail', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc', 'SFCC_Site_ID__pc', 'SFCC_CustomerList_ID__pc'})
                .setClause('Id', '=', '\'' + accountId + '\'')
                .setLimit('1')
                .getQuery();
            List<Account> accountRecords = (List<Account>)SCCQueryUtilClass.getRecords(query);

            // Pull the account and fill the Commerce Cloud identifiers
            Account accountRecord = accountRecords.get(0);
            String customerNo = accountRecord.SFCC_Customer_Number__pc;
            String customerId = accountRecord.SFCC_Customer_Id__pc;
            String siteId = accountRecord.SFCC_Site_ID__pc;
            String customerListId = accountRecord.SFCC_CustomerList_ID__pc;

            // Scope the Commerce Cloud interactions by the order's site
            ccConnect.setSiteId(siteId);
            ccConnect.setCustomerListId(customerListId);

            // Retrieve the customer profile and address-book details via Commerce Cloud
            String resBody = ccConnect.getCustomerDetails(customerNo, ccConnect.connectToCommerceCloud());
            String addressBody = ccConnect.getCustomerDetailsById(customerId, ccConnect.connectToCommerceCloud());
            logger.debug('SCCAccountQueueable.execute','resBody: ' + resBody + ' addressBody: '+addressBody);

            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            Map<String, Object> addressJsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(addressBody);
            jsonMap.put('auth_type', addressJsonMap.get('auth_type'));
            jsonMap.put('addresses', addressJsonMap.get('addresses'));
            logger.debug('SCCAccountQueueable.execute','after adding address jsonMap: ' + System.JSON.serialize(jsonMap));

            // Update the account to leverage the account field-mapping properties
            Account updatedAccount = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', accountFieldMappings, logger);
            updatedAccount.Contact_Status__pc = 'Synchronised';
            updatedAccount.From_SFCC__pc = true;
            updatedAccount.Id = accountRecord.Id;
            Database.update(updatedAccount, true);

            // Were any addresses processed?  If so, then process the addresses as well
            if(addressJsonMap.containsKey('addresses') && !((List<Object>)addressJsonMap.get('addresses')).isEmpty()){
               SCCAccountHelper.upsertAddressBook(updatedAccount.Id, (List<Object>)addressJsonMap.get('addresses'));
            }

            // This is add any client specific customization.
            SCCAccountHelper.updateAdditionalAttributes(updatedAccount, jsonMap, logger);
            return true;
        } catch (Exception e) {

            // Audit any exceptions caught during record processing
            logger.error('SCCAccountQueueable.execute', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return false;
        } finally {

            logger.flush();

        }
    }

    public static void upsertAddressBook(Id recordId, List<Object> addressJsonMap) {

        // Initialize the logger instance
        SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // Prepare the collection of addresses to update
            logger.debug('SCCAccountHelper.upsertAddressBook',' recordId: ' + recordId + ' addressJsonMap: ' + addressJsonMap);
            Map<String, SObject> addressFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Address', logger);
            List<Address__c> contactAddressList = new List<Address__c>();
            Account personAccount = SCCUtilityClass.getPersonAccount(recordId);
            String contactId = personAccount.PersonContactId;

            // Iterate over the collection of addresses and process them
            for (Object obj : addressJsonMap) {

                // Create a reference to the current address
                Map<String, Object> tempMap = (Map<String, Object>)obj;
                Address__c record = (Address__c)SCCUtilityClass.initializeObject(tempMap, 'Address__c', addressFieldMappings, logger);
                Address__c address = SCCUtilityClass.getContactAddress(String.valueOf(tempMap.get('address_id')), contactId, String.valueOf(recordId) );

                // Was a valid address object found?  If so, map the address
                if (address != null && address.Id != null) {
                    record.Id = address.Id;
                }

                // Was a contactId found?  If so, associate the address to the contact
                if (String.isNotEmpty(contactId)) {
                    record.Contact__c =  contactId;
                }

                // Map the account and tag the address as from SFCC
                record.Account__c = recordId;
                record.from_SFCC__c = true;

                // Push this address into a list for batch processing
                contactAddressList.add(record);

            }

            // Update the collection of addresses
            Database.upsert(contactAddressList);

        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCAccountHelper.upsertAddressBook', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());

        } finally {

            logger.flush();

        }

    }

    /**
    * This method patch customer profile in commerce cloud. This is called usually by triggers
    * in service cloud when contact or account is updated in service cloud.
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */
    public static Boolean patchCustProfile(Map<String, Object> patchDataMap, Account acc){

        // Initialize the logger and local processing variables
        SCCFileLogger logger = SCCFileLogger.getInstance();
        Map<String, Object> jsonObjMap;
        Boolean result = false;

        try {

            // Initialize the account object using the patch-data properties
            jsonObjMap = SCCJsonUtil.initializeJsonObject(patchDataMap, 'Account', logger);

            // Serialize the JSON patch / update properties map
            String body = (String)System.JSON.serialize(jsonObjMap);

            // Audit and process the patch request via Commerce Cloud and push the account updates
            logger.debug('SCCAccountHelper.patchCustProfile','Profile Patch request body: '+ body);
            patchCustProfileCallOut(body, acc.SFCC_Customer_Number__pc, acc.SFCC_Site_ID__pc, acc.SFCC_CustomerList_ID__pc);
            result = true;

        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCAccountHelper.patchCustProfile', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());

        } finally {

            logger.flush();

        }

        return result;
    }

    /**
    * This method is wrapper method to call webservice asynchronously.
    * @param patchDataMap: Map<String, Object>
    * @return Boolean.
    */
    @Future (Callout=true)
    static void patchCustProfileCallOut(String body, String customerNo, String siteId, String customerListId){

        // Create an instance of the file-logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        try {

            // Initialize the SFCC Connector logger
            ccConnect.logger = logger;

            // Attach the siteId and customerListId to the SFCC Connector
            ccConnect.setSiteId(siteId);
            ccConnect.setCustomerListId(customerListId);

            // Push the request to update the customer's Commerce Cloud profile
            ccConnect.updateCCCustomerProfile(body, customerNo, ccConnect.connectToCommerceCloud2ProfileOperations());

        } catch(Exception e) {

            // Log and audit any error message that is caught during processing
            logger.error('SCCAccountHelper.patchCustProfileCallOut', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());

        } finally {

            logger.flush();

        }

    }

    /**
    * This method is to implement client specific customizations
    * @param updatedAccount: Account
    * @param jsonMap: Map<String, Object>
    * @param logger: SCCFileLogger
    * @return None.
    */
    public static void updateAdditionalAttributes(Account updatedAccount, Map<String, Object> jsonMap, SCCFileLogger logger){}

}