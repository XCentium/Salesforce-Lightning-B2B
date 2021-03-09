public with sharing class ckz_OrderFormStartController {

    // 2019-10-10  msobczak

    @AuraEnabled
    public static Map<String, Object> fetchUserInfo(String recordId) {

        Id contactId = null;

        System.debug('recordId = ' + recordId);

        Map<String, Object> userInfoMap = new Map<String, Object>();

        if(recordId == null) {
            return userInfoMap;
        }

        if(recordId.startsWith('500')) {
            Case caseObj = [Select Id, CaseNumber, ContactId from Case where Id = :recordId];

            if(caseObj != null) {
                contactId = caseObj.ContactId;
            }
        }
        else {
            contactId = recordId;
        }

        ccrz__E_AccountGroup__c ag = null;

        Contact contact = [Select Id, Name, AccountId from Contact where Id = :contactId];

        Account account = [Select Id, Name, ccrz__E_AccountGroup__c from Account where Id = :contact.AccountId];

        if(account.ccrz__E_AccountGroup__c != null) {
            ag = [Select Id, Name from ccrz__E_AccountGroup__c where Id = :account.ccrz__E_AccountGroup__c];
        }

        User user = [Select Id, Name, LocaleSidKey, ccrz__CC_CurrencyCode__c from User where ContactId = :contactId];

        userInfoMap.put('userId', user.Id);

        // 2019-01-14  msobczak: added
        userInfoMap.put('contactId', contactId);

        userInfoMap.put('accountGroupName', ag.Name);

        userInfoMap.put('accountGroup', ag);

        userInfoMap.put('locale', user.LocaleSidKey);

        userInfoMap.put('userName', user.Name);

        userInfoMap.put('accountId', account.Id);

        userInfoMap.put('currencyCode', user.ccrz__CC_CurrencyCode__c);

        return userInfoMap;
    }

    @AuraEnabled
    public static ccrz__E_AccountGroup__c getAccountGroup(Id contactId) {

        System.debug('contactId: ' + contactId);

        ccrz__E_AccountGroup__c ag = null;

        Contact contact = [Select Id, Name, AccountId from Contact where Id = :contactId];

        Account account = [Select Id, Name, ccrz__E_AccountGroup__c from Account where Id = :contact.AccountId];

        if(account.ccrz__E_AccountGroup__c != null) {
            ag = [Select Id, Name from ccrz__E_AccountGroup__c where Id = :account.ccrz__E_AccountGroup__c];
        }

        System.debug('ag: ' + ag);

        return ag;

    }

    @AuraEnabled
    public static List<Map<String, Object>> fetchOrders(String storefront, String userId, String locale) {

        System.debug('storefront: ' + storefront);
        System.debug('userId: ' + userId);

        Integer orderTot = 5;

        Map<String, Object> orders = new Map<String, Object>();

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = 'USD';

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPIOrder.PARAM_OWNERID => userId
                , ccrz.ccAPIOrder.PARAM_STOREFRONT => ctx.storefront
                , ccrz.ccAPI.API_VERSION => 7
                , ccrz.ccAPIOrder.PARAM_BY_DATE => TRUE

                // 2019-10-10  msobczak: added
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                        }
                }
        };

        try {
            Map<String, Object> outputData = ccrz.ccAPIOrder.fetch(inputData);

            System.debug('outputData: ' + outputData);

            // 2019-10-10  msobczak: added
            List<Map<String, Object>> productList = new List<Map<String, Object>>();
            if(outputData.containsKey('productList')) {
                productList = (List<Map<String, Object>>)outputData.get('productList');
            }

            // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
            Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productMap : productList) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
            }

            if (outputData.get(ccrz.ccAPIOrder.ORDERLIST) != null) {

                List<Map<String, Object>> outputOrderList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIOrder.ORDERLIST);

                for (integer i = 0; i < orderTot; i++) {

                    Boolean isValid = true;

                    Map<String, Object> orderMap = (Map<String, Object>) outputOrderList.get(i);

                    System.debug('orderMap: ' + JSON.serialize(orderMap));

                    if (orderMap.get('orderDate') != null) {
                        Date orderItemDate = Date.valueOf((String) orderMap.get('orderDate'));
                        orderMap.put('orderDateStr', orderItemDate.format());
                    } else {
                        orderMap.put('orderDateStr', '');
                    }

                    // Get the items on the order
                    List<Map<String, Object>> orderItemsList = null;
                    if(orderMap.containsKey('EOrderItemsS')) {
                        orderItemsList = (List<Map<String, Object>>)orderMap.get('EOrderItemsS');
                    }

                    List<String> orderProducts = new List<String>();

                    for(Map<String, Object> orderItemMap : orderItemsList) {
                        if(orderItemMap.containsKey('productName')) {
                            orderProducts.add((String)orderItemMap.get('productName'));
                        }
                        if(orderItemMap.containsKey('productType')) {
                            if(((String)orderItemMap.get('productType')) != 'Product') {
                                isValid = false;
                            }
                        }

                        // 2019-10-10  msobczak: add product media to each order item
                        String productSfid = (String)orderItemMap.get('product');

                        if(productsMap.containsKey(productSfid)) {

                            Map<String, Object> productMap = productsMap.get(productSfid);

                            List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');
                            //orderItemMap.put('EProductMediasS', productMediaList);

                            for(Map<String, Object> productMedia : productMediaList) {
                                String mediaType = (String)productMedia.get('mediaType');

                                if(mediaType == 'Product Image Thumbnail') {
                                    orderItemMap.put('thumbnailImage', productMedia);
                                    break;
                                }
                            }
                        }

                    }

                    orderMap.put('orderItemsList', orderItemsList);
                    orderMap.put('isValid', isValid);

                    dataList.add(orderMap);

                }

            }


        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

        }

        return dataList;
    }

    @AuraEnabled
    public static List<Map<String, Object>> fetchCarts(String storefront, String userId, String locale) {

        System.debug('storefront: ' + storefront);
        System.debug('userId: ' + userId);

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = 'USD';
        ctx.portalUserId = userId;

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        try {

            List<Map<String, Object>> dataList1 = fetchCartsByStatus('Open', storefront, userId, locale);

            List<Map<String, Object>> dataList2 = fetchCartsByStatus('Abandoned', storefront, userId, locale);

            dataList.addAll(dataList1);

            dataList.addAll(dataList2);


        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());
            System.debug(ex.getStackTraceString());

        }

        return dataList;
    }

    public static List<Map<String, Object>> fetchCartsByStatus(String status, String storefront, String userId, String locale) {

        System.debug('storefront: ' + storefront);
        System.debug('userId: ' + userId);

        Integer orderTot = 5;

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPICart.CARTTYPE => 'Cart'
                ,ccrz.ccAPICart.BYOWNER => userId
                ,ccrz.ccAPICart.CARTSTATUS => status
                //,ccrz.ccAPI.API_VERSION => 7
                ,ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L  // M to get lastModifiedDate, L to get subtotalAmount
                        }
                }

                // 2019-10-10  msobczak: added
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                        }
                }

        };

        try {
            Map<String, Object> outputFetchData = ccrz.ccAPICart.fetch(inputData);

            System.debug('outputData: ' + outputFetchData);

            List<Map<String, Object>> productList = new List<Map<String, Object>>();
            if(outputFetchData.containsKey('productList')) {
                productList = (List<Map<String, Object>>)outputFetchData.get('productList');
            }

            // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
            Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productMap : productList) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
            }

            System.debug('productList size = ' + productList.size());
            System.debug('productList = ');
            System.debug(productList);

            if (outputFetchData.get(ccrz.ccAPICart.CART_OBJLIST) != null) {

                List<Map<String, Object>> cartList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPICart.CART_OBJLIST);

                for (integer i = 0; i < orderTot; i++) {

                    Boolean isValid = true;

                    Map<String, Object> cartMap = (Map<String, Object>)cartList.get(i);

                    if (cartMap.get('lastModifiedDate') != null) {

                        // 2019-01-09  msobczak: added logic to handle lastModifiedDate being returned in DateTime format.
                        System.debug('lastModifiedDate = ' + cartMap.get('lastModifiedDate'));

                        Object lastModifiedDate = cartMap.get('lastModifiedDate');

                        if(lastModifiedDate instanceof DateTime) {
                            cartMap.put('lastModifiedDateStr', ((DateTime)lastModifiedDate).format());
                        }
                        else {
                            Date orderItemDate = Date.valueOf((String) cartMap.get('lastModifiedDate'));
                            cartMap.put('lastModifiedDateStr', orderItemDate.format());
                        }

                    } else {
                        cartMap.put('lastModifiedDateStr', '');
                    }

                    List<Map<String, Object>> cartItemsList = new List<Map<String, Object>>();
                    if(cartMap.containsKey('ECartItemsS')) {
                        cartItemsList = (List<Map<String, Object>>)cartMap.get('ECartItemsS');
                    }

                    List<String> orderProducts = new List<String>();

                    for(Map<String, Object> cartItemMap : cartItemsList) {

                        // Get the SKU and productName for each order item from the productList

//                        String sfid = (String)cartItemMap.get('product');
//
//                        for (Map<String, Object> productMap : productList) {
//                            if(sfid == (String)productMap.get('sfid')) {
//                                cartItemMap.put('sku', productMap.get('SKU'));
//                                cartItemMap.put('productName', productMap.get('sfdcName'));
//                            }
//                        }

                        // 2019-10-10  msobczak: add product media to each order item
                        String productSfid = (String)cartItemMap.get('product');

                        if(productsMap.containsKey(productSfid)) {

                            Map<String, Object> productMap = productsMap.get(productSfid);

                            cartItemMap.put('sku', productMap.get('SKU'));
                            cartItemMap.put('productName', productMap.get('sfdcName'));

                            List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');
                            //orderItemMap.put('EProductMediasS', productMediaList);

                            for(Map<String, Object> productMedia : productMediaList) {
                                String mediaType = (String)productMedia.get('mediaType');

                                if(mediaType == 'Product Image Thumbnail') {
                                    cartItemMap.put('thumbnailImage', productMedia);
                                    break;
                                }
                            }
                        }

                    }

                    for(Map<String, Object> cartItemMap : cartItemsList) {
                        if(cartItemMap.containsKey('productName')) {
                            orderProducts.add((String)cartItemMap.get('productName'));
                        }
                        if(cartItemMap.containsKey('productType')) {
                            String productType = (String)cartItemMap.get('productType');
                            System.debug('productType = ' + productType);
                            if(productType != 'Product') {
                                isValid = false;
                            }
                        }
                    }

                    cartMap.put('cartItemsList', cartItemsList);
                    cartMap.put('isValid', isValid);

                    dataList.add(cartMap);

                }

            }


        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());
            System.debug(ex.getStackTraceString());

        }

        return dataList;
    }

    @AuraEnabled
    public static List<Map<String, Object>> fetchWishLists(String storefront, String userId, String locale) {

        System.debug('storefront: ' + storefront);
        System.debug('userId: ' + userId);

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = 'USD';
        ctx.portalUserId = userId;

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        Integer orderTot = 5;

        try {

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPIWishList.OWNER => userId
                    ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIWishList.INCLUDE_ITEMS => true
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIWishList.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L  // M to get lastModifiedDate, L to get subtotalAmount
                            }
                    }

                    // 2019-10-10  msobczak: added
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_M
                            }
                    }

            };

            Map<String, Object> outputFetchData = ccrz.ccAPIWishList.fetch(inputData);

            System.debug('outputData: ' + JSON.serialize(outputFetchData));

            List<Map<String, Object>> productList = new List<Map<String, Object>>();
            if(outputFetchData.containsKey('productList')) {
                productList = (List<Map<String, Object>>)outputFetchData.get('productList');
            }

            // 2019-10-10  msobczak: put the productList into a Map, key being the product SFID
            Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();

            for(Map<String, Object> productMap : productList) {
                String productSfid = (String)productMap.get('sfid');
                productsMap.put(productSfid, productMap);
            }

            System.debug('productList size = ' + productList.size());
            System.debug('productList = ');
            System.debug(productList);

            if (outputFetchData.get(ccrz.ccAPIWishList.WISHLISTS) != null) {

                /*
                    Some pre-processing here.  Wish lists are returned as properties of a Map, while carts are returned as a List.
                 */
                Map<String, Map<String, Object>> wishListsMap = (Map<String, Map<String, Object>>) outputFetchData.get(ccrz.ccAPIWishList.WISHLISTS);

                List<Map<String, Object>> cartList = new List<Map<String, Object>>();

                // for(String key : wishListsMap.keySet()) {
                //     Map<String, Object> wishListMap = wishListsMap.get(key);
                //     cartList.add(wishListMap);
                // }

                System.debug('prepare objects for sorting');

                List<SortObj> sortObjList = new List<SortObj>();
                for(String key : wishListsMap.keySet()) {
                    Map<String, Object> wishListMap = wishListsMap.get(key);

                    SortObj s = new SortObj();

                    s.cartMap = wishListMap;

                    Object createdDate = wishListMap.get('createdDate');

                    DateTime dt = null;

                    if(createdDate instanceof Datetime) {
                        dt = (Datetime)createdDate;
                    }
                    else {
                        String temp = (String) wishListMap.get('createdDate');
                        dt = DateTime.parse(temp);
                    }

                    s.createdDate = dt;

                    Object lastModified = wishListMap.get('lastModifiedDate');

                    if(lastModified instanceof Datetime) {
                        dt = (Datetime)lastModified;
                    }
                    else {
                        String temp = (String) wishListMap.get('lastModifiedDate');
                        dt = DateTime.parse(temp);
                    }

                    s.lastModified = dt;

                    sortObjList.add(s);
                }

                System.debug('sort the objects');

                sortObjList.sort();

                for(SortObj s : sortObjList) {
                    System.debug('createdDate: ' + s.createdDate);
                    cartList.add(s.cartMap);
                }

                for (Integer i = 0; i < orderTot; i++) {

                    Boolean isValid = true;

                    Map<String, Object> cartMap = (Map<String, Object>)cartList.get(i);
                    System.debug('cartMap: ' + JSON.serialize(cartMap));

                    if (cartMap.get('lastModifiedDate') != null) {

                        // 2019-01-09  msobczak: added logic to handle lastModifiedDate being returned in DateTime format.
                        System.debug('lastModifiedDate = ' + cartMap.get('lastModifiedDate'));

                        Object lastModifiedDate = cartMap.get('lastModifiedDate');

                        if(lastModifiedDate instanceof Datetime) {
                            cartMap.put('lastModifiedDateStr', ((Datetime)lastModifiedDate).format());
                        }
                        else {
                            Date orderItemDate = Date.valueOf((String) cartMap.get('lastModifiedDate'));
                            cartMap.put('lastModifiedDateStr', orderItemDate.format());
                        }

                    } else {
                        cartMap.put('lastModifiedDateStr', '');
                    }

                    List<Map<String, Object>> cartItemsList = new List<Map<String, Object>>();
                    if(cartMap.containsKey('ECartItemsS')) {
                        cartItemsList = (List<Map<String, Object>>)cartMap.get('ECartItemsS');
                    }

                    List<String> orderProducts = new List<String>();

                    for(Map<String, Object> cartItemMap : cartItemsList) {

                        // 2019-10-10  msobczak: add product media to each order item
                        String productSfid = (String)cartItemMap.get('product');

                        if(productsMap.containsKey(productSfid)) {

                            Map<String, Object> productMap = productsMap.get(productSfid);

                            cartItemMap.put('sku', productMap.get('SKU'));
                            cartItemMap.put('productName', productMap.get('sfdcName'));

                            List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');

                            for(Map<String, Object> productMedia : productMediaList) {
                                String mediaType = (String)productMedia.get('mediaType');

                                if(mediaType == 'Product Image Thumbnail') {
                                    cartItemMap.put('thumbnailImage', productMedia);
                                    break;
                                }
                            }
                        }

                    }

                    for(Map<String, Object> cartItemMap : cartItemsList) {
                        if(cartItemMap.containsKey('productName')) {
                            orderProducts.add((String)cartItemMap.get('productName'));
                        }
                        if(cartItemMap.containsKey('productType')) {
                            String productType = (String)cartItemMap.get('productType');
                            System.debug('productType = ' + productType);
                            if(productType != 'Product') {
                                isValid = false;
                            }
                        }
                    }

                    cartMap.put('cartItemsList', cartItemsList);
                    cartMap.put('isValid', isValid);

                    dataList.add(cartMap);

                }

            }


        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());
            System.debug(ex.getStackTraceString());

        }

        return dataList;
    }

    @AuraEnabled
    public static List<String> getStorefrontSet() {

        System.debug('inside getStorefrontSet()');

        Set<String> storefronts = new Set<String>();
        List<String> storefrontList = new List<String>();

        try {
            System.debug('getting configs');
            List<AggregateResult> configs = [SELECT ccrz__Storefront__c FROM ccrz__E_Configuration__c GROUP BY ccrz__Storefront__c];

            System.debug('looping through results');
            for (AggregateResult ag : configs) {
                String storefrontName = (String)ag.get('ccrz__Storefront__c');
                if(storefrontName != 'Global') {
                    storefronts.add(storefrontName);
                }
            }

            storefrontList.addAll(storefronts);

            System.debug('storefrontList.size = ' + storefrontList.size());
        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

        }

        System.debug('exit getStorefrontSet()');

        //storefrontList.add('DefaultStore');

        return storefrontList;
    }

    class SortObj implements Comparable {
        public DateTime createdDate;
        public DateTime lastModified;

        Map<String, Object> cartMap;

        public Integer compareTo(Object compareTo) {
            
            SortObj compareToObj = (SortObj)compareTo;
    
            if (lastModified == compareToObj.lastModified) return 0;
    
            if (lastModified > compareToObj.lastModified) return -1;
    
            return 1;
    
        }
            

    }

}