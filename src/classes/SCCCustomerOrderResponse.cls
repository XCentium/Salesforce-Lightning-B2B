/**
* response class for rest services - post methods
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-14
*/
global with sharing class SCCCustomerOrderResponse {
        private String objectType                   {get; set;}
        private String recordId                     {get; set;}
        private String SFCCOrderNo               	{get; set;}
        private SCCErrorHandlingTemplate errors     {get; set;}

        /**
        * This is the constructor for SCCCustomerOrderResponse class.
        * @param recordId String
        * @return None.
        */
        public SCCCustomerOrderResponse() {  }

        /**
        * This is the constructor for SCCCustomerOrderResponse class.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerOrderResponse(String recordId, String objectType, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.errors         = errors;
        }


        /**
        * This is the constructor for SCCCustomerOrderResponse class used for Account/Contact objects.
        * @param recordId String
        * @param objectType String
        * @param errors SCCErrorHandlingTemplate
        * @return None.
        */
        public SCCCustomerOrderResponse(String recordId, String objectType, String orderNo, SCCErrorHandlingTemplate errors) {
            this.recordId       = recordId;
            this.objectType     = objectType;
            this.SFCCOrderNo 	= orderNo;
            this.errors         = errors;
        }

        /**
        * This method used for creating json text for response of rest services.
        * @param recordId: Id
        * @return SCCCustomerOrderResponse.
        */
        public static SCCCustomerOrderResponse createResponse(Id recordId) {
            return new SCCCustomerOrderResponse((String)recordId, recordId.getSobjectType().getDescribe().getLabel(), null);
        }


        /**
        * This method used for creating json text for response of rest services.
        * @param recordId: Id
        * @return SCCCustomerOrderResponse.
        */
        public static SCCCustomerOrderResponse createResponse(SObject record) {
            String objectType = record.getSObjectType().getDescribe().getLabel();
            if(objectType.equalsIgnoreCase('Order')){
                Order obj = (Order)record;
                return new SCCCustomerOrderResponse((String)obj.Id, obj.getSObjectType().getDescribe().getLabel(), obj.SFCC_Order_Number__c,  null);
            }else{
                return new SCCCustomerOrderResponse((String)record.Id, record.getSObjectType().getDescribe().getLabel(), null);
            }
        }

        /**
        * This method used for creating json text if there is error on processing.
        * @param e: Exception
        * @return SCCCustomerOrderResponse.
        */
        public static SCCCustomerOrderResponse createError(Exception e) {
            return new SCCCustomerOrderResponse(null, null, SCCErrorHandlingTemplate.createError(e));
        }

        /**
        * This method used for creating json text if there is error on processing.
        * @param e: Exception
        * @return SCCCustomerOrderResponse.
        */
        public static SCCCustomerOrderResponse createError(Exception e, String order_no) {
            return new SCCCustomerOrderResponse(null, null, order_no, SCCErrorHandlingTemplate.createError(e));
        }

        /**
        * This method used for creating json text if there is error of missing default account in SC.
        * @param e: Exception
        * @return SCCCustomerOrderResponse.
        */
        public static SCCCustomerOrderResponse createDefaultAccountError() {
            return new SCCCustomerOrderResponse(null, null, SCCErrorHandlingTemplate.createError(Label.SCC_Missing_Default_Account));
        }
    }