public class B2B_SPC_DeliveryMethods {
    /**
     * @description This creates a couple of delivery methods for the user to select from.
     *              This hits a heroku server to get at the data, simulating a call to a third party system.
     * @param cartIds Expects a single cart id that we are preparing delivery methods for.
     */
    @InvocableMethod(label='B2B Prepare the Delivery Method Options' description='Update Web Cart with possible delivery method options' category='B2B Commerce')
    public static void prepDeliveryMethods(List<ID> cartIds) {

        System.debug('begin prepDeliveryMethods');
        Id cartId = cartIds[0];

        // 2020-11-30 msobczak: refactored the code to handle when there is no cart delivery group (cart contains no items).
        //Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;

        Id cartDeliveryGroupId = null;

        try {

            List<CartItem> cartItems = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId];

            if(cartItems.size() > 0 ) {
                CartItem cartItem = cartItems.get(0);
                cartDeliveryGroupId = cartItem.CartDeliveryGroupId;
            }

            if(cartDeliveryGroupId == null) {
                return;
            }

            System.debug('cartDelilveryGroupId: ' + cartDeliveryGroupId);

            // Get the shipping options from an external service.
            // We're getting information like rates and carriers from this external service. 
            ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService();

            // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
            System.debug('deleting cart delivery group...');
            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];

            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

            // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            Integer i = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
                populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                                cartDeliveryGroupId,
                                                                orderDeliveryMethodId,
                                                                cartId);
                i+=1;
            }

        }
        catch(Exception e) {
            integrationStatusFailedWithCartValidationOutputError(e.getMessage(), cartId);
        }
    }
  
    public static void prepDeliveryMethodsInternal(List<ID> cartIds) {

        System.debug('begin prepDeliveryMethodsInternal');
        
        Id cartId = cartIds[0];

        // 2020-11-30 msobczak: refactored the code to handle when there is no cart delivery group (cart contains no items).
        //Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;

        Id cartDeliveryGroupId = null;

        List<CartItem> cartItems = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId];

        System.debug('cartItems.size() = ' + cartItems.size());

        if(cartItems.size() > 0 ) {
            CartItem cartItem = cartItems.get(0);
            cartDeliveryGroupId = cartItem.CartDeliveryGroupId;
        }

        if(cartDeliveryGroupId == null) {
            return;
        }

        System.debug('cartDelilveryGroupId: ' + cartDeliveryGroupId);

        // Get the shipping options from an external service.
        // We're getting information like rates and carriers from this external service. 
        // ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService();

        // 2020-11-20 msobczak
        
        ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromInternal();

        // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
        System.debug('deleting cart delivery group...');
        delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];

        // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
        List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

        // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
        Integer i = 0;
        for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
            populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                               cartDeliveryGroupId,
                                                               orderDeliveryMethodId,
                                                               cartId);
            i+=1;
        }
  }
    // Don't hit Heroku Server: You can uncomment this out if you want to remove the Heroku Service from this class. Comment out the
    // method below instead.
    /*
    private static ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService () {
        // Don't actually call heroku
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();

        // To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
        // If the request is successful, parse the JSON response.
        // The response looks like this:
        // [{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},
        // {"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]
        String body = '[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},' +
					   '{"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]';
        List<Object> results = (List<Object>) JSON.deserializeUntyped(body);
        for (Object result: results) {
            Map<String, Object> subresult = (Map<String, Object>) result;
            Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
            shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                (String) providerAndRate.get('name'),
                (String) providerAndRate.get('serviceCode'),
                (Decimal) providerAndRate.get('shipmentCost'),
                (Decimal) providerAndRate.get('otherCost'),
                (String) providerAndRate.get('serviceName')
            ));
        }
        return shippingOptions;
    }*/
    
    // Do hit Heroku Server: You can comment this out and uncomment out the above class if you don't want to hit the Heroku Service.
    public static ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService () {

        System.debug('begin getShippingOptionsAndRatesFromExternalService');
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        // To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/calculate-shipping-rates-winter-21');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        // The response looks like this:
        // [{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},
        // {"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]
        if (response.getStatusCode() == SuccessfulHttpRequest) {
           List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
           for (Object result: results) {
                Map<String, Object> subresult = (Map<String, Object>) result;
                Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
                shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                    (String) providerAndRate.get('name'),
                    (String) providerAndRate.get('serviceCode'),
                    (Decimal) providerAndRate.get('shipmentCost'),
                    (Decimal) providerAndRate.get('otherCost'),
                    (String) providerAndRate.get('serviceName')
                ));
            }
            return shippingOptions;
        }
        else {
            String msg = 'There was a problem with the request. Error: ' + response.getStatusCode();
            throw new CalloutException (msg);
        }
    }

    private static ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromInternal () {
        // Don't actually call heroku
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();

        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('Free shipping', 'DHLFREE', 0.00, 0.00, 'DHL'));
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('Next day 9am', 'DHLND9', 39.99, 2.99, 'DHL'));
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('Next day', 'DHLND', 9.99, 2.99, 'DHL'));
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('Standard 3-6 days', 'UPDSTD',0.00, 0.00, 'UPS'));
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('Next day', 'UPDSND',8.99, 1.99, 'UPS'));
        shippingOptions.add( new ShippingOptionsAndRatesFromExternalService('4 hours', 'UPDS4H',16.99, 1.99, 'UPS'));
        
        return shippingOptions;
    }

    // Structure to store the shipping options retrieved from external service.
    public Class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;

        public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
        }

        public String getProvider() {
            return provider;
        }

        public Decimal getRate() {
            return rate;
        }

        public Decimal getOtherCost() {
            return otherCost;
        }

        public String getServiceName() {
            return serviceName;
        }

        public String getName() {
            return name;
        }
    }

    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private static void populateCartDeliveryGroupMethodWithShippingOptions(ShippingOptionsAndRatesFromExternalService shippingOption,
                                                                           Id cartDeliveryGroupId,
                                                                           Id deliveryMethodId,
                                                                           Id webCartId){
        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
        // CartDeliveryGroupId: Id of the delivery group of this shipping option
        // DeliveryMethodId: Id of the delivery method for this shipping option
        // ExternalProvider: Unique identifier of shipping provider
        // Name: Name of the CartDeliveryGroupMethod record
        // ShippingFee: The cost of shipping for the delivery group
        // WebCartId: Id if the cart that the delivery group belongs to
        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOption.getProvider(),
            Name = shippingOption.getName(),
            ShippingFee = shippingOption.getRate(),
            WebCartId = webCartId
        );
        insert(cartDeliveryGroupMethod);
    }

    // 2020-12-10  msobczak: removed references to the sfdc_checkout.IntegrationStatus object, since that is not used.
    private static void integrationStatusFailedWithCartValidationOutputError(
        String errorMessage, Id cartId) {
            
            // In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = null,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId,
                RelatedEntityId = cartId,
                Type = 'Shipping'
            );
            insert(cartValidationError);
    }

    private static List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> shippingOptions) {
        
        System.debug('begin getShippingOptionsAndRatesFromInternal()');
        
        System.debug('shippingOptions.size = ' + shippingOptions.size());
        
        String defaultDeliveryMethodName = 'Order Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (ShippingOptionsAndRatesFromExternalService shippingOption: shippingOptions) {
            String shippingOptionNumber = String.valueOf(i);
            String name = defaultDeliveryMethodName + shippingOptionNumber;
            
            System.debug('name: ' + name);
            
            String serviceName = shippingOption.getServiceName();
            String provider = shippingOption.getProvider();
            
            // The previous way of locating OrderDeliveryMethods did not make sense.
            // Changed the code to match on Carrier and ClassOfService.
            //List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :name];
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Carrier = :serviceName
                                             and ClassOfService = :provider];
            
            // This is the case in which an Order Delivery method does not exist.
            if (odms.isEmpty()) {
                
                System.debug('Creating a new OrderDeliveryMethod');
                
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = name,
                    Carrier = shippingOption.serviceName,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.provider
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                
                System.debug('Getting existing OrderDeliveryMethod');
                
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod existingodm = odms[0];
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.serviceName;
                    existingodm.ClassOfService = shippingOption.provider;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }

    private static Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }

}