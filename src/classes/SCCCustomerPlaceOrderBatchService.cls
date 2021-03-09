/**
* Rest Service class for post order informations' details => Customer Place Order
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(UrlMapping='/Order/Placement/Batch/*')
global with sharing class SCCCustomerPlaceOrderBatchService {

    static final String OBJECT_NAME = 'Order';

    /**
    * This is the method using on "POST" requests.
    * @return SCCCustomerOrderResponse.
    */
    @HttpPost
    global static List<SCCCustomerOrderResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerOrderResponse> response;
        SObject sobj;
        try{
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());
			Map<String, Object> jsonMap = (Map<String, Object>)jsonDataList[0];
            if(!String.isEmpty((String)jsonMap.get('account_id'))){
 				sobj = SCCUtilityClass.getSojectByRefId((String)jsonMap.get('account_id'));
            }

            if(SCCUtilityClass.isPersonAccountEnabled()
               && (sobj instanceof Account || sobj == null)){
                logger.debug('SCCCustomerPlaceOrderService.create', 'Person account enabled. Creating account order: '+sobj);
                response = createAccountOrderRecord(RestContext.request, logger);
            }else{
                logger.debug('SCCCustomerPlaceOrderService.create', 'Supplied data in incorrect. OR this Org doesnt support person account');
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());
            }
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationService.create', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			response = new List<SCCCustomerOrderResponse>();
            response.add(SCCCustomerOrderResponse.createError(e));
            return response;
        }finally{
            logger.flush();
        }
        return response;
    }

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerOrderResponse.
    */
    static List<SCCCustomerOrderResponse> createAccountOrderRecord(RestRequest request, SCCFileLogger logger){

        List<SCCCustomerOrderResponse> respList = new List<SCCCustomerOrderResponse>();
        Account defaultAccount = SCCUtilityClass.getDefaultAccount();
        if(defaultAccount == null){
	        	respList.add(SCCCustomerOrderResponse.createDefaultAccountError());
	        	logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', Label.SCC_Missing_Default_Account);
	        	return respList;
	    }
        Map<String, SObject> orderfieldMappings = SCCUtilityClass.getAllCustomSettingValues(OBJECT_NAME, logger);
        List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
        for (Object jsonData : jsonDataList){
            Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
            List<Id> recordIdsForAsynchRequest = new List<Id>();
            try	{
                if(jsonMap.containsKey('order_no')) {
                    String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName(OBJECT_NAME)
                        .setRelatedFields(new Set<String>{'Id', 'AccountId', 'Name', 'OrderNumber', 'SFCC_Order_Number__c'})
                        .setClause('SFCC_Order_Number__c = \'' + (String)jsonMap.get('order_no') + '\'')
                        .getQuery();
                    List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);
                    Order record = (Order)SCCUtilityClass.initializeObject(jsonMap, OBJECT_NAME, orderfieldMappings, logger);
                    if(!orderList.isEmpty()) {
                        //Existing order processing.
                        record = orderList.get(0);
                        record.Order_SCCSync_Status__c = 'Updated';
                        Database.update(record, true);
                        recordIdsForAsynchRequest.add(record.Id);
                        respList.add(SCCCustomerOrderResponse.createResponse(record));
                    }else{
                        if(jsonMap.containsKey('account_id')) {
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
                                recordIdsForAsynchRequest.add(record.Id);
                            } else {
                                record = additionalFieldsforNewOrder(record);
                                record.Order_Contact__c = null;
                                record.AccountId = defaultAccount.Id;
                                Database.insert(record, true);
                                recordIdsForAsynchRequest.add(record.Id);
                            }
                        } else {
                            record = additionalFieldsforNewOrder(record);
                            record.AccountId = defaultAccount.Id;
                            Database.insert(record, true);
                            recordIdsForAsynchRequest.add(record.Id);
                        }
                        respList.add(SCCCustomerOrderResponse.createResponse(record));

                        //Initiate a asynch request to SFCC to get Payment, Shipping, Line Items and other additional details.
                        if(recordIdsForAsynchRequest != null && !recordIdsForAsynchRequest.isEmpty()){
                            SCCCommerceCloudConnect.initiateAsynchOperation(null, recordIdsForAsynchRequest, OBJECT_NAME);
                        }
                    }
                }
            } catch(Exception e) {
                logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                             + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                respList.add(SCCCustomerOrderResponse.createError(e, (String)jsonMap.get('order_no')));
            }
        }
        return respList;
    }

    /**
    * This method used for populating additional and required fields for order object
    * @param record: Order
    * @return Order.
    */
    public static Order additionalFieldsforNewOrder(Order record) {
        record.EffectiveDate = System.today();
        record.from_SFCC__c = true;
        record.Order_SCCSync_Status__c = 'Created';
        record.Status = 'Draft';
        return record;
    }
}