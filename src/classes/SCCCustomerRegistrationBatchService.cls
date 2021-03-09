/**
* Rest Service class for post contact informations' details => Customer Registration
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-02
*/
@RestResource(UrlMapping='/Contact/Registration/Batch/*')
global with sharing class SCCCustomerRegistrationBatchService {

    static final String OBJECT_NAME = 'Account';

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    @HttpPost
    global static List<SCCCustomerRegResponse> create() {
        SCCFileLogger logger = SCCFileLogger.getInstance();
        List<SCCCustomerRegResponse> response;
        try{
            if(SCCUtilityClass.isPersonAccountEnabled()){
                response = createAccountRecord(RestContext.request, logger);
            }else {
                logger.debug('SCCCustomerRegistrationBatchService.create', 'Supplied data in incorrect. OR this Org doesnt support person account');
                throw new SObjectException('Invalid data, Is PersonAccount Enabled: '+ SCCUtilityClass.isPersonAccountEnabled());
            }
        }catch(Exception e){
            logger.error('SCCCustomerRegistrationBatchService.create', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			response = new List<SCCCustomerRegResponse>();
            response.add(SCCCustomerRegResponse.createError(e));
            return response;
        }finally{
            logger.flush();
        }
        return response;
    }

    /**
    * This is the method using on "POST" requests
    * @return SCCCustomerRegResponse.
    */
    static List<SCCCustomerRegResponse> createAccountRecord(RestRequest request, SCCFileLogger logger){

        List<SCCCustomerRegResponse> respList = new List<SCCCustomerRegResponse>();
        List<Id> recordIds = new List<Id>();

        try {
        	Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues(OBJECT_NAME, logger);
            List<Object> jsonDataList = (List<Object>)System.JSON.deserializeUntyped(request.requestBody.toString());
            for (Object jsonData : jsonDataList)
            {
                Map<String, Object> jsonMap = (Map<String, Object>)jsonData;
                try	{
                    String query = SCCQueryUtilClass.getInstance()
                      .getQueryInstance()
                      .setObjectName(OBJECT_NAME)
                      .setRelatedFields(new Set<String>{'Id', 'PersonEmail', 'SFCC_Customer_Id__pc', 'SFCC_Customer_Number__pc'})
                      .setClause('PersonEmail = \'' + (String)jsonMap.get('email') + '\'')
                      .getQuery();
                    List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                    Account record = (Account)SCCUtilityClass.initializeObject(jsonMap, OBJECT_NAME, fieldMappings, logger);
                    record.From_SFCC__pc = true;
                    record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
                    if(!accountList.isEmpty()) {
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Updating existing account: '+record);
                        record.Id = accountList[0].Id;
                        record.Contact_Status__pc  = 'Updated';
                        record.SFCC_update__c = true;
                    }else{
                        logger.debug('SCCCustomerRegistrationBatchService.createAccountRecord', 'Creating new account: '+ record);
                        RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
                        record.RecordTypeId = recordType.Id;
                        record.Contact_Status__pc  = 'Created';
                    }
                    Database.upsert(record, true);
                    recordIds.add(record.Id);
                    respList.add(SCCCustomerRegResponse.createResponse(record));
                } catch(Exception e) {
                    logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
                    respList.add(SCCCustomerRegResponse.createError((String)jsonMap.get('customer_no'), e));
                }
           	}
            SCCCommerceCloudConnect.initiateAsynchOperation(null, recordIds, OBJECT_NAME);
            return respList;
        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerRegistrationBatchService.createAccountRecord', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            respList.add(SCCCustomerRegResponse.createError(e));
            return respList;
        }
    }
}