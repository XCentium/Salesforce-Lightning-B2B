@IsTest
public with sharing class B2B_SPC_CartToOrderDraftTest {
    
    public static String effectiveAccountId = null;
    public static String shipToContactPointAddressId = null;
    public static String cartId = null;
    public static String webstoreId = null;
    public static String deliveryMethodId = null;
    public static String cartDeliveryGroupId = null;
    public static String cartDeliveryGroupMethodId = null;
    
    private static void setup() {

        System.debug('begin setup()');

        Account account = new Account(Name='TestAccount');
        insert account;
        effectiveAccountId = account.Id;

        WebStore webStore = new WebStore(Name='TestWebStore', SupportedLanguages='en_US', DefaultLanguage='en_US');
        insert webStore;
        webstoreId = webStore.Id;

        WebCart cart = new WebCart(
            Name='Cart'
            , WebStoreId=webStore.Id
            , AccountId=account.Id
            , PONumber = '24601'
            , Status = 'Active'
            , Type = 'Cart'
            , BillingStreet = '2100 Woodward Ave'
            
            , BillingCity = 'Detroit'
            , BillingState = 'MI'
            , BillingPostalCode = '48201'
            , BillingCountry = 'USA'
            );
        insert cart;
        cartId = cart.Id;

        System.debug('cartId: ' + cartId);

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId=cart.Id
            , Name='Default Delivery'
            , DeliverToName ='Detroit IGHQ'
            , DeliverToState='MI'
            , DeliverToCountry='USA');
        insert cartDeliveryGroup;

        cartDeliveryGroupId = cartDeliveryGroup.Id;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
            , ListPrice = 50
            , SalesPrice = 50
            , TotalLineAmount = 150
            ,TotalPrice = 150
        );
        insert cartItem;

        List<ContactPointAddress> cpaList = new List<ContactPointAddress>();
        ContactPointAddress billingAddr = new ContactPointAddress(
            AddressType = 'Billing'
            , Street = '2100 Woodward Ave'
            , ParentId = effectiveAccountId
            , Name ='Detroit IGHQ'
            , City = 'Detroit'
            , State = 'MI'
            , PostalCode = '48201'
            , Country = 'USA'
            , IsDefault = true
            , IsPrimary = true
        );
        cpaList.add(billingAddr);

        ContactPointAddress shippingAddr = new ContactPointAddress(
            AddressType = 'Shipping'
            , Street = '2100 Woodward Ave'
            , ParentId = effectiveAccountId
            , Name ='Detroit IGHQ'
            , City = 'Detroit'
            , State = 'MI'
            , PostalCode = '48201'
            , Country = 'USA'
            , IsDefault = true
            , IsPrimary = true
        );
        cpaList.add(shippingAddr);

        insert(cpaList);

        shipToContactPointAddressId = cpaList.get(1).Id;

    }

    private static void setup2() {

        System.debug('begin setup2()');

        Product2 product = new Product2(
            Name = 'Shipping Charge for this delivery method'
            , IsActive = true
        );

        insert product;

        OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = 'Order Delivery Method1',
                    Carrier = 'DHL',
                    isActive = true,
                    ProductId = product.Id,
                    ClassOfService = 'DHLND9'
                );
        insert(defaultOrderDeliveryMethod);

        deliveryMethodId = defaultOrderDeliveryMethod.Id;

        String shippingOptionProvider = 'DHLND9';
        String shippingOptionName = 'Next day 9am';
        Decimal shippingOptionRate = 39.99;


        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOptionProvider,
            Name = shippingOptionName,
            ShippingFee = shippingOptionRate,
            WebCartId = cartId
        );
        insert(cartDeliveryGroupMethod);

        cartDeliveryGroupMethodId = cartDeliveryGroupMethod.Id;

        CartDeliveryGroup cartDeliveryGroup = [SELECT Id, DeliveryMethodId FROM CartDeliveryGroup WHERE Id= :cartDeliveryGroupId][0];
        cartDeliveryGroup.DeliveryMethodId = deliveryMethodId;
        update cartDeliveryGroup;

    }

    /*
        Test getting the cart summary, where a delivery method has been selected.
    */
    @isTest static void testCode1() {

        setup();

        // Additional setup to associate a cart delivery group method with the cart delivery group.
        setup2();
        
        B2B_SPC_CartToOrderDraft.Request request = new B2B_SPC_CartToOrderDraft.Request();
        request.cartId = cartId;

        List<B2B_SPC_CartToOrderDraft.Request> requestList = new List<B2B_SPC_CartToOrderDraft.Request>();
        requestList.add(request);

        Test.startTest();

        List<ID> orderIds = B2B_SPC_CartToOrderDraft.cartToOrder(requestList);      
        
        Test.stopTest();
    }

}