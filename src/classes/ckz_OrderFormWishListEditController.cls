/**
 * Created by msobczak on 10/17/2019.
 */

public with sharing class ckz_OrderFormWishListEditController {

    /*
        Returns the specified wish list's line items.
     */
    @AuraEnabled
    public static Map<String, Object> fetchWishList(String userId, String storefront, String currencyCode, String accountId, String locale, String wishListId) {

        System.debug('---- begin fetchWishList');

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

        ccrz.cc_CallContext.init(ctx);

        Set<String> searchIdSet = new Set<String>();
        searchIdSet.add(wishListId);

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPIWishList.OWNER => userId
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccAPIWishList.INCLUDE_ITEMS => true
                ,ccrz.ccAPIWishList.IDS => searchIdSet

                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIWishList.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L  // M to get lastModifiedDate, L to get subtotalAmount
                        }
                }

                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                        }
                }

        };

        Map<String, Object> outputFetchData = ccrz.ccAPIWishList.fetch(inputData);

        // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
        Map<String, Map<String, Object>> productsMap = productListProcessing(outputFetchData);

        List<Map<String, Object>> cartList = new List<Map<String, Object>>();

        if (outputFetchData.get(ccrz.ccAPIWishList.WISHLISTS) != null) {
            /*
                Some pre-processing here.  Wish lists are returned as properties of a Map, while carts are returned as a List.
             */
            Map<String, Map<String, Object>> wishListsMap = (Map<String, Map<String, Object>>) outputFetchData.get(ccrz.ccAPIWishList.WISHLISTS);

            for(String key : wishListsMap.keySet()) {
                Map<String, Object> wishListMap = wishListsMap.get(key);
                cartList.add(wishListMap);
            }
        }

        Map<String, Object> cartMap = new Map<String, Object>();
        if(cartList.size() > 0) {
            cartMap = cartList.get(0);
        }

        List<Map<String, Object>> orderableItems = createOrderableItemsList(cartMap, productsMap);

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        responseMap.put('orderItems', orderableItems);

        responseMap.put('wishListId', (String)cartMap.get('sfid'));
        responseMap.put('wishListName', (String)(cartList.get(0).get('name')));
        responseMap.put('wishListSfdcName', (String)(cartList.get(0).get('sfdcName')));

        System.debug('---- exit fetchWishList');

        return responseMap;

    }

    private static List<Map<String, Object>> createOrderableItemsList(Map<String, Object> cartMap, Map<String, Map<String, Object>> productsMap) {

        System.debug('---- begin createOrderableItemsList');

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
            //if(productType == 'Product') {
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
            //}
        }

        // Get the SKU and productName for each order item from the productList
        for(Map<String, Object> orderableItem : orderableItems) {

            // 2019-10-10  msobczak: add product media to each order item
            String productSfid = (String)orderableItem.get('product_sfid');

            if(productsMap.containsKey(productSfid)) {

                Map<String, Object> productMap = productsMap.get(productSfid);

                orderableItem.put('sku', productMap.get('SKU'));
                orderableItem.put('productName', productMap.get('sfdcName'));

                List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');

                for(Map<String, Object> productMedia : productMediaList) {
                    String mediaType = (String)productMedia.get('mediaType');

                    if(mediaType == 'Product Image Thumbnail') {
                        orderableItem.put('thumbnailImage', productMedia);
                        break;
                    }
                }

                orderableItem.put('productData', productMap);

            }

        }

        System.debug('orderableItems = ');
        System.debug(orderableItems);

        System.debug('---- end createOrderableItemsList');

        return orderableItems;
    }

    /*
        Creates a new wish list (cart) object and adds items to it.
     */
    @AuraEnabled
    public static Map<String, Object> fetchNewWishList(String wishListName, String userId, String contactId, String locale, String storefront, String currencyCode, String accountId, String itemsJson) {

        System.debug('---- begin fetchNewWishList');

        Boolean wishListCreated = false;
        Boolean wishListItemsAdded = false;

        System.debug('userId = ' + userId);
        System.debug('contactId = ' + contactId);
        System.debug('locale = ' + locale);
        System.debug('storefront = ' + storefront);
        System.debug('currencyCode = ' + currencyCode);
        System.debug('accountId = ' + accountId);
        System.debug('wishListName = ' + wishListName);
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

        ccrz.cc_CallContext.init(ctx);


        List<Map<String, Object>> orderableItems = null;

        Map<String, Object> responseMap = new Map<String, Object>();

        Savepoint sp = Database.setSavepoint();

        try {

            createWishList(wishListName, storefront, currencyCode, responseMap);

            wishListCreated = (Boolean)responseMap.get('wishListCreated');

            System.debug('wishListCreated = ' + wishListCreated);

            if(wishListCreated == false) {
                String msg = (String)responseMap.get('wishListCreatedMsg');

                throw new CustomException(msg);
            }

            String wishListId = (String)responseMap.get('wishListId');

            System.debug('wishListId = ' + wishListId);

            putLineItems(wishListId, itemsJson, responseMap);

            wishListItemsAdded = (Boolean)responseMap.get('wishListItemsAdded');

            if(wishListItemsAdded == false) {
                String msg = (String)responseMap.get('wishListItemsAdded');
                throw new CustomException(msg);
            }

            System.debug('wishListItemsAdded = ' + wishListItemsAdded);

            List<Map<String, Object>> productList = (List<Map<String, Object>>)responseMap.get('productList');

            // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
            Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productMap : productList) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
            }

            List<Map<String, Object>> cartList = (List<Map<String, Object>>)responseMap.get('cartList');

            Map<String, Object> cartMap = new Map<String, Object>();
            if(cartList.size() > 0) {
                cartMap = cartList.get(0);
            }

            orderableItems = createOrderableItemsList(cartMap, productsMap);

            responseMap.put('orderItems', orderableItems);

        }
        catch (CustomException e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.remove('cartEncryptedId');
            responseMap.remove('cartId');
        }

        System.debug('---- end fetchNewWishList');

        return responseMap;

    }

    /*
        Creates a wish list (cart) object.  This does not add line items.
     */
    public static void createWishList(String wishListName, String storefront, String currencyCode, Map<String, Object> responseMap) {

        System.debug('---- begin createWishList');

        responseMap.put('wishListCreated', false);
        responseMap.put('cartEncryptedId', null);
        responseMap.put('wishListId', null);
        responseMap.put('wishListName', null);

        try {

            Map<String, Object> newWishListData = new Map<String, Object>{
                    'storefront' => storefront
                    , 'currencyISOCode' => currencyCode
                    , 'note' => 'Headless commerce'
                    , 'name' => wishListName

            };

            List<Object> newCartList = new List<Object>();
            newCartList.add(newWishListData);

            Map<String, Object> inputData = new Map<String, Object>{
                    //ccrz.ccApi.API_VERSION => 8
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIWishList.WISHLIST => newWishListData
            };

            System.debug('creating the wish list');
            Map<String, Object> outputData = (Map<String, Object>) ccrz.ccAPIWishList.create(inputData);
            System.debug('back from API call');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean wishListCreated = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wishListCreated = ' + wishListCreated);

            if (wishListCreated) {
                responseMap.put('wishListCreated', true);
                responseMap.put('wishListCreatedMsg', 'Wish list created successfully');

                String wishListId = (String)outputData.get('wlId');
                responseMap.put('wishListId', wishListId);

                Map<String, Object> wishListMap = (Map<String, Object>)outputData.get('wishList');

                String name = (String)wishListMap.get('name');
                System.debug('new wish list name: ' + name);
                responseMap.put('wishListName', name);

            } else {
                responseMap.put('wishListCreatedMsg', 'Wish list not created');
            }

        }
        catch (Exception e) {
            responseMap.put('wishListCreatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

        System.debug('---- end createWishList');

    }

    /*
        Adds items to an existing cart.
     */

    private static void putLineItems(String wishListId, String itemsJson, Map<String, Object> responseMap) {

        System.debug('---- begin putLineItems');

        List<Object> items = (List<Object>)JSON.deserializeUntyped(itemsJson);

        System.debug('items: ' + items);
        System.debug('wishListId: ' + wishListId);

        responseMap.put('wishListItemsAdded', false);

        Boolean isSuccess = false;

        Set<String> skuSet = new Set<String>();

        try {

            for(Object temp : items) {

                Map<String, Object> item = (Map<String, Object>)temp;

                String sku = (String)item.get('sku');

                System.debug('sku = ' + sku);

                skuSet.add(sku);
            }

            System.debug('calling ccAPIWishList.addTo()');

            Map<String, Object> addResults = ccrz.ccAPIWishList.addTo(new Map<String, Object>{
                    //ccrz.ccApi.API_VERSION => 8
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIWishList.ID => wishListId
                    ,ccrz.ccAPIProduct.PRODUCTSKULIST => skuSet

                    // 2018-11-30  msobczak: reinstated refetch.  The Large parameter will include the product list and prices.
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIWishList.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                                    ,ccrz.ccApi.SZ_REFETCH => true
                            }
                    }

            });

            System.debug('back from ccAPIWishList.addTo()');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            isSuccess = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            if(isSuccess) {
                responseMap.put('wishListItemsAdded', true);
                responseMap.put('wishListItemsAddedMsg', 'Items successfully added: ' + skuSet);

                //System.debug('addResults: ' + addResults);

                // 2018-11-30 msobczak: add the product list and the cart list to the response
                List<Map<String, Object>> productList = (List<Map<String, Object>>)addResults.get('productList');
                responseMap.put('productList', productList);
                System.debug('productList: ' + productList);

                List<Map<String, Object>> cartList = new List<Map<String, Object>>();

                if (addResults.get(ccrz.ccAPIWishList.WISHLISTS) != null) {
                    /*
                        Some pre-processing here.  Wish lists are returned as properties of a Map, while carts are returned as a List.
                     */
                    Map<String, Map<String, Object>> wishListsMap = (Map<String, Map<String, Object>>) addResults.get(ccrz.ccAPIWishList.WISHLISTS);

                    for(String key : wishListsMap.keySet()) {
                        Map<String, Object> wishListMap = wishListsMap.get(key);
                        cartList.add(wishListMap);
                    }
                }

                responseMap.put('cartList', cartList);

            }
            else {
                responseMap.put('wishListItemsAddedMsg', 'Items not added');
            }

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) addResults.get(ccrz.ccApi.MESSAGES);

            System.debug('messages = ' + messages);

        }
        catch(Exception e) {
            responseMap.put('wishListItemsAddedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

        System.debug('---- end putLineItems');

    }

    /*
        Handles adds and deletes to an existing wish list (cart).
        Update of a wish list item does not apply, because the qty is always 1.
     */
    @AuraEnabled
    public static Map<String, Object> fetchUpdatedWishList(String wishListName, String userId, String storefront, String currencyCode, String accountId, String locale, String wishListId, String addItemsJson, String removeItemsJson) {
        System.debug('---- begin fetchUpdatedWishList');

        System.debug('userId: ' + userId);
        System.debug('storefront: ' + storefront);
        System.debug('currencyCode: ' + currencyCode);
        System.debug('accountId: ' + accountId);
        System.debug('locale: ' + locale);
        System.debug('wishListId: ' + wishListId);
        System.debug('wishListName: ' + wishListName);

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

        ccrz.cc_CallContext.init(ctx);

        Savepoint sp = Database.setSavepoint();

        Map<String, Object> responseMap = new Map<String, Object>();

        try {

            // Revise name if parameter is not null
            if(wishListName != null) {
                reviseWishList(wishListName, wishListId, responseMap);
            }

            // Delete items
            if (removeItemsJson != null && removeItemsJson != '') {
                Map<String, Object> removeResponseMap = deleteLineItems(wishListId, removeItemsJson);

                responseMap.putAll(removeResponseMap);
            }

            // Add items
            // Response includes the current cart items
            if (addItemsJson != null && addItemsJson != '') {

                putLineItems(wishListId, addItemsJson, responseMap);

            }

            // See if there were any errors
            Boolean wishListItemsAdded = true;
            Boolean wishListItemsRemoved = true;

            if (responseMap.containsKey('wishListItemsAdded')) {
                wishListItemsAdded = (Boolean) responseMap.get('wishListItemsAdded');
            }

            if (responseMap.containsKey('wishListItemsRemoved')) {
                wishListItemsRemoved = (Boolean) responseMap.get('cartItemsRemoved');
            }

            // If there was a problem with any of the three possible transactions roll everything back.
            if (wishListItemsAdded == false || wishListItemsRemoved == false) {
                System.debug('rolling back cart transactions');
                Database.rollback(sp);
            }

            Map<String, Object> fetchResponseMap = fetchWishList(userId, storefront, currencyCode, accountId, locale, wishListId);

            responseMap.putAll(fetchResponseMap);
        }
        catch (CustomException e) {
            System.debug('rolling back transactions');
            Database.rollback(sp);

            responseMap.put('wishListItemsUpdated', false);
            String msg = 'Error: ' + e.getMessage();
            responseMap.put('wishListItemUpdateMsg', msg);
        }

        System.debug('---- end fetchUpdatedWishList');

        return responseMap;

    }

    @AuraEnabled
    public static Map<String, Object> deleteLineItems(String wishListId, String itemsJson) {
        System.debug('begin deleteLineItems');

        Map<String, Object> items = (Map<String, Object>)JSON.deserializeUntyped(itemsJson);

        System.debug('items: ' + items);

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('wishListItemsDeleted', false);

        Boolean isSuccess = false;

        Set<String> itemIdSet = new Set<String>();
        Set<String> skuSet = new Set<String>();

        try {

            System.debug('deleting lines');

            System.debug('starting loop');

            for(String sfid : items.keySet()) {

                String sku = (String)items.get(sfid);
                skuSet.add(sku);

                itemIdSet.add(sfid);
            }

            System.debug('calling ccAPIWishList.removeFrom()');

            Map<String, Object> apiResults = ccrz.ccAPIWishList.removeFrom(new Map<String, Object>{
                    //ccrz.ccApi.API_VERSION => 7,
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIWishList.ID => wishListId
                    ,ccrz.ccAPIWishList.WISHLIST_ITEM_IDS => itemIdSet

            });

            System.debug('back from ccAPIWishList.removeFrom()');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            isSuccess = (Boolean) apiResults.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            if(isSuccess) {
                responseMap.put('wishListItemsDeleted', true);
                responseMap.put('wishListItemsDeletedMsg', 'Items successfully deleted: ' + skuSet);
            }
            else {
                responseMap.put('wishListItemsDeletedMsg', 'Items not deleted');
            }

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) apiResults.get(ccrz.ccApi.MESSAGES);

            System.debug('messages = ' + messages);
        }
        catch(Exception e) {
            responseMap.put('wishListItemsDeletedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug(e.getLineNumber());
        }

        return responseMap;

    }

    private static void reviseWishList(String wishListName, String wishListId, Map<String, Object> responseMap) {

        try {

            responseMap.put('wishListRevised', false);

            Map<String, Object> wishListData = new Map<String, Object>{
                    'name' => wishListName
                    ,'sfid' => wishListId
            };

            List<Map<String, Object>> wishListLists = new List<Map<String, Object>>();

            wishListLists.add(wishListData);

            System.debug('calling ccAPIWishList.revise()');

            Map<String, Object> apiResults = ccrz.ccAPIWishList.revise(new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIWishList.WISHLISTS => wishListLists

            });

            System.debug('back from ccAPIWishList.revise()');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean isSuccess = (Boolean) apiResults.get(ccrz.ccApi.SUCCESS);

            System.debug('isSuccess = ' + isSuccess);

            if(isSuccess) {
                responseMap.put('wishListRevised', true);
                responseMap.put('wishListRevisedMsg', 'Name updated');
            }
            else {
                responseMap.put('wishListRevisedMsg', 'Name not updated');
            }

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) apiResults.get(ccrz.ccApi.MESSAGES);

            System.debug('messages = ' + messages);
        }
        catch(Exception e) {
            responseMap.put('wishListRevisedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug(e.getLineNumber());

            throw new CustomException('Error revising wish list header');
        }

    }

    private static Map<String, Map<String, Object>> productListProcessing(Map<String, Object> outputFetchData) {

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

            // Handle when no specs are present
            if((productMap.containsKey('productSpecIndiciesS') == false) || productMap.containsKey('productSpecIndiciesS') == false) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
                continue;
            }

            List<Map<String, Object>> productSpecIndiciesS = (List<Map<String, Object>>)productMap.get('productSpecIndiciesS');

            List<Map<String, Object>> productSpecsS = (List<Map<String, Object>>)productMap.get('productSpecsS');

            // put all of the productSpecsS entries into a Map, for quick retrieval
            Map<String, Map<String, Object>> allProductSpecsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productSpecsSMap : productSpecsS) {
                String spec = (String)productSpecsSMap.get('spec');

                allProductSpecsMap.put(spec, productSpecsSMap);
            }

            System.debug('allProductSpecsMap: ' + allProductSpecsMap);

            // Get the correctly formatted product spec value from the Map just created
            for(Map<String, Object> productSpecIndiciesMap : productSpecIndiciesS) {
                String spec = (String)productSpecIndiciesMap.get('spec');

                if(allProductSpecsMap.containsKey(spec)) {
                    Map<String, Object> productSpecsMap2 = allProductSpecsMap.get(spec);
                    String specValue = (String)productSpecsMap2.get('specValue');

                    if(((String)productSpecIndiciesMap.get('specValue')) != specValue) {
                        System.debug('updated specValue');
                        productSpecIndiciesMap.put('specValue', specValue);
                    }
                }
            }

            String productSfid = (String)productMap.get('sfid');
            productsMap.put(productSfid, productMap);
        }

        return productsMap;

    }

    public class CustomException extends Exception {}

}