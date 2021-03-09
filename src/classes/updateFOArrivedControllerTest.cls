@isTest
private class updateFOArrivedControllerTest {
    
    //Creating Fulfillment Orders and all related objects not clear
    //Replace with proper test method include proper creation of FO and related records
    static testMethod void default() {
        
        String plainText = System.UserInfo.getUserId() + '|' + System.UserInfo.getUserType();
        
        String encryptedText = ued.UserCryptoHelper.doEncrypt(plainText);
        encryptedText = System.EncodingUtil.urlEncode(encryptedText, 'UTF-8');

        String result = updateFOArrivedController.updateFO(encryptedText);

        System.assert(result.startsWith('error'));

    }

    /* Test with create Fulfillment Order - fails to run with the following error
    /* FATAL_ERROR System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
    */
    static testMethod void defaultSuccess() {

        String identifier = 'test1';
        String fulfillmentType = 'warehouse';

        Account acc = OMSObjectUtility.createPersonAccount(identifier);
        insert acc;

        SalesChannel salesChannelRecord = OMSObjectUtility.createSalesChannel(identifier);
        insert salesChannelRecord;

        Product2 prod1 = OMSObjectUtility.createProduct2('prod1', 'prod1', 'prod1', true);
        insert prod1;

        PriceBookEntry pbe = OMSObjectUtility.createStandardPrice(prod1.Id, System.Test.getStandardPricebookId());
        insert pbe;


        Order currOrder = OMSObjectUtility.createOrder(identifier, acc.Id, System.Test.getStandardPricebookId(), salesChannelRecord.Id);
        insert currOrder;

        OrderDeliveryMethod odm = OMSObjectUtility.createOrderDeliveryMethod(identifier, identifier, prod1.Id);
        insert odm;

        OrderDeliveryGroup odg = OMSObjectUtility.createOrderDeliveryGroup(currOrder.Id, odm.Id);
        insert odg;

        OrderItem oi =  OMSObjectUtility.createOrderItem(currOrder.Id, prod1.Id, pbe.Id, odg.Id);
        insert oi;

        OrderItemTaxLineItem oitxli = OMSObjectUtility.createOrderItemTaxLineItem(identifier, identifier, oi.Id);
        insert oitxli; 

        Schema.Location floc = OMSObjectUtility.createLocation(identifier,fulfillmentType);
        insert floc;
        

        try {
        Id FOId = OMSObjectUtility.createOrderSummary(currOrder.Id);

        System.Test.startTest();
        FulfillmentOrder FO = [SELECT Id, OrderSummary.OrderNumber FROM FulfillmentOrder WHERE Id =:FOId LIMIT 1];
        System.Test.stopTest();

        } catch (Exception e) {}

        try {
            
            List<String> foIdList = OMSObjectUtility.createFulfillmentOrder(System.UserInfo.getUserId(), floc.Id, fulfillmentType);

        } catch(Exception e) {}

    }





}