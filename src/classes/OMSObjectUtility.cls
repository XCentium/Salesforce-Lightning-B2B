public class OMSObjectUtility {
    
    public static Account createPersonAccount(String identifier)
    {
        Id rtId = [SELECT Id FROM RecordType WHERE IsPersonType = TRUE AND SObjectType='Account' LIMIT 1].Id;
        Account a = new Account(RecordTypeId = rtId, FirstName='Vasa' + identifier,LastName='Petrov', AccountNumber = '1234' + identifier, BillingStreet = '901 Winslowway E BainsBridge Island', 
        billingState= 'WA', BillingCountry = 'US', BillingPostalCode = '98110', BillingCity ='Seattle', PersonEmail='petrov@email.com');
        return a;
    }

    public static SalesChannel createSalesChannel(String name)
    {
        SalesChannel objSalesChannel = new SalesChannel();
        objSalesChannel.SalesChannelName = name;
        return objSalesChannel;
    }

    public static Product2 createProduct2(String name, String description, String productCode, Boolean isActive)
    {
        Product2 objProductItem = new Product2(Name = name,Description=description,productCode = productCode,IsActive= isActive);
        return objProductItem;
    }

    public static PriceBookEntry createStandardPrice(Id productItemId, Id pricebookId)
    {
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = productItemId;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        //standardPrice.UseStandardPrice = false;
        return standardPrice ;
    }

    public static Order createOrder(String identifier, Id accountId, Id pricebook2Id, Id salesChannelId)
    {
        Order tmpOrder = new Order(Name = 'Order'+ identifier, AccountId = accountId, EffectiveDate = system.today(), 
                                     status = 'Draft',Pricebook2Id =pricebook2Id, SalesChannelId= salesChannelId,
                                    OrderReferenceNumber ='CCS-Standard3', BillingStreet = '901 Winslowway E BainsBridge Island', 
            BillingState= 'WA', BillingCountry = 'US', BillingPostalCode = '98110', BillingCity ='Seattle', OrderedDate=system.today(),
                                    BillingEmailAddress='john@doe.com');
        return tmpOrder;
    }

    public static OrderDeliveryMethod createOrderDeliveryMethod(String name, String description, Id productId)
    {
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod(IsActive =true,Description= description,Name= name,ProductId = productId);
        return objOrderDeliveryMethod;
    }

    public static OrderDeliveryGroup createOrderDeliveryGroup(Id orderId, Id orderDeliveryMethodId)
    {
        OrderDeliveryGroup objOrderDeliveryGroup= new OrderDeliveryGroup(DeliverToCity= 'Seattle', DeliverToStreet= '900 Winslow Way E', DeliverToPostalCode = '98110',
         DeliverToState = 'WA',EmailAddress= 'email@email.com',OrderId= orderId, DeliverToName = 'Test', OrderDeliveryMethodId= orderDeliveryMethodId);
        
        return objOrderDeliveryGroup;
    }

    public static OrderItem createOrderItem(Id orderId, Id product2Id, Id pricebookEntryId, Id orderDeliveryGroupId)
    {
        OrderItem i = new OrderItem();
        i.OrderId = orderId;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = product2Id;
        i.PricebookEntryId=pricebookEntryId;
        i.OrderDeliveryGroupId = orderDeliveryGroupId;
		i.Description = 'Some Product';
		i.Type = 'Order Product';
        i.TotalLineAmount = 5760.00;  
        return i;
    }

    public static OrderItemTaxLineItem createOrderItemTaxLineItem(String name, String description, Id orderItemId) 
    {
        OrderItemTaxLineItem objOrderItemTaxLineItem = new OrderItemTaxLineItem(Name= name,Amount=100,Description=description,OrderItemId=orderItemId,Rate= 1.0,type = 'Estimated',TaxEffectiveDate= system.today());
        return objOrderItemTaxLineItem;
    }

    public static Id createOrderSummary(Id orderId)
    {
        ConnectApi.OrderSummaryInputRepresentation inputRep  = new ConnectApi.OrderSummaryInputRepresentation();
        inputRep.orderId = orderId;
        
        ConnectApi.OrderSummaryOutputRepresentation outputRep = new ConnectApi.OrderSummaryOutputRepresentation();
        outputRep = connectapi.OrderSummaryCreation.createOrderSummary(inputRep);
        return outputRep.orderSummaryId;
    }

    public static Schema.Location createLocation(String name, String type)
    {
        Schema.Location floc = new Schema.Location();
        floc.Name = name;
        floc.LocationType = type;

        return floc;
    }

    public static List<String> createFulfillmentOrder(Id orderSummaryId, Id fulfilledFromLocationId, String fulfillmentType)
    {
       
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new
        ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId = orderSummaryId;
        
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id FROM
                                                                        OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSummaryId];

        for (OrderDeliveryGroupSummary orderDeliveryGroupSummary: orderDeliveryGroupSummaryList){
            fulfillmentOrderInput.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
            List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new
            List<ConnectApi.FulfillmentGroupInputRepresentation>();

            ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new
            ConnectApi.FulfillmentGroupInputRepresentation();
            fulfillmentGroup.fulfilledFromLocationId = fulfilledFromLocationId;
            fulfillmentGroup.fulfillmentType = fulfillmentType;
            List<ConnectApi.OrderItemSummaryInputRepresentation> orderItemSummaries = new
            List<ConnectApi.OrderItemSummaryInputRepresentation>();
            
            List<OrderItemSummary> orderItemSummaryList = [Select Id, quantity FROM OrderItemSummary
            WHERE OrderSummaryId =: orderSummaryId AND OrderDeliveryGroupSummaryId =:
            orderDeliveryGroupSummary.Id];
            
            for(OrderItemSummary orderItemSummary : orderItemSummaryList){
                ConnectApi.OrderItemSummaryInputRepresentation oisInputRepresentation = new
                ConnectApi.OrderItemSummaryInputRepresentation();
                oisInputRepresentation.orderItemSummaryId = orderItemSummary.Id;
                oisInputRepresentation.quantity = orderItemSummary.quantity;
                orderItemSummaries.add(oisInputRepresentation);
            }

            fulfillmentGroup.orderItemSummaries = orderItemSummaries;
            fulfillmentGroups.add(fulfillmentGroup);
            fulfillmentOrderInput.fulfillmentGroups = fulfillmentGroups;
        }

        ConnectApi.FulfillmentOrderOutputRepresentation result =
        ConnectAPI.FulfillmentOrder.createFulfillmentOrders(fulfillmentOrderInput);

        return result.fulfillmentOrderIds;

    }

}