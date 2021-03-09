/**
 * Created by msobczak on 11/8/2018.
 */

public with sharing class ckz_OrderEntryController {

    @AuraEnabled
    public static List<Map<String, Object>> fetchOrderItems(String userId, String storefront, String currencyCode, String accountId, String locale, String orderId) {

        System.debug('userId: ' + userId);
        System.debug('storefront: ' + storefront);
        System.debug('currencyCode: ' + currencyCode);
        System.debug('accountId: ' + accountId);
        System.debug('locale: ' + locale);
        System.debug('orderId: ' + orderId);

        // See if the storefront uses effective accounts
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Map<String, Object> outputFetchData = new Map<String, Object>();

        Set<String> searchIdSet = new Set<String>();
        searchIdSet.add(orderId);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccAPIOrder.PARAM_ORDER_ID_LIST => searchIdSet
                ,ccrz.ccAPIOrder.PARAM_OWNERID => userId
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION

                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                        }
                }
        };

        outputFetchData = ccrz.ccAPIOrder.fetch(fetchInputData);

        //System.debug('outputFetchData = ');
        //System.debug(outputFetchData);

        //for(String key : outputFetchData.keySet()) {
        //    System.debug('key = ' + key);
        //}

        List<Map<String, Object>> orderList = new List<Map<String, Object>>();

        if(outputFetchData.containsKey('orderList')) {
            orderList = (List<Map<String, Object>>)outputFetchData.get('orderList');
        }

        System.debug('orderList size = ' + orderList.size());
        System.debug('orderList = ');
        System.debug(orderList);

        Map<String, Object> orderMap = new Map<String, Object>();
        if(orderList.size() > 0) {
            orderMap = orderList.get(0);
        }

        List<Map<String, Object>> productList = new List<Map<String, Object>>();
        if(outputFetchData.containsKey('productList')) {
            productList = (List<Map<String, Object>>)outputFetchData.get('productList');
        }

        System.debug('productList size = ' + productList.size());
        System.debug('productList = ');
        System.debug(productList);

        List<Map<String, Object>> orderItemsList = new List<Map<String, Object>>();
        if(orderMap.containsKey('EOrderItemsS')) {
            orderItemsList = (List<Map<String, Object>>)orderMap.get('EOrderItemsS');
        }

        System.debug('orderItemsList = ');
        System.debug(orderItemsList);

        //Map<String, Object> orderItemMap = orderItemsMap.get(0);
        //
        //for(String key : orderItemMap.keySet()) {
        //    System.debug('key = ' + key);
        //}

        List<Map<String, Object>> orderableItems = new List<Map<String, Object>>();

        for(Map<String, Object> orderItemMap : orderItemsList) {
            String productType = (String)orderItemMap.get('productType');

            // Only include simple products
            if(productType == 'Product') {
                Map<String, Object> orderableItem = new Map<String, Object>();
                orderableItem.put('productName', orderItemMap.get('productName'));
                orderableItem.put('product_sfid', orderItemMap.get('product'));
                orderableItem.put('price', 0.00);
                orderableItem.put('qty', orderItemMap.get('quantity'));
                orderableItem.put('sku', '');  // Get from productList

                orderableItems.add(orderableItem);
            }
        }

        // Get the SKU for each order item from the productList
        for(Map<String, Object> orderableItem : orderableItems) {
            String sfid = (String)orderableItem.get('product_sfid');
            for (Map<String, Object> productMap : productList) {
                if(sfid == (String)productMap.get('sfid')) {
                    orderableItem.put('sku', productMap.get('SKU'));
                }
            }
        }

        if(orderableItems.size() > 0) {
            // Get the current price for the items
            fetchProductPricing(orderableItems, storefront, locale);
        }

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        return orderableItems;

    }

    /*
        Returns the specified cart's line items.
        The Storefront and locale params are used to get pricing.
     */
    @AuraEnabled
    public static Map<String, Object> fetchCartInfo(String userId, String storefront, String currencyCode, String accountId, String locale, String cartId, Boolean getPrices) {

        System.debug('---- begin fetchCartItems');

        Map<String, Object> responseMap = new Map<String, Object>();

        // 2019-01-02  msobczak: added context to see if it resolves issue with product pricing
        // See if the storefront uses effective accounts
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);


        Map<String, Object> outputFetchData = new Map<String, Object>();

        Set<String> searchIdSet = new Set<String>();
        searchIdSet.add(cartId);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_IDLIST => searchIdSet
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                        }
                }

                // 2019-10-10  msobczak: added
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_M
                        }
                }
        };

        outputFetchData = ccrz.ccApiCart.fetch(fetchInputData);

        List<Map<String, Object>> productList = new List<Map<String, Object>>();
        if(outputFetchData.containsKey('productList')) {
            productList = (List<Map<String, Object>>)outputFetchData.get('productList');
        }

        System.debug('productList size = ' + productList.size());
        System.debug('productList = ');
        System.debug(JSON.serialize(productList));

        // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
        Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

        for(Map<String, Object> productMap : productList) {
            String productSfid = (String)productMap.get('sfid');
            productsMap.put(productSfid, productMap);
        }

        List<Map<String, Object>> cartList = new List<Map<String, Object>>();

        if(outputFetchData.containsKey(ccrz.ccApiCart.CART_OBJLIST)) {
            cartList = (List<Map<String, Object>>)outputFetchData.get(ccrz.ccApiCart.CART_OBJLIST);

            // 2019-07-23 msobczak: added
            reviseCartStatusIfAbandoned(cartList);
        }

        List<Map<String, Object>> orderableItems = createOrderableItemsList(cartList, productsMap, getPrices, storefront, locale);

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        responseMap.put('orderableItems', orderableItems);

        System.debug('---- exit fetchCartItems');

        return responseMap;

    }

    /*
        Returns the specified cart's line items.
        The Storefront and locale params are used to get pricing.
     */
    @AuraEnabled
    public static List<Map<String, Object>> fetchCartItems(String userId, String storefront, String currencyCode, String accountId, String locale, String cartId, Boolean getPrices) {

        System.debug('---- begin fetchCartItems');

        // 2019-01-02  msobczak: added context to see if it resolves issue with product pricing
        // See if the storefront uses effective accounts
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);


        Map<String, Object> outputFetchData = new Map<String, Object>();

        Set<String> searchIdSet = new Set<String>();
        searchIdSet.add(cartId);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_IDLIST => searchIdSet
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                        }
                }

                // 2019-10-10  msobczak: added
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_M
                        }
                }
        };

        outputFetchData = ccrz.ccApiCart.fetch(fetchInputData);

        List<Map<String, Object>> productList = new List<Map<String, Object>>();
        if(outputFetchData.containsKey('productList')) {
            productList = (List<Map<String, Object>>)outputFetchData.get('productList');
        }

        System.debug('productList size = ' + productList.size());
        System.debug('productList = ');
        System.debug(JSON.serialize(productList));

        // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
        Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

        for(Map<String, Object> productMap : productList) {
            String productSfid = (String)productMap.get('sfid');
            productsMap.put(productSfid, productMap);
        }

        List<Map<String, Object>> cartList = new List<Map<String, Object>>();

        if(outputFetchData.containsKey(ccrz.ccApiCart.CART_OBJLIST)) {
            cartList = (List<Map<String, Object>>)outputFetchData.get(ccrz.ccApiCart.CART_OBJLIST);

            // 2019-07-23 msobczak: added
            reviseCartStatusIfAbandoned(cartList);
        }

        List<Map<String, Object>> orderableItems = createOrderableItemsList(cartList, productsMap, getPrices, storefront, locale);

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        System.debug('---- exit fetchCartItems');

        return orderableItems;

    }

    private static void reviseCartStatusIfAbandoned(List<Map<String, Object>> cartList) {

        System.debug('---- begin reviseCartStatusIfAbandoned');

        Map<String, Object> cartMap = cartList.get(0);

        String cartStatus = (String)cartMap.get('cartStatus');

        System.debug('cartStatus: ' + cartStatus);

        String cartId = (String)cartMap.get('sfid');

        System.debug('cartId: ' + cartId);

        if(cartStatus == 'Abandoned') {

            Map<String, Object> cartInputData = new Map<String, Object>{
                    'sfid' => cartId
                    ,'cartStatus' => 'Open'
                    ,'activeCart' => false
                    ,'name' => 'converted abandoned cart'
            };

            List<Object> cartReviseList = new List<Object>();
            cartReviseList.add(cartInputData);

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    , ccrz.ccApiCart.CART_OBJLIST => cartReviseList
            };

            Map<String, Object> outputData = ccrz.ccApiCart.revise(inputData);

            System.debug('outputData: ' + outputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful = ' + wasSuccessful);
        }

        System.debug('---- exit reviseCartStatusIfAbandoned');

    }

    /*
        Gets the current price for all products retrieved from the selected order.
        The price on the order items is the price when the order was placed.
     */
    private static void fetchProductPricing(List<Map<String, Object>> orderableItems, String storefront, String locale) {

        System.debug('---- begin fetchProductPricing');

        Set<String> searchIdSet = new Set<String>();

        for(Map<String, Object> orderableItem : orderableItems) {
            searchIdSet.add((String)orderableItem.get('product_sfid'));
        }

        System.debug('searchIdSet: ' + searchIdSet);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccAPIProduct.PRODUCTIDLIST => searchIdSet
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true
                ,ccrz.ccAPIProduct.PRODUCTSTOREFRONT => storefront
                ,ccrz.ccAPIProduct.PRODUCTLOCALE => locale
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                        }
                }
        };

        try {
            Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(fetchInputData);

            System.debug('outputFetchData:');
            //System.debug(outputFetchData);

            for(String key : outputFetchData.keySet()) {
                System.debug('key = ' + key + ' > ' + outputFetchData.get(key));
            }

            if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {

                List<Map<String, Object>> outputProductList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                for(Map<String, Object> outputProductMap : outputProductList) {

                    Map<String, Object> productMap = new Map<String, Object>();
                    String productName = (String) outputProductMap.get('sfdcName');

                    System.debug('productName: ' + productName);

                    String productType = (String) outputProductMap.get('productType');

                    String fetchProductSfid = (String) outputProductMap.get('sfid');
                    Decimal price = (Decimal) outputProductMap.get('price');
                    System.debug('price: ' + price);

                    for(Map<String, Object> orderableItem : orderableItems) {
                        String sfid = (String)orderableItem.get('product_sfid');
                        if(fetchProductSfid == sfid) {
                            orderableItem.put('price', outputProductMap.get('price'));
                        }
                    }

                }
            }
            else {
                System.debug('product list was null');
            }
        } catch (Exception e) {
            // Error handling...
            System.debug('error message: ' + e.getMessage());
            System.debug('line number: ' + e.getLineNumber());
        }

        System.debug('---- exit fetchProductPricing');

    }

    /*
        Creates a new cart object and adds items to it.
     */
    @AuraEnabled
    public static Map<String, Object> fetchNewCart(String userId, String contactId, String locale, String storefront, String currencyCode, String accountId, String itemsJson) {

        System.debug('---- begin fetchNewCart');

        Boolean cartCreated = false;
        Boolean cartItemsAdded = false;

        System.debug('userId = ' + userId);
        System.debug('contactId = ' + contactId);
        System.debug('locale = ' + locale);
        System.debug('storefront = ' + storefront);
        System.debug('currencyCode = ' + currencyCode);
        System.debug('accountId = ' + accountId);
        System.debug('itemsJson = ' + itemsJson);


        // 2019-01-14  msobczak: added context to see if it resolves issue with fetching the contact
        // See if the storefront uses effective accounts
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);


        List<Map<String, Object>> orderableItems = null;

        Map<String, Object> responseMap = new Map<String, Object>();

        Savepoint sp = Database.setSavepoint();

        try {
            getContact(contactId, responseMap);

            Boolean contactRetrieved = (Boolean)responseMap.get('contactRetrieved');

            if(contactRetrieved == false) {
                String msg = (String)responseMap.get('contactRetrievedMsg');

                throw new CustomException(msg);
            }

            createCart(userId, storefront, currencyCode, accountId, responseMap);

            cartCreated = (Boolean)responseMap.get('cartCreated');

            System.debug('cartCreated = ' + cartCreated);

            if(cartCreated == false) {
                String msg = (String)responseMap.get('cartCreatedMsg');

                throw new CustomException(msg);
            }

            String cartId = (String)responseMap.get('cartId');

            System.debug('cartId = ' + cartId);

            putLineItems(cartId, itemsJson, responseMap);

            cartItemsAdded = (Boolean)responseMap.get('cartItemsAdded');

            if(cartItemsAdded == false) {
                String msg = (String)responseMap.get('cartAddItemMsg');
                throw new CustomException(msg);
            }

            System.debug('cartItemsAdded = ' + cartItemsAdded);

            //orderableItems = fetchCartItems(storefront, locale, cartId, true);
            // 2018-11-29 msobczak: added an alternative method to use the results of the addTo to build the data returned.

            List<Map<String, Object>> productList = (List<Map<String, Object>>)responseMap.get('productList');

            // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
            Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productMap : productList) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
            }

            List<Map<String, Object>> cartList = (List<Map<String, Object>>)responseMap.get('cartList');

            orderableItems = createOrderableItemsList(cartList, productsMap);

            responseMap.put('cartItems', orderableItems);

        }
        catch (CustomException e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.remove('cartEncryptedId');
            responseMap.remove('cartId');
        }

        System.debug('---- end fetchNewCart');

        return responseMap;

    }

    /*
        Creates a cart object.  This does not add line items.
     */
    public static void createCart(String userId, String storefront, String currencyCode, String accountId, Map<String, Object> responseMap) {

        System.debug('---- begin createCart');

        responseMap.put('cartCreated', false);
        responseMap.put('cartEncryptedId', null);
        responseMap.put('cartId', null);

        Map<String, Object> contactMap = (Map<String, Object>)responseMap.get('contactMap');

        String firstName = (String)contactMap.get('firstName');
        String lastName = (String)contactMap.get('lastName');
        String phone = (String)contactMap.get('phone');
        String email = (String)contactMap.get('email');

        try {

            Map<String, Object> newCartInputData = new Map<String, Object>{
                    'storefront' => storefront
                    //,'ownerId' => userId
                    , 'activeCart' => false
                    , 'cartType' => 'Cart'
                    , 'currencyISOCode' => currencyCode
                    , 'note' => 'Headless commerce'
                    , 'cartStatus' => 'Open'
                    , 'name' => 'Headless Cart'
                    , 'buyerFirstName' => firstName
                    , 'buyerLastName' => lastName
                    , 'buyerPhone' => phone
                    , 'buyerEmail' => email

            };

            List<Object> newCartList = new List<Object>();
            newCartList.add(newCartInputData);

            /*
             2019-01-23  msobczak: changing the api version to current causes issues.
             The current user can't see the cart, even when the current user is a system admin.
             Keep at 7 unless you want trouble.
             */

            Map<String, Object> createCartInputData = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => 8
                    //,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccApiCart.CART_OBJLIST => newCartList

                    // 2020-04-07  msobczak: added to get the new cart name
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                                    ,ccrz.ccApi.SZ_REFETCH => true
                            }
                    }
            };

            System.debug('creating the cart');
            Map<String, Object> outputData = (Map<String, Object>) ccrz.ccApiCart.create(createCartInputData);
            System.debug('back from API call');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean cartCreated = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('cartCreated = ' + cartCreated);

            if (cartCreated) {
                responseMap.put('cartCreated', true);
                responseMap.put('cartCreatedMsg', 'Cart created successfully');

                String cartEncryptedId = (String) outputData.get(ccrz.ccApiCart.CART_ENCID);
                System.debug('cartEncryptedId = ' + cartEncryptedId);
                responseMap.put('cartEncryptedId', cartEncryptedId);

                String cartId = (String)outputData.get(ccrz.ccApiCart.CART_ID);
                responseMap.put('cartId', cartId);

                // 2020-04-07  msobczak: added to get the new cart name
                List<Map<String, Object>> cartList = (List<Map<String, Object>>)outputData.get(ccrz.ccApiCart.CART_OBJLIST);

                Map<String, Object> cartMap = cartList.get(0);

                String sfdcName = (String)cartMap.get('sfdcName');

                responseMap.put('cartName', sfdcName);

            } else {
                responseMap.put('cartCreatedMsg', 'Cart not created');
            }

        }
        catch (Exception e) {
            responseMap.put('cartCreatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

        System.debug('---- end createCart');

    }

    /*
        Handles adds, changes and deletes to an existing cart.
     */
    @AuraEnabled
    public static Map<String, Object> fetchUpdatedCart(String userId, String storefront, String currencyCode, String accountId, String locale, String cartId, String addItemsJson, String removeItemsJson, String updateItemsJson) {
        System.debug('---- begin fetchUpdatedCart');

        System.debug('userId: ' + userId);
        System.debug('storefront: ' + storefront);
        System.debug('currencyCode: ' + currencyCode);
        System.debug('accountId: ' + accountId);
        System.debug('locale: ' + locale);
        System.debug('cartId: ' + cartId);

        // See if the storefront uses effective accounts
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        List<Map<String, Object>> orderableItems = null;

        Savepoint sp = Database.setSavepoint();

        Map<String, Object> responseMap = new Map<String, Object>();

        try {

            // Delete items
            if (removeItemsJson != null && removeItemsJson != '') {
                Map<String, Object> removeResponseMap = deleteLineItems(cartId, removeItemsJson);

                responseMap.putAll(removeResponseMap);
            }

            // Add items
            // Response includes the current cart items
            if (addItemsJson != null && addItemsJson != '') {

                putLineItems(cartId, addItemsJson, responseMap);

            }

            // Update items
            // If an Add was performed, use the cart items returned by the ccApiCart.addTo() call.
            // If not, do a fetch of the cart.
            if (updateItemsJson != null && updateItemsJson != '') {

                orderableItems = fetchCartItems(userId, storefront, currencyCode, accountId, locale, cartId, false);

                // Pass in the current cart items.
                Map<String, Object> updateResponseMap = updateLineItems(cartId, orderableItems, updateItemsJson);

                responseMap.putAll(updateResponseMap);
            }

            // See if there were any errors
            Boolean cartItemsAdded = true;
            Boolean cartItemsRemoved = true;
            Boolean cartItemsUpdated = true;

            if (responseMap.containsKey('cartItemsAdded')) {
                cartItemsAdded = (Boolean) responseMap.get('cartItemsAdded');
            }

            if (responseMap.containsKey('cartItemsRemoved')) {
                cartItemsRemoved = (Boolean) responseMap.get('cartItemsRemoved');
            }

            if (responseMap.containsKey('cartItemsUpdated')) {
                cartItemsUpdated = (Boolean) responseMap.get('cartItemsUpdated');
            }

            // If there was a problem with any of the three possible transactions roll everything back.
            if (cartItemsAdded == false || cartItemsRemoved == false || cartItemsUpdated == false) {
                System.debug('rolling back cart transactions');
                Database.rollback(sp);
            }

            // Get latest version of the cart (already included in the responseMap for an Add or a Change).
            // If only a deletion was performed, will need to fetch the cart.
            /*
        if(responseMap.containsKey('cartItemsRaw') == false) {
            List<Map<String, Object>> cartList = (List<Map<String, Object>>)responseMap.get('cartListRaw');

            orderableItems = createOrderableItemsList(cartList, null, false, storefront, locale);

            responseMap.put('cartItems', orderableItems);

        }
        else {
            orderableItems = fetchCartItems(storefront, locale, cartId, true);

            responseMap.put('cartItems', orderableItems);
        }
        */

            //orderableItems = fetchCartItems(storefront, locale, cartId, true);
            orderableItems = fetchCartItems(userId, storefront, currencyCode, accountId, locale, cartId, true);

            responseMap.put('cartItems', orderableItems);
        }
        catch (CustomException e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.put('cartItemsUpdated', false);
            String msg = 'Error: ' + e.getMessage();
            responseMap.put('cartItemUpdateMsg', msg);
        }

        System.debug('---- end fetchUpdatedCart');

        return responseMap;

    }

    /*
        Adds items to an existing cart.
     */

    private static void putLineItems(String cartId, String itemsJson, Map<String, Object> responseMap) {

        System.debug('---- begin putLineItems');

        List<Object> items = (List<Object>)JSON.deserializeUntyped(itemsJson);

        System.debug('items: ' + items);
        System.debug('cartId: ' + cartId);

        responseMap.put('cartItemsAdded', false);

        Boolean isSuccess = false;

        Set<String> skuSet = new Set<String>();

        try {

            List<ccrz.ccApiCart.LineData> theNewLines = new List<ccrz.ccApiCart.LineData>();

            for(Object temp : items) {

                Map<String, Object> item = (Map<String, Object>)temp;

                System.debug('creating new line object');

                String sku = (String)item.get('sku');

                System.debug('sku = ' + sku);
                System.debug('qty = ' + item.get('qty'));

                skuSet.add(sku);

                ccrz.ccApiCart.LineData theNewLine = new ccrz.ccApiCart.LineData();

                theNewLine.sku = (String)item.get('sku');
                theNewLine.quantity = Integer.valueOf(item.get('qty'));

                theNewLines.add(theNewLine);
            }

            //System.debug('theNewLines: ' + JSON.serialize(theNewLines));

            System.debug('calling ccApiCart.addTo()');

            // 2018-11-26  msobczak: retrieve the current cart so that it can be used in a subsequent change transaction (if necessary).
            Map<String, Object> addResults = ccrz.ccApiCart.addTo(new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => 8
                    //ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccApiCart.CART_ID => cartId
                    ,ccrz.ccApiCart.LINE_DATA => theNewLines

                    // 2018-11-30  msobczak: reinstated refetch.  The Large parameter will include the product list and prices.
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                                    ,ccrz.ccApi.SZ_REFETCH => true
                            }
                    }

            });

            System.debug('back from ccApiCart.addTo()');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            isSuccess = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            if(isSuccess) {
                responseMap.put('cartItemsAdded', true);
                responseMap.put('cartAddItemMsg', 'Items successfully added to cart: ' + skuSet);


                /*
                    2019-01-23  msobczak: added because refetch stopped working.
                    Discovered that when the cart is created with API version 7, there are no issues.
                  */
//                System.debug('fetching modified cart with line items');
//                Map<String, Object> outputFetchData = new Map<String, Object>();
//
//                Set<String> searchIdSet = new Set<String>();
//                searchIdSet.add(cartId);
//
//                Map<String, Object> fetchInputData = new Map<String, Object>{
//                        ccrz.ccAPICart.CART_IDLIST => searchIdSet
//                        //,ccrz.ccAPI.API_VERSION => 7
//                        ,ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
//                        ,ccrz.ccApi.SIZING => new Map<String, Object>{
//                                ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
//                                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
//                                }
//                        }
//                };
//
//                outputFetchData = ccrz.ccAPICart.fetch(fetchInputData);


                // 2018-11-30 msobczak: add the product list and the cart list to the response
                List<Map<String, Object>> productList = (List<Map<String, Object>>)addResults.get('productList');
                responseMap.put('productList', productList);
                System.debug('productList: ' + productList);

                List<Map<String, Object>> cartList = (List<Map<String, Object>>)addResults.get(ccrz.ccApiCart.CART_OBJLIST);
                responseMap.put('cartList', cartList);
                System.debug('cartList: ' + cartList);
            }
            else {
                responseMap.put('cartAddItemMsg', 'Items not added to cart');
            }

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) addResults.get(ccrz.ccApi.MESSAGES);

            System.debug('messages = ' + messages);

            List<String> productIdsAddedToCart = (List<String>) addResults.get(ccrz.ccApiCart.PRODSADDEDTOCART);

            System.debug('productIdsAddedToCart = ' + productIdsAddedToCart);

        }
        catch(Exception e) {
            responseMap.put('cartAddItemMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

        System.debug('---- end putLineItems');

    }

    /*
        Change the qty of an existing line item.
        The ccAPICart.price() call must contain all cart line items.  If any are not included in the input parameter list, those items will be removed from the cart.
     */
    private static Map<String, Object> updateLineItems(String cartId, List<Map<String, Object>> orderableItems, String itemsJson) {

        System.debug('---- begin updateLineItems');

        Set<String> skuSet = new Set<String>();

        Map<String, Object> items = (Map<String, Object>)JSON.deserializeUntyped(itemsJson);

        System.debug('items: ' + items);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('cartItemsUpdated', false);

        Boolean isSuccess = false;

        try {

            Map<String, Map<String, Object>> cartItemChangeList = new Map<String, Map<String, Object>>();

            /*
            for(String cart_item_sfid : items.keySet()) {

                Map<String, Object> item = (Map<String, Object>)items.get(cart_item_sfid);

                System.debug('creating new line object');

                Integer qty = Integer.valueOf((String)item.get('qty'));

                System.debug('cart_item_sfid = ' + cart_item_sfid);
                System.debug('qty = ' + item.get('qty'));

                String sku = (String)item.get('sku');
                skuSet.add(sku);

                cartItemChangeList.put(cart_item_sfid, new Map<String, Object>{ccrz.ccApiCart.CIQTY => qty, ccrz.ccApiCart.CICMTS => 'revised'});

            }
            */
            for(Map<String, Object> orderableItem : orderableItems) {

                String cart_item_sfid = (String) orderableItem.get('cart_item_sfid');

                Integer qty = null;

                Object qtyObj = orderableItem.get('qty');

                if(qtyObj instanceof Decimal) {
                    qty = ((Decimal)qtyObj).intValue();
                }
                else {
                    qty = (Integer)qtyObj;
                }

                String sku = (String)orderableItem.get('sku');

                System.debug('sku = ' + sku);
                System.debug('cart_item_sfid = ' + cart_item_sfid);
                System.debug('orig qty = ' + qty);

                if(items.containsKey(cart_item_sfid)) {

                    Map<String, Object> item = (Map<String, Object>)items.get(cart_item_sfid);

                    // Override the current qty of the line item with what came in as a change
                    qty = Integer.valueOf((String)item.get('qty'));

                    System.debug('new qty = ' + qty);

                    skuSet.add(sku);
                }

                cartItemChangeList.put(cart_item_sfid, new Map<String, Object>{ccrz.ccApiCart.CIQTY => qty, ccrz.ccApiCart.CICMTS => 'revised'});

            }

            System.debug('skuSet = ' + skuSet);

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPICart.CILIST => cartItemChangeList
                    ,ccrz.ccApiCart.CART_ID => cartId
                    /*
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S
                                    ,ccrz.ccAPI.SZ_REFETCH => TRUE
                            }
                    }
                    */
            };

            System.debug('calling ccApiCart.price()');

            Map<String, Object> outputFetchData = new Map<String, Object>();
            outputFetchData = ccrz.ccApiCart.price(inputData);

            System.debug('back from ccApiCart.price()');

            isSuccess = (Boolean)outputFetchData.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            String cartEncryptedId = null;

            if(outputFetchData.containsKey(ccrz.ccApiCart.CART_ENCID)) {
                cartEncryptedId = (String)outputFetchData.get(ccrz.ccApiCart.CART_ENCID);
            }

            System.debug('cartEncryptedId = ' + cartEncryptedId);

            if(isSuccess) {
                responseMap.put('cartItemsUpdated', true);
                responseMap.put('cartItemUpdateMsg', 'items successfully updated in the cart: ' + skuSet);

                // 2018-11-25  msobczak: added so that we'll have the entire cart for any subsequent cart quantity changes.
                List<Map<String, Object>> cartList = (List<Map<String, Object>>)outputFetchData.get(ccrz.ccApiCart.CART_OBJLIST);

                responseMap.put('cartListRaw', cartList);
            }
            else {
                responseMap.put('cartItemUpdateMsg', 'items not updated in the cart');
            }

        }
        catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            System.debug('Line: ' + e.getLineNumber());

            String msg = 'Error: ' + e.getMessage();

            throw new CustomException(msg);
        }

        System.debug('---- end updateLineItems');

        return responseMap;

    }

    @AuraEnabled
    public static Map<String, Object> deleteLineItems(String cartId, String itemsJson) {
        System.debug('begin deleteLineItems');

        Map<String, Object> items = (Map<String, Object>)JSON.deserializeUntyped(itemsJson);

        System.debug('items: ' + items);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('cartItemsDeleted', false);

        Boolean isSuccess = false;

        Set<String> skuSet = new Set<String>();

        try {

            System.debug('adding new lines');

            List<ccrz.ccApiCart.LineData> theNewLines = new List<ccrz.ccApiCart.LineData>();

            System.debug('starting loop');

            for(String sfid : items.keySet()) {

                String sku = (String)items.get(sfid);
                skuSet.add(sku);

                System.debug('creating new line object');

                System.debug('sku = ' + sku);
                System.debug('sfid = ' + sfid);

                ccrz.ccApiCart.LineData theNewLine = new ccrz.ccApiCart.LineData();

                theNewLine.sku = sku;
                theNewLine.sfid = sfid;

                theNewLines.add(theNewLine);
            }

            System.debug('calling ccApiCart.addTo()');

            Map<String, Object> apiResults = ccrz.ccApiCart.removeFrom(new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => 7,
                    ccrz.ccApiCart.CART_ID => cartId,
                    ccrz.ccApiCart.LINE_DATA => theNewLines

            });

            System.debug('back from ccApiCart.addTo()');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            isSuccess = (Boolean) apiResults.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            if(isSuccess) {
                responseMap.put('cartItemsDeleted', true);
                responseMap.put('cartDeleteItemMsg', 'Items successfully deleted from cart: ' + skuSet);

                //List<Map<String, Object>> orderableItems = createOrderableItemsList(apiResults, false, '', '');

                //System.debug('cartItems = ' + orderableItems);

                //responseMap.put('cartItems', orderableItems);
            }
            else {
                responseMap.put('cartDeleteItemMsg', 'Items not deleted from cart');
            }

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) apiResults.get(ccrz.ccApi.MESSAGES);

            System.debug('messages = ' + messages);
        }
        catch(Exception e) {
            responseMap.put('cartDeleteItemMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug(e.getLineNumber());
        }

        return responseMap;

    }

    /*
        Utility method that converts the fetched cart data into the format used by the order form components.
     */
    private static List<Map<String, Object>> createOrderableItemsList(List<Map<String, Object>> cartList, Map<String, Map<String, Object>> productsMap, Boolean getPrices, String storefront, String locale) {

        System.debug('---- begin createOrderableItemsList');

        //System.debug('cartList size = ' + cartList.size());
        //System.debug('cartList = ');
        //System.debug(cartList);

        Map<String, Object> cartMap = new Map<String, Object>();
        if(cartList.size() > 0) {
            cartMap = cartList.get(0);
        }

        System.debug('cartMap = ');
        System.debug(JSON.serialize(cartMap));

        List<Map<String, Object>> cartItemsList = new List<Map<String, Object>>();
        if(cartMap.containsKey('ECartItemsS')) {
            cartItemsList = (List<Map<String, Object>>)cartMap.get('ECartItemsS');
        }

        System.debug('cartItemsList = ');
        System.debug(JSON.serialize(cartItemsList));

        List<Map<String, Object>> orderableItems = new List<Map<String, Object>>();

        for(Map<String, Object> cartItemMap : cartItemsList) {

            String productType = (String)cartItemMap.get('productType');

            // Only include simple products
            if(productType == 'Product') {
                Map<String, Object> orderableItem = new Map<String, Object>();
                orderableItem.put('productName', '');
                orderableItem.put('product_sfid', cartItemMap.get('product'));

                if(orderableItem.containsKey('price')) {
                    orderableItem.put('price', cartItemMap.get('price'));
                }
                else {
                    orderableItem.put('price', 0.00);
                }

                orderableItem.put('qty', cartItemMap.get('quantity'));
                orderableItem.put('orig_qty', cartItemMap.get('quantity'));
                orderableItem.put('sku', '');  // Get from productList

                orderableItem.put('cart_item_sfid', cartItemMap.get('sfid'));

                orderableItems.add(orderableItem);
            }
        }

        // Get the SKU and productName for each order item from the productList
        for(Map<String, Object> orderableItem : orderableItems) {
//            String sfid = (String)orderableItem.get('product_sfid');
//            for (Map<String, Object> productMap : productList) {
//                if(sfid == (String)productMap.get('sfid')) {
//                    orderableItem.put('sku', productMap.get('SKU'));
//                    orderableItem.put('productName', productMap.get('sfdcName'));
//                }
//            }

            // 2019-10-10  msobczak: add product media to each order item
            String productSfid = (String)orderableItem.get('product_sfid');

            if(productsMap.containsKey(productSfid)) {

                Map<String, Object> productMap = productsMap.get(productSfid);

                orderableItem.put('sku', productMap.get('SKU'));
                orderableItem.put('productName', productMap.get('sfdcName'));

                List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');
                //orderItemMap.put('EProductMediasS', productMediaList);

                for(Map<String, Object> productMedia : productMediaList) {
                    String mediaType = (String)productMedia.get('mediaType');

                    if(mediaType == 'Product Image Thumbnail') {
                        orderableItem.put('thumbnailImage', productMedia);
                        break;
                    }
                }
            }

        }

        if(getPrices && orderableItems.size() > 0) {
            // Get the current price for the items
            fetchProductPricing(orderableItems, storefront, locale);
        }

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        System.debug('---- end createOrderableItemsList');

        return orderableItems;
    }

    /*
        Used for when a new cart is created.
     */
    private static List<Map<String, Object>> createOrderableItemsList(List<Map<String, Object>> cartList, Map<String, Map<String, Object>> productsMap) {

        System.debug('---- begin createOrderableItemsList2');

        Map<String, Object> cartMap = new Map<String, Object>();
        if(cartList.size() > 0) {
            cartMap = cartList.get(0);
        }

        List<Map<String, Object>> cartItemsList = new List<Map<String, Object>>();
        if(cartMap.containsKey('ECartItemsS')) {
            cartItemsList = (List<Map<String, Object>>)cartMap.get('ECartItemsS');
        }

        System.debug('cartItemsList = ');
        System.debug(cartItemsList);

        //Map<String, Object> orderItemMap = orderItemsMap.get(0);
        //
        //for(String key : orderItemMap.keySet()) {
        //    System.debug('key = ' + key);
        //}

        List<Map<String, Object>> orderableItems = new List<Map<String, Object>>();

        for(Map<String, Object> cartItemMap : cartItemsList) {
            String productType = (String)cartItemMap.get('productType');

            // Only include simple products
            if(productType == 'Product') {
                Map<String, Object> orderableItem = new Map<String, Object>();
                orderableItem.put('productName', '');
                orderableItem.put('product_sfid', cartItemMap.get('product'));

                if(cartItemMap.containsKey('price')) {
                    orderableItem.put('price', cartItemMap.get('price'));
                }
                else {
                    orderableItem.put('price', 0.00);
                }

                orderableItem.put('qty', cartItemMap.get('quantity'));
                orderableItem.put('orig_qty', cartItemMap.get('quantity'));
                orderableItem.put('sku', '');  // Get from productList

                orderableItem.put('cart_item_sfid', cartItemMap.get('sfid'));

                orderableItems.add(orderableItem);
            }
        }

        // Get the SKU and productName for each order item from the productList
        for(Map<String, Object> orderableItem : orderableItems) {
//            String sfid = (String)orderableItem.get('product_sfid');
//            for (Map<String, Object> productMap : productList) {
//                if(sfid == (String)productMap.get('sfid')) {
//                    orderableItem.put('sku', productMap.get('SKU'));
//                    orderableItem.put('productName', productMap.get('sfdcName'));
//                }
//            }

            // 2019-10-10  msobczak: add product media to each order item
            String productSfid = (String)orderableItem.get('product_sfid');

            if(productsMap.containsKey(productSfid)) {

                Map<String, Object> productMap = productsMap.get(productSfid);

                orderableItem.put('sku', productMap.get('SKU'));
                orderableItem.put('productName', productMap.get('sfdcName'));

                List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');
                //orderItemMap.put('EProductMediasS', productMediaList);

                for(Map<String, Object> productMedia : productMediaList) {
                    String mediaType = (String)productMedia.get('mediaType');

                    if(mediaType == 'Product Image Thumbnail') {
                        orderableItem.put('thumbnailImage', productMedia);
                        break;
                    }
                }
            }
        }

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        System.debug('---- end createOrderableItemsList2');

        return orderableItems;
    }

    private static void getContact(String contactId, Map<String, Object> responseMap) {

        System.debug('---- begin getContact');

        responseMap.put('contactRetrieved', false);

        try {

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApiContact.ID => contactId
                    //,ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                    ,ccrz.ccApi.API_VERSION => 7
            };

            Map<String, Object> outputData = ccrz.ccApiContact.fetch(inputData);

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            if(wasSuccessful) {

                System.debug('outputData: ');
                System.debug(outputData);

                if(outputData.containsKey(ccrz.ccApiContact.CONTACTS) == false) {
                    throw new CustomException('Contact not found (null)');
                }

                List<Object> tempList = (List<Object>) outputData.get(ccrz.ccApiContact.CONTACTS);

                if(tempList.size() == 0) {
                    throw new CustomException('Contact not found (empty list)');
                }

                List<Map<String, Object>> contactList = (List<Map<String, Object>>)tempList;

                Map<String, Object> contactMap = (Map<String, Object>)contactList.get(0);

                responseMap.put('contactMap', contactMap);

                responseMap.put('contactRetrieved', true);
                responseMap.put('contactRetrievedMsg', 'Contact data retrieved');
                System.debug('Contact data retrieved');
            }
            else {
                System.debug('Contact data not found');
                responseMap.put('orderPlacedMsg', 'Contact data not found');
            }
        }
        catch (Exception e) {
            responseMap.put('contactRetrievedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end getContact');

    }

    public class CustomException extends Exception {}

}