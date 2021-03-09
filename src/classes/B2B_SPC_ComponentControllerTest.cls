@IsTest
public with sharing class B2B_SPC_ComponentControllerTest {

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

        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        cartId = cart.Id;

        System.debug('cartId: ' + cartId);

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId=cart.Id
            , Name='Default Delivery'
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
        Test getting the addresses
    */
    @isTest static void testCode1() {

        setup();
        
        Test.startTest();

        // Get shipping addresses
        Map<String, Object> responseMap = B2B_SPC_ComponentController.getAddressInfo(effectiveAccountId, true, false);

        // Get billing addresses
        Map<String, Object> responseMap2 = B2B_SPC_ComponentController.getAddressInfo(effectiveAccountId, false, true);
        
        Test.stopTest();
    }

    /*
        Test getting the cart summary, where a delivery method has not been selected.
    */
    @isTest static void testCode2a() {

        setup();
        
        Test.startTest();

        // Test: execute the integration for the test cart ID.
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];

        List<CartItem> cartItemList = [Select Id from CartItem where CartId = :webCart.Id];

        System.debug('cartItemList size = ' + cartItemList.size());

        List<CartDeliveryGroup> cdgList = [Select Id from CartDeliveryGroup where CartId = :webCart.Id];

        System.debug('cartItemList size = ' + cartItemList.size());

        // Get cart summary
        Map<String, Object> responseMap = B2B_SPC_ComponentController.getCartSummary(effectiveAccountId, webstoreId, cartId, true);

        
        
        Test.stopTest();
    }

    /*
        Test getting the cart summary, where a delivery method has been selected.
    */
    @isTest static void testCode2b() {

        setup();

        // Additional setup to associate a cart delivery group method with the cart delivery group.
        setup2();
        
        Test.startTest();

        

        // Get cart summary
        Map<String, Object> responseMap = B2B_SPC_ComponentController.getCartSummary(effectiveAccountId, webstoreId, cartId, true);

        
        
        Test.stopTest();
    }

    /*
        Test getting the delivery methods
    */
    @isTest static void testCode3() {

        setup();
        
        Test.startTest();

        // Get delivery methods
        Map<String, Object> responseMap = B2B_SPC_ComponentController.fetchDeliveryMethods(cartId);

        
        
        Test.stopTest();
    }

    /*
        Set the cart delivery method.
    */
    @isTest static void testCode4() {

        setup();

        // Additional setup to associate a cart delivery group method with the cart delivery group.
        setup2();
        
        Test.startTest();

        

        // Set the cart delivery group to the selected delivery method.
        Map<String, Object> responseMap = B2B_SPC_ComponentController.setCartItemDeliveryGroup(cartDeliveryGroupMethodId, deliveryMethodId, cartId);

        
        
        Test.stopTest();
    }

    /*
        Update the cart delivery group record with the selected ship to address (contact point address record).
    */
    @isTest static void testCode5() {

        setup();

        // Additional setup to associate a cart delivery group method with the cart delivery group.
        setup2();
        
        Test.startTest();

        

        // Set the cart delivery group to the selected delivery method.
        Map<String, Object> responseMap = B2B_SPC_ComponentController.setCartDeliveryGroupShipToAddress(shipToContactPointAddressId, cartId);

        
        
        Test.stopTest();
    }

    /*
        Fetch the init values with an existing cart
    */
    @isTest static void testCode6a() {

        setup();

        String communityId = null;
        
        Test.startTest();

        

        // Get the init info with an existing cart
        Map<String, Object> responseMap = B2B_SPC_ComponentController.fetchInitValues(communityId, effectiveAccountId, cartId);

        
        
        Test.stopTest();
    }

    /*
        Fetch the init values with no cart
    */
    @isTest static void testCode6b() {

        setup();

        String communityId = null;
        
        Test.startTest();

        

        // Get the init info with an existing cart
        Map<String, Object> responseMap = B2B_SPC_ComponentController.fetchInitValues(communityId, effectiveAccountId, null);

        
        
        Test.stopTest();
    }

    /*
        Work the util methods
    */
    @isTest static void testCode7() {

        Map<String, Object> responseMap = new Map<String, Object>();

        B2B_SPC_ComponentUtil.addMessage(new B2B_SPC_ComponentUtil.Message('Error', 'Some error message', B2B_SPC_ComponentUtil.ERROR), null, responseMap);
        B2B_SPC_ComponentUtil.addMessage(new B2B_SPC_ComponentUtil.Message('Error', 'Some error message', B2B_SPC_ComponentUtil.ERROR), 0, responseMap);

        B2B_SPC_ComponentUtil.addMessage(new B2B_SPC_ComponentUtil.Message('Error', 'Some error message', B2B_SPC_ComponentUtil.ERROR, true), 0, responseMap);

    }

}