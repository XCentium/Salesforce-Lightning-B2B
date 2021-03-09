public class SCCContactRefreshComponentController {

    // related contact record
    public static Contact contactRecord;

    // related account record
    public static Account accountRecord;

    // customer information
    @AuraEnabled
    public static List<SCCCustomerWrapper> customerList   {get; set;}

    // json map after deserialization
    public static Map<String, Object> jsonMap             {get; set;}

    // json key - label mapping
    public static Map<String, String> jsonKeyMap = new Map<String, String>{
        'customer_id'=>'Customer ID',
        'customer_no'=>'Customer No',
        'email'=>'Email',
        'first_name'=>'First Name',
        'last_name'=>'Last Name',
        'c_sscid'=>'Account Id',
        'c_ssccid'=>'Contact Id',
        'birthday'=>'BirthDay'
    };

    /**
    * This method used to synchonized with customer and contact
    * @return None.
    */
    @AuraEnabled
    public static List<SCCCustomerWrapper> getCustomers(String objectId) {

        // Initialize the file-logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // Are PersonAccounts enabled?
            if (SCCUtilityClass.isPersonAccountExist(objectId)){

                // If so, then retrieve the account details -- and include the site / customerList identifiers for this account
                accountRecord = [SELECT Id, SFCC_Site_ID__pc, SFCC_CustomerList_ID__pc, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id =: objectId];
                return getCustomersData(accountRecord.SFCC_Site_ID__pc, accountRecord.SFCC_CustomerList_ID__pc, accountRecord.SFCC_Customer_Number__pc, logger);

            } else {

                // Otherwise, retrieve the contact details -- and include the site / customerList identifiers
                contactRecord = [SELECT Id, SFCC_Site_ID__c, SFCC_CustomerList_ID__c, SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE Id =: objectId];
                return getCustomersData(contactRecord.SFCC_Site_ID__c, contactRecord.SFCC_CustomerList_ID__c, contactRecord.SFCC_Customer_Number__c, logger);

            }

        } catch(Exception e) {

            // Catch and audit any errors or exceptions while processing
            logger.error('SCCContactRefreshComponentController.getCustomers', 'Exception message : '
                + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return new List<SCCCustomerWrapper>();

        } finally {

            logger.flush();

        }

    }

    /**
    * This method used to getting customer informations from commerce cloud
    * @return List<SCCCustomerWrapper>.
    */
    public static List<SCCCustomerWrapper> getCustomersData(String SFCCSiteId, String SFCCCustomerListId, String SFCCCustomerNo, SCCFileLogger logger) {

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        try {

            // Seed the customerListId from the customer details
            ccConnect.setCustomerListId(SFCCCustomerListId);
            ccConnect.setSiteId(SFCCSiteId);

            // Initialize the customer details container
            customerList = new List<SCCCustomerWrapper>();
            List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();

            // Retrieve the customer details from Commerce Cloud
            String resBody = ccConnect.getCustomerDetails(SFCCCustomerNo, ccConnect.connectToCommerceCloud());
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            logger.debug('SCCContactRefreshComponentController.getCustomers','jsonMap: ' + jsonMap);

            // Loop over the collection of profile properties
            for (String key : jsonMap.keySet()) {

                // Is the current key in the keyMap?
                if (jsonKeyMap.keySet().contains(key)) {

                    // If so, then add the key / value pair to the collection of properties to process
                    returnList.add(new SCCCustomerWrapper(jsonKeyMap.get(key), String.valueOf(jsonMap.get(key))));

                }

            }

            // Add and set the collection of properties
            customerList.addAll(returnList);

            // Return the collection of profile properties
            return returnList;

        } catch(Exception e) {

            // Clear the contents of the customer list
            customerList.clear();

            // Audit any errors or exceptions caught during processing
            logger.error('SCCContactRefreshComponentController.getCustomersData', 'Exception message : '
                    + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return new List<SCCCustomerWrapper>();

        }

    }

    /**
    * This method used to synchonized with customer and contact
    * @return Boolean.
    */
    @AuraEnabled
    public static Boolean syncCustomer(String objectId) {
        Boolean returnValue;
        // Are PersonAccounts enabled?
        if (SCCUtilityClass.isPersonAccountExist(objectId)) {

            // If so, then synchronize personAccounts
            SCCAccountHelper accountHelper = new SCCAccountHelper();
            returnValue = accountHelper.continueWithObject(objectId);

        }
        return returnValue;
    }

}