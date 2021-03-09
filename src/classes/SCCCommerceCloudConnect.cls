/**
* Connection class to SFCC(Salesforce Commerce Cloud) and pull related informations
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-06
*/
public with sharing class SCCCommerceCloudConnect {

    /* specified site id on commerce cloud */
    public SCCFileLogger logger {
        get {
            return logger;
        }
        set {
        	logger = value;
        }
    }

    // Initialize the site / customerList properties
    // specified site id on commerce cloud
    public String siteId;

    // specified customer list id on commerce cloud
    public String customerListId;

    // Setter to set the active siteId for a given connection
    public void setSiteId (String SFCCSiteId) {
        siteId = SFCCSiteId;
    }

    // Setter to set the active customerListId for a given connection
    public void setCustomerListId (String SFCCCustomerListId) {
        customerListId = SFCCCustomerListId;
    }

    // Specified base url for commerce cloud platform to connect
    public String siteBaseUrl {
        get {

            System.debug(' -- getting siteId:' + siteId);

            if (String.isBlank(siteBaseUrl)) {
                String query = SCCQueryUtilClass.getInstance()
                  .getQueryInstance()
                  .setObjectName('SFCCConfiguration__c')
                  .setRelatedFields(new Set<String>{'Id', 'Name', 'SFCC_Site_URL__c'})
                  .setClause('Site_ID__c = \'' + siteId + '\'')
                  .setLimit('1')
                  .getQuery();
                List<SFCCConfiguration__c> objList = (List<SFCCConfiguration__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].SFCC_Site_URL__c;
            }
            return siteBaseUrl;
        }
        set;
    }

    /* specified client_id for doing connection with sfcc */
    public String sfccClientId {
        get {
            if (String.isBlank(sfccClientId)) {
                String query = SCCQueryUtilClass.getInstance()
                  .getQueryInstance()
                  .setObjectName('SFCC_Integration_Creds__c')
                  .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Id__c'})
                  .setLimit('1')
                  .getQuery();
                List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Client_Id__c;
            }
            return sfccClientId;
        }
        set;
    }

    /* specified client_id for doing connection with sfcc */
    public String sfccClientSecret {
        get {
            if (String.isBlank(sfccClientSecret)) {
                String query = SCCQueryUtilClass.getInstance()
                  .getQueryInstance()
                  .setObjectName('SFCC_Integration_Creds__c')
                  .setRelatedFields(new Set<String>{'Id', 'Name', 'Client_Secret__c'})
                  .setLimit('1')
                  .getQuery();
                List<SFCC_Integration_Creds__c> objList = (List<SFCC_Integration_Creds__c>)SCCQueryUtilClass.getRecords(query);
                return objList[0].Client_Secret__c;
            }
            return sfccClientSecret;
        }
        set;
    }

    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public String connectToCommerceCloud() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFCCUserCreds/dw/oauth2/access_token?client_id=' + sfccClientId);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:demandware:params:oauth:grant-type:client-id:dwsid:dwsecuretoken');
        Http https = new Http();
        HttpResponse res = https.send(req);
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
        if(jsonMap.containsKey('access_token')) {
            String token = (String)jsonMap.get('access_token');
            if(logger!=null){
				logger.trace('SCCCommerceCloudConnect.connectToCommerceCloud', 'connectToCommerceCloud-access_token : '+ token);
            }
            return token;
        }
        return '';

    }

    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public String connectToCommerceCloud2ProfileOperations() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFCCClientCreds/dw/oauth2/access_token');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(sfccClientId + ':' + sfccClientSecret)));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials');
        Http https = new Http();
        HttpResponse res = https.send(req);
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
        if(jsonMap.containsKey('access_token')) {
            if(logger!=null){
            	logger.trace('SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations', 'connectToCommerceCloud-connectToCommerceCloud2ProfileOperations : '+ (String)jsonMap.get('access_token'));
            }
            return (String)jsonMap.get('access_token');
        }
        return '';

    }

    public String getCustomerAuthToken(String agentToken, String scccustomerid){
		if (logger != null) {
            logger.debug('SCCCommerceCloudConnect.getCustomerAuthToken', 'getCustomerAuthToken agentToken: '+ agentToken + ' scccustomerid: ' + scccustomerid);
        }
        String customerAuthToken = null;
        String relUrl = '/s/'+ siteId +'/dw/shop/v17_4/customers/' + scccustomerid + '/auth';
        HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:SFCCClientCredsBearer'+relUrl);
		req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('Authorization', 'Bearer '+agentToken);
        req.setBody('{}');
		Http https = new Http();
		HttpResponse res = https.send(req);
        customerAuthToken = res.getHeader('authorization');
		if (logger != null) {
        	logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getCustomerAuthToken: res.getBody() '+res.getBody() + 'customerAuthToken '+ customerAuthToken);
        }
		return customerAuthToken;
    }

    /**
    * This method used for pulling selected order details from commerce cloud.
    * @param orderNumber: String
    * @param accessToken: String
    * @return String.
    */
    public String getOrderDetails(String orderNumber, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v17_8/orders/' + orderNumber);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if(logger!=null){
	        logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getOrderDetails: res '+ res.getBody());
        }
        return res.getBody();

    }

    /**
    * This method used for pulling selected customer details from commerce cloud using customer no.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public String getCustomerDetails(String customerNumber, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + customerListId + '/customers/' + customerNumber);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if (logger != null) {
        	logger.trace('SCCCommerceCloudConnect', 'connectToCommerceCloud-getCustomerDetails: res '+ res.getBody());
        }
        return res.getBody();

    }

    /**
     * Unued method hence commented
    * This method used for pulling selected customer details from commerce cloud using customer ID.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public String getCustomerDetailsById(String customerId, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/customers/' + customerId +'?expand=addresses,paymentinstruments');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
		if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.getCustomerDetailsById', 'connectToCommerceCloud-getCustomerDetails: res '+ res.getBody());
        }
        return res.getBody();

    }

    public String getAddressDetails(String customerNumber, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + customerListId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

	public String postAddressDetails(String body, String customerNumber, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + customerListId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

    /**
    * This method used for pulling selected customer profile details from commerce cloud.
    * @param email: String
    * @param accessToken: String
    * @return String.
    */
    public String searchCustomerByEmail(String email, String accessToken) {

        if(String.isEmpty(email)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + customerListId + '/customer_search');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        String body = '{"query":{"text_query":{"fields":["email", "phone_home", "phone_business", "phone_mobile"],"search_phrase":"' + email + '"}}}';
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.searchCustomerByEmail', 'connectToCommerceCloud-searchCustomerByEmail: res '+ res.getBody());
        }
        return res.getBody();

    }

    /**
    * This method used for pushing selected customer profile to update to commerce cloud.
    * @param body: String
    * @param customerNo: String
    * @param accessToken: String
    * @return String.
    */
    public HttpResponse updateCCCustomerProfile(String body, String customerNo, String accessToken) {

        if(String.isEmpty(body) || String.isEmpty(customerNo)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + customerListId + '/customers/' + customerNo);
        req.setMethod('POST');
	    req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(logger!=null){
        	logger.trace('SCCCommerceCloudConnect.updateCCCustomerProfile', 'Req: '+req.getBody() +' Res: '+ res.getBody());
        }
        return res;

    }

	/**
    * This method used for pushing selected order to update to commerce cloud.
    * @param body: String
    * @param orderNo: String
    * @param accessToken: String
    * @return String.
    */
    public String pushOrderDetails(String body, String orderNo, String accessToken) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/orders/' + orderNo);
        req.setMethod('POST');
        req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

    /**
     *  Method to check if a Queueable or a Future needs to be called.
     *  @param objectId: Id
     *  @return None.
    */
    public static void initiateAsynchOperation(Id objectId, List<Id> objectIds, String objectName) {
        if((objectId != null || (objectIds != null && !objectIds.isEmpty())) && !String.isBlank(objectName)){
            callQueueable(objectId, objectIds, objectName);
        }
    }

    /**
     *
     * Queueable method used for pulling the object details from commerce cloud and update object.
     * @param objectId: Id
     * @return None.
    */
    public static void callQueueable(Id objectId, List<Id> objectIds, String objectName) {

        Queueable queueableJob;
        if(!String.isBlank(objectName) && objectName.equalsIgnoreCase('Account')){
            queueableJob = new SCCAccountQueueable(objectId, objectIds);
        }else if(!String.isBlank(objectName) && objectName.equalsIgnoreCase('Order')){
            queueableJob = new SCCOrderQueueable(objectId, objectIds);
        }
        if(queueableJob != null){
            Id jobID = System.enqueueJob(queueableJob);
            SCCFileLogger logger = SCCFileLogger.getInstance();
            logger.debug('SCCCommerceCloudConnect.callQueueable', ', calling the SCC' + objectName + 'Queueable Asynch operation, jobID ' + jobID);
        }
    }
}