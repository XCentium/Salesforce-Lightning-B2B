/**
* Rest service class for customer resolution - if not found, create new.
*
* @author  Praveen Gaur
* @version 1.0
* @since   2019-08-22
*/
@RestResource(UrlMapping='/ResolveAccount/*')
global with sharing class SCCCustomerAccountResolutionService  {

    /**
    * This is the method using on "POST" requests.
    * @return SCCReturnResponse.
    */
    @HttpPost
    global static SCCCustomerRegResponse resolveOrCreate() {

        // Initialize the logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        logger.debug('SCCCustomerAccountResolutionService.resolveOrCreate', 'calling resolveOrCreate()');
        try {

            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            //Checking the mandatory fields
            if((jsonMap.get('last_name') == null || jsonMap.get('last_name') == '') || (jsonMap.get('email') == null || jsonMap.get('email') == '')){
                //Bad request - mandatory parameters missing
                RestContext.response.statusCode = 400;
                logger.error('SCCCustomerAccountResolutionService.resolveOrCreate', 'Error message : Mandatory paraneters missing - email & last_name');
                return SCCCustomerRegResponse.createError('Mandatory paraneters missing - email & last_name', '400', 'Bad Request');
            }else{

                Map<String, SObject> fieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);
                //Resolution parameters
                Set<String> relatedFields;
                String clause;
                if(jsonMap.get('customer_no') != null && jsonMap.get('customer_no') != ''){//Resolution criterion 1: search via customer_no
                    relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};
                    clause = 'SFCC_Customer_Number__pc = \'' + (String)jsonMap.get('customer_no') + '\'';
                }else if(jsonMap.get('customer_id') != null && jsonMap.get('customer_id') != ''){//Resolution criterion 2: search via customer_id
                    relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};
                    clause = 'SFCC_Customer_Id__pc = \'' + (String)jsonMap.get('customer_id') + '\'';
                }else{//Resolution criterion 3: if neither of customer_no or customer_id present in request, resolve via email
                    relatedFields = new Set<String>{'Id', 'PersonEmail','SFCC_Customer_Number__pc','SFCC_Customer_Id__pc'};
                    clause = 'PersonEmail = \'' + (String)jsonMap.get('email') + '\'';
                }
                String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Account')
                    .setRelatedFields(relatedFields)
                    .setClause(clause)
                    .getQuery();

                List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);
                Account record;
                if(!accountList.isEmpty()) {
                    logger.debug('SCCCustomerAccountResolutionService.resolveOrCreate', 'Found an existing account: '+accountList);
                    record = accountList[0];

                }else{
                    record = (Account)SCCUtilityClass.initializeObject(jsonMap, 'Account', fieldMappings, logger);
                    record.From_SFCC__pc = true;
                    record = SCCUtilityClass.additionalFieldsforAccount(record, jsonMap);
                    logger.debug('SCCCustomerAccountResolutionService.resolveOrCreate', 'Creating new account');
                    RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
                    record.RecordTypeId = recordType.Id;
                    record.Contact_Status__pc  = 'Created';
                    Database.upsert(record, true);
                    SCCCommerceCloudConnect.initiateAsynchOperation(record.Id, null, 'Account');
                }
                return SCCCustomerRegResponse.createResponse(record);
            }


        } catch(Exception e) {
            RestContext.response.statusCode = 500;
            logger.error('SCCCustomerAccountResolutionService.resolveOrCreate', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return SCCCustomerRegResponse.createError(e);
        }   finally{
            logger.flush();
        }

    }


}