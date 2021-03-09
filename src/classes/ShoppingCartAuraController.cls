public with sharing class ShoppingCartAuraController {

    // Initialize the logger
    static SCCFileLogger logger = SCCFileLogger.getInstance();

    // Initialize the output site-properties
    public class SiteParams {
        public String siteId { get; set; }
        public String customerListId { get; set; }
        public String customerId { get; set; }
        public String customerNo { get; set; }
    }

    @AuraEnabled
    public static String initComponent (String recordId, String objectName) {

        SiteParams responseObj = new SiteParams();

        // Are personAccounts enabled for this implementation?
        if (SCCUtilityClass.isPersonAccountEnabled()) {

            // Is the current record being processed an account?
            if (objectName == 'Account') {

                // Retrieve the account details -- focusing on the Commerce identifiers
                Account account = [SELECT Id, SFCC_Site_ID__pc, SFCC_CustomerList_ID__pc, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id = :recordId];

                // Default the response
                responseObj.siteId = account.SFCC_Site_ID__pc;
                responseObj.customerListId = account.SFCC_CustomerList_ID__pc;
                responseObj.customerId = account.SFCC_Customer_Id__pc;
                responseObj.customerNo = account.SFCC_Customer_Number__pc;

                // Otherwise, is the current object being processed a case?
            } else if (objectName == 'Case') {

                // Retrieve the case-details -- focusing on the account properties
                Case[] records = [SELECT Id, SFCC_Site_ID__c, SFCC_CustomerList_ID__c, SFCC_Customer_Id__c, SFCC_Customer_Number__c, Account.Id, ContactEmail FROM Case WHERE Id = :recordId];

                // Default the response using the case properties
                responseObj.siteId = records[0].SFCC_Site_ID__c;
                responseObj.customerListId = records[0].SFCC_CustomerList_ID__c;
                responseObj.customerId = records[0].SFCC_Customer_Id__c;
                responseObj.customerNo = records[0].SFCC_Customer_Number__c;

                // Were any case records retrieved?
                if (!records.isEmpty()) {

                    // Retrieve the account details -- focusing on the Commerce identifiers
                    Account account = [SELECT Id, SFCC_Site_ID__pc, SFCC_CustomerList_ID__pc, SFCC_Customer_Id__pc, SFCC_Customer_Number__pc FROM Account WHERE Id = :records[0].Account.Id];

                    // Were any case records retrieved?
                    if (!records.isEmpty()) {

                        // Overwrite the response using the account properties
                        // but only over-write if a valid value is defined on the account

                        // Overwrite the siteId property
                        if (String.isNotEmpty(account.SFCC_Site_ID__pc)) {
                            responseObj.siteId = account.SFCC_Site_ID__pc;
                        }

                        // Overwrite the customerList property
                        if (String.isNotEmpty(account.SFCC_CustomerList_ID__pc)) {
                            responseObj.customerListId = account.SFCC_CustomerList_ID__pc;
                        }

                        // Overwrite the customerId property
                        if (String.isNotEmpty(account.SFCC_Customer_Id__pc)) {
                            responseObj.customerId = account.SFCC_Customer_Id__pc;
                        }

                        // Overwrite the customerNumber property
                        if (String.isNotEmpty(account.SFCC_Customer_Number__pc)) {
                            responseObj.customerNo = account.SFCC_Customer_Number__pc;
                        }

                    }

                }

            }

        }

        // Return the response object
        return JSON.serialize(responseObj);

    }

    @AuraEnabled
    public static String getStoreSessionURL (String siteId) {

        // Initialize and default the storefront url
        String storeSessionURL = null;

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Set the siteId within the SFCC connector
        ccConnect.setSiteId(siteId);

        // Build out the site-specific session-url
        storeSessionURL = ccConnect.siteBaseUrl + '/s/' + siteId + '/dw/shop/v17_4/sessions';

        // Return the url
        return storeSessionURL;

    }

    @AuraEnabled
    public static String getStoreFrontURL (String siteId) {

        // Initialize and default the storefront url
        String storeFrontURL = null;

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Set the siteId within the SFCC connector
        ccConnect.setSiteId(siteId);

        // Build out the site-specific session-url
        storeFrontURL = ccConnect.siteBaseUrl + '/on/demandware.store/Sites-' + siteId + '-Site/default/';

        // Retrive the oobo pipline-redirect url
        String ooboPipelineRedirectUrl = getOboPipelineRedirectUrl(siteId);

        // Evaluate if a valid pipeline redirect url was defined; if so -- then append it to the storefront url
        if (String.isNotEmpty(ooboPipelineRedirectUrl)) { storeFrontURL += ooboPipelineRedirectUrl; }

        // Return the storefront url
        return storeFrontURL;

    }

    @AuraEnabled
    public static String getAccessToken (String siteId, String customerId) {

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize local variables
        ccConnect.logger = logger;

        logger.debug('ShoppingCartAuraController', '-- getAccessToken');
        logger.debug('ShoppingCartAuraController', '-- siteId: ' + siteId);

        // Set the siteId within the Commerce connector
        ccConnect.setSiteId(siteId);

        // Initialize the placeholder variables
        String customerAuthToken = null;
        String sfccCustomerId = customerId;

        try {

            // Generate an access token from Commerce Cloud
            String agentAccessToken = ccConnect.connectToCommerceCloud();

            logger.debug('ShoppingCartAuraController', '-- getAccessToken: ' + agentAccessToken);

            // Was a valid customerId provided?
            if (String.isEmpty(sfccCustomerId)) {

                // If not, then get the site-specific guest customer-recordId
                sfccCustomerId = getGuestCustomerRecordID(siteId);

            }

            // Was a valid token generated?
            if (agentAccessToken != null && agentAccessToken != '' ){

                // If so, retrieve the customer-auth token for order-on-behalf-of
                customerAuthToken = ccConnect.getCustomerAuthToken(agentAccessToken, sfccCustomerId);

            }

            // Return the customer-access token
            return customerAuthToken;

        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('ShoppingCartAuraController.getAccessToken', 'Exception message : ' + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return customerAuthToken;

        } finally {

            logger.flush();

        }

    }

    public static String getOboPipelineRedirectUrl (String siteId) {

        // Retrieve the pipeline-redirect url for the current site
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('SFCCConfiguration__c')
            .setRelatedFields(new Set<String>{'Id', 'Name', 'SFCC_OOBO_Auth_Redirect_Pipeline__c'})
            .setClause('Site_ID__c = \'' + siteId + '\'')
            .setLimit('1')
            .getQuery();

        // Process the results and turn it into an object-list for easy reference
        List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);

        // Return the pipeline redirect-url value
        return objList[0].SFCC_OOBO_Auth_Redirect_Pipeline__c;

    }

    public static String getGuestCustomerRecordID (String siteId) {

        // Retrieve the placeholder guest OOBO order-number url for the current site
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('SFCCConfiguration__c')
            .setRelatedFields(new Set<String>{'Id', 'Name', 'Placeholder_OOBO_SFCC_Customer_ID__c'})
            .setClause('Site_ID__c = \'' + siteId + '\'')
            .setLimit('1')
            .getQuery();

        // Process the results and turn it into an object-list for easy reference
        List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);

        // Return the pipeline redirect-url value
        return objList[0].Placeholder_OOBO_SFCC_Customer_ID__c;

    }

}