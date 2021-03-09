/**
* response class for rest services - post methods
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-14
*/
global with sharing class SCCCustomerRegResponse {

    private String accountId                    {get; set;}
    private String contactId                    {get; set;}
    private String objectType                   {get; set;}
    private String SFCCCustomerId               {get; set;}
    private String SFCCCustomerNo               {get; set;}
    private SCCErrorHandlingTemplate errors     {get; set;}

    /**
    * This is the constructor for SCCReturnResponse class.
    */
    public SCCCustomerRegResponse() {}

    /**
    * This is the constructor for SCCReturnResponse class.
    * @param recordId: String
    * @param objectType: String
    * @param errors: SCCErrorHandlingTemplate
    * @return void
    */
    public SCCCustomerRegResponse(String recordId, String objectType, SCCErrorHandlingTemplate errors) {
        this.accountId       = recordId;
        this.objectType     = objectType;
        this.errors         = errors;
    }

    /**
    * This is the constructor for SCCReturnResponse class.
    * @param recordId: String
    * @param customerNo: String
    * @param objectType: String
    * @param errors: SCCErrorHandlingTemplate
    * @return void
    */
    public SCCCustomerRegResponse(String recordId, String contactId, String objectType, String customerId, String customerNo, SCCErrorHandlingTemplate errors) {
        this.accountId       = recordId;
        this.contactId      = contactId;
        this.objectType     = objectType;
        this.SFCCCustomerId = customerId;
        this.SFCCCustomerNo = customerNo;
        this.errors         = errors;
    }

    /**
    * This method used for creating json text for response of rest services.
    * @return SCCReturnResponse
    */
    public static SCCCustomerRegResponse createResponse(Id recordId) {
        return new SCCCustomerRegResponse((String)recordId, recordId.getSobjectType().getDescribe().getLabel(), null);
    }

    /**
    * @function createResponse
    * @description This method used for creating json text for response of rest services.
    * @param record: SObject Represents the object used to create the customerRegistration response
    * @return SCCReturnResponse Returns the response object
    */
    public static SCCCustomerRegResponse createResponse(SObject record) {

        // Retrieve the object-type from the record object specified
        String objectType = record.getSObjectType().getDescribe().getLabel();

        // Is this an Account / PersonAccount?
        if (objectType.equalsIgnoreCase('Account')) {

            // Spin-up a new query to retrieve the PersonContactId for this account
            String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Account')
                .setRelatedFields(new Set<String>{'Id', 'PersonContactId'})
                .setClause('Id = \'' + (String)record.Id + '\'')
                .setLimit('1')
                .getQuery();

            // Convert the query results to an array
            List<Account> accountList = (List<Account>)SCCQueryUtilClass.getRecords(query);

            // Retrieve the first element in the array
            Account thisAccount = accountList[0];

            // Create a reference to the implied PersonAccount object
            Account obj = (Account)record;

            // Build out and return the registration response for this PersonAccount
            return new SCCCustomerRegResponse(
                (String)obj.Id,
                (String)thisAccount.PersonContactId,
                obj.getSObjectType().getDescribe().getLabel(),
                obj.SFCC_Customer_Id__pc,
                obj.SFCC_Customer_Number__pc,
                null
            );

        // If not, is this a Contact Record?
        } else if (objectType.equalsIgnoreCase('Contact')){

            // Create a reference to the implied Contact object
            Contact obj = (Contact)record;

            // Return the registration response describing the contact
            return new SCCCustomerRegResponse(
                (String)obj.Id,
                (String)obj.Id,
                obj.getSObjectType().getDescribe().getLabel(),
                obj.SFCC_Customer_Id__c,
                obj.SFCC_Customer_Number__c,
                null
            );

        } else {

            // Otherwise, provide a generic registration response
            return new SCCCustomerRegResponse(
                (String)record.Id,
                record.getSObjectType().getDescribe().getLabel(),
                null
            );

        }

    }

    /**
    * This method used for creating json text if there is error on processing.
    * @param e: Exception
    * @return SCCReturnResponse.
    */
    public static SCCCustomerRegResponse createError(Exception e) {

        // Return the registration response containing the exception
        return new SCCCustomerRegResponse(
            null,
            null,
            SCCErrorHandlingTemplate.createError(e)
        );

    }

    /**
    * Overloaded createError method to accept String arguments.
    * @param e: Exception
    * @return SCCReturnResponse.
    */
    public static SCCCustomerRegResponse createError(String errorMessage, String statusCode, String typeOfError) {

        // Return the registration response containing the exception
        return new SCCCustomerRegResponse(
            null,
            null,
            SCCErrorHandlingTemplate.createError(errorMessage, statusCode, typeOfError)
        );

    }
    /**
    * This method used for creating json text if there is error on processing.
    * @param e: Exception
    * @return SCCReturnResponse.
    */
    public static SCCCustomerRegResponse createError(String customerNo, Exception e) {

        // Build out the error response
        return new SCCCustomerRegResponse(
            null,
            null,
            null,
            customerNo,
            null,
            SCCErrorHandlingTemplate.createError(e)
        );

    }

}