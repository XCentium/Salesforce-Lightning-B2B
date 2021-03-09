/*
   @Author: EDL Resource
   @Updated By: Accenture
   @Name: ckz_util_OrderBuilder
   @CreateDate: 11/11/2014
   @Description:ckz_util_OrderBuilder
   @Version: 1.0
 */

/* Utility class for orderbuilder*/
global with sharing class ckz_util_OrderBuilder {
    /* Required fields defined*/
    Set<Id> accountgroupIds = new Set<Id>();
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    Set<String>skuinorder = new Set<String>();
    List<String> brandCategory = new List<String>(); // Changed for Ensighten- Google Analytics
    List<String> listSkuord = new List<String>();
    String userLocale { get; set; }
    /*Default Constructor required for secondry controller */
    public ckz_util_OrderBuilder() {
    }

    public ccrz__E_Cart__c retrieveCurrentCart(String cartId) {

        ccrz__E_Cart__c currentCartData = new ccrz__E_Cart__c();
        try {
            if (!String.isBlank(cartId)) {

                currentCartData = [
                        select e.ccrz__EffectiveAccountId__c, (select ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c from ccrz__E_CartItems__r)
                        from ccrz__E_Cart__c e
                        where e.ccrz__EncryptedId__c = :cartId
                        limit 50000
                ];

            }
        } catch (Exception e) {
            System.debug('Exception in retrieveCurrentCart method of ckz_util_OrderBuilder');
        }

        return currentCartData;
    }

    /**
    *   Method that will retrieve cart items based on cartId
    *
    *   @Param: String cartId
    */
    public Map<String, Integer> retrieveCartItems(ccrz__E_Cart__c currentCartData) {

        Map<String, Integer> skusInCart = new Map<String, Integer>();
        List<ccrz__E_CartItem__c> cartItems = currentCartData.getSObjects('ccrz__E_CartItems__r');
        try {
            if (cartItems != null) {
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    skusInCart.put(cartItem.ccrz__Product__r.ccrz__SKU__c, (Integer) cartItem.ccrz__Quantity__c);

                }
            }
        } catch (Exception e) {
            System.debug(logginglevel.info, 'error' + e);
            System.debug('Exception in retrieveCartItems method of ckz_util_OrderBuilder.' + e);
        }
        return skusInCart;
    }

    public List<ckz_bean_Order> retrieveOrders(Integer numOfOrders, ccrz__E_Cart__c currentCartData) {
        return retrieveOrders(numOfOrders, null, currentCartData);
    }

    /**
    *   Method that will retrieve the past orders for the user based on the number of orders returned.
    *   It will also determine the quantity of the skus in the order that are in the current cart and save that to the bean
    *
    *   @Param: String userId
    *   @Param: String cartId
    *   @Param: Map skusInCart
    */


    public List<ckz_bean_Order> retrieveOrders(Integer numOfOrders, String storefront, ccrz__E_Cart__c currentCartData) {
        String effectiveAccountId = currentCartData.ccrz__EffectiveAccountId__c;
        userLocale = UserInfo.getLocale();//Last Delivery, Order Builder month display in french

        List<ckz_bean_Order> orders = new List<ckz_bean_Order>();
        //try{

        Set<String> discontinuedSku = New Set<String>();
        /*for (Customer_Product_Exclusion__c cp :
            [select Id,Account__c,Products__r.SKUId__c
             from Customer_Product_Exclusion__c
             where Account__c =: effectiveAccountId
            and Discontinued_by_Customer__c = true]) {

            discontinuedSku.add(cp.Products__r.SKUId__c);

        }*/

  List<ccrz__E_Order__c> lastOrderData = [
                SELECT e.ccrz__OrderDate__c, e.ccrz__OrderID__c, e.Name, e.Id, e.ccrz__OrderStatus__c, e.ccrz__RequestDate__c,
                        e.ccrz__OriginatedCart__r.ccrz__EffectiveAccountId__c,e.ccrz__User__r.LocaleSidKey,
                        e.ccrz__EffectiveAccountId__c, (
                        SELECT Name, ccrz__Order__c, ccrz__ProductType__c, ccrz__OrderItemID__c, ccrz__Price__c,
                                ccrz__Quantity__c, ccrz__Product__r.name, ccrz__Product__r.ccrz__SKU__c,
                                ccrz__Product__r.ccrz__EndDate__c, //fetching end date of product
                                //ccrz__Product__r.TradeMark__c,
                                ccrz__Product__r.ccrz__Quantityperunit__c, ccrz__Product__r.ccrz__UnitOfMeasure__c,
                                ccrz__Product__r.ccrz__InventoryType__c, ccrz__OrderItemStatus__c
                        From ccrz__E_OrderItems__r
                        WHERE ccrz__Product__r.ccrz__ProductType__c = 'Product'
                        AND ccrz__Product__r.ccrz__ProductStatus__c = 'Released'
                        //AND  ccrz__Product__r.ImpliedArticles__c= false
                        limit 50000
                ) //Added product status condition to be released only.. as a part of Feb16 release
                FROM ccrz__E_Order__c e
                WHERE e.ccrz__EffectiveAccountId__c = :effectiveAccountId
                //AND ccrz__OrderStatus__c = 'Shipped'
                AND ccrz__Storefront__c = :storefront
                ORDER BY e.ccrz__OrderDate__c DESC
                LIMIT :numOfOrders
        ];


        //list<ckz_bean_OrderItem> lstOrde = new list<ckz_bean_OrderItem>();
        List<ccrz__E_OrderItem__c> orderItemsPPrd = new list<ccrz__E_OrderItem__c>();
        set<string> prdSku = new set<string>();
        for (ccrz__E_Order__c order : lastOrderData) {
            orderItemsPPrd = order.getSObjects('ccrz__E_OrderItems__r');
            accountgroupIds.add(order.ccrz__EffectiveAccountId__c);
            if (orderItemsPPrd != null) {
                for (ccrz__E_OrderItem__c orderItemPrd : orderItemsPPrd) {
                    prdSku.add(orderItemPrd.ccrz__Product__r.ccrz__SKU__c);
                }
            }

        }
        map<string, string> mapPrd18N = new map<string, string>();
        list<ccrz__E_ProductItemI18N__c> lstPrd18N = [select id, name,ccrz__Locale__c,ccrz__SKU__c from ccrz__E_ProductItemI18N__c where ccrz__SKU__c IN :prdSku and ccrz__Locale__c like 'fr%'];

        if (lstPrd18N.size() > 0) {
            for (ccrz__E_ProductItemI18N__c p18N : lstPrd18N) {

                mapPrd18N.put(p18N.ccrz__SKU__c, p18N.name);

            }
        }

        List<Account> lstAccGrp = [
                select Id,
                        //Bottler_Name__c,
                        ccrz__E_AccountGroup__r.ccrz__AccountGroupID__c
                //,Sales_Method__c
                from Account
                where Id IN :accountgroupIds
        ];
        System.debug('-----------lstAccGrp=' + lstAccGrp);

        set<string> setAccGtp = new set<string>();
        for (Account acc : lstAccGrp) {
            setAccGtp.add(acc.ccrz__E_AccountGroup__r.ccrz__AccountGroupID__c);
            mapAccount.put(acc.Id, acc);
        }
        System.debug('-----------mapAccount=' + mapAccount);
        List<ccrz__E_AccountGroupPriceList__c> lstAccGrpPr = [select ccrz__Pricelist__r.name from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__r.ccrz__AccountGroupID__c IN :setAccGtp and ccrz__Enable__c = true and ccrz__EndDate__c >= :system.today()];
        set<string> priceList = new set<string>();
        for (ccrz__E_AccountGroupPriceList__c accGrpLst : lstAccGrpPr) {
            priceList.add(accGrpLst.ccrz__Pricelist__r.name);
        }
        System.debug('-----------priceList=' + priceList);

        map<string, ccrz__E_PriceListItem__c> mapExpPriceList = new map<string, ccrz__E_PriceListItem__c>();
        map<string, ccrz__E_PriceListItem__c> mapBlockPriceList = new map<string, ccrz__E_PriceListItem__c>();

        list<ccrz__E_PriceListItem__c> lstPriceListItem = [
                select Id,ccrz__Product__r.ccrz__SKU__c,
                        //ProductBlocked__c,SalesMethod__c,
                        ccrz__EndDate__c
                from ccrz__E_PriceListItem__c
                where ccrz__Pricelist__r.name IN :priceList and ccrz__Product__r.ccrz__SKU__c IN :prdSku
        ];
        System.debug('-----------lstPriceListItem=' + lstPriceListItem);
        //ckz_ProductBlockedHelper cls = new ckz_ProductBlockedHelper();

        for (ccrz__E_PriceListItem__c prList : lstPriceListItem) {
            System.debug('-----------prList' + prList.Id);
            System.debug('-----------prList.ccrz__EndDate__c=' + prList.ccrz__EndDate__c);
            //System.debug('-----------prList.ccrz__EndDate__c2='+cls.isthisProductBlocked(prList.ProductBlocked__c, prList.SalesMethod__c, mapAccount.get(effectiveAccountId).Sales_Method__c));
            if (prList.ccrz__EndDate__c < system.today()) {
                mapExpPriceList.put(prList.ccrz__Product__r.ccrz__SKU__c, prList);
            }

            /*if (cls.isthisProductBlocked(prList.ProductBlocked__c, prList.SalesMethod__c, mapAccount.get(effectiveAccountId).Sales_Method__c)) {
                mapBlockPriceList.put(prList.ccrz__Product__r.ccrz__SKU__c, prList);
            }*/


        }




        if (lastOrderData.size() > 0) {
            // Loop through each order
            for (ccrz__E_Order__c order : lastOrderData) {
                // Create delivery date

                //todo:uzia fix this
                //DateTime deliveryDate = DateTime.newInstance(order.ccrz__RequestDate__c.year(), order.ccrz__RequestDate__c.month(), order.ccrz__RequestDate__c.day());

 				//DateTime deliveryDate = System.now();
                Datetime deliveryDate = DateTime.newInstance(order.ccrz__OrderDate__c.year(), order.ccrz__OrderDate__c.month(), order.ccrz__OrderDate__c.day());
                //String deliveryDateLong = deliveryDate.format('MMMM dd, yyyy');
                String deliveryDateLong = deliveryDate.format('yyyy');
                String deliveryDateMonth = deliveryDate.format('MMM');
                String deliveryDateDay = deliveryDate.format('dd');
                //Last Delivery, Order Builder month display in french --- start

                /*todo:uzia fix this
                ccrz__E_PageLabel__c datePageLabel =[Select Id from ccrz__E_PageLabel__c where Name='deliveryDateMonths' LIMIT 1];
                String datePageLabelLangen = [SELECT ccrz__Value__c FROM ccrz__E_PageLabel__c where Name='deliveryDateMonths' LIMIT 1].ccrz__Value__c;
                String datePageLabelLangfr = [SELECT ccrz__Value__c FROM ccrz__E_PageLabeli18n__c where ccrz__PageLabel__c =: datePageLabel.Id and ccrz__Language__c = 'fr'].ccrz__Value__c;
               //Change For GLCC
               string[] datePageLabelLangfrVal =Null;
               string[] datePageLabelLangenVal=Null;
               if(String.isNotBlank(datePageLabelLangfr)){
                datePageLabelLangfrVal = datePageLabelLangfr.split(',');
                }
                if(String.isNotBlank(datePageLabelLangen)){
                datePageLabelLangenVal = datePageLabelLangen.split(',');
                }//End For GLCC
                map<string,string> langTrans = new map<string,string>();
                for(integer i=0;i<datePageLabelLangenVal.size();i++){
                    langTrans.put(datePageLabelLangenVal[i], datePageLabelLangfrVal[i]);
                }
                if(userLocale.containsIgnoreCase('fr')){
                    deliveryDateMonth = langTrans.get(deliveryDateMonth);
                }*/

                //Last Delivery, Order Builder month display in french --- end
                // Get list of items associated with the current order
                List<ckz_bean_OrderItem> orderItemList = new List<ckz_bean_OrderItem>();
                List<ccrz__E_OrderItem__c> orderItems = order.getSObjects('ccrz__E_OrderItems__r');
                list<ckz_bean_OrderItem> lstOrde = new list<ckz_bean_OrderItem>();
                List<String> productIds = new List<String>();
                List<string> listSkuord = new List<string>();
                Integer quantityInCart = 0;

                If (orderItems != null) {

                    // Loop through orderItems to build list of product ids to retrieve product media map
                    for (ccrz__E_OrderItem__c orderItem : orderItems) {
                        // capture Ids for the images
                        productIds.add(orderItem.ccrz__Product__r.Id);
                        listSkuord.add(orderItem.ccrz__Product__r.ccrz__SKU__c);
                    }
                }

                // Get instance of media utility
                ckz_util_Media mediaUtil = new ckz_util_Media('Outlet');

                // Get images and add them to the bean
                Map<Id, ckz_bean_MediaWrapper> productMediaMap = mediaUtil.getProductMedia(productIds, 'Product Image Thumbnail', 'en_US');

                //Map<Id, ckz_bean_MediaWrapper> productMediaMap = new Map<Id, ckz_bean_MediaWrapper>();
                String locale = 'en_US';
                if (userInfo.getLocale().containsIgnoreCase('fr')) {
                    locale = 'fr_CA';
                    productMediaMap = mediaUtil.getProductMedia(productIds, 'Product Image Thumbnail', 'fr');
                } else {
                    productMediaMap = mediaUtil.getProductMedia(productIds, 'Product Image Thumbnail', 'en_US');
                }
                Map<String, Integer> skusInCart = retrieveCartItems(currentCartData);
                if (userLocale.containsIgnoreCase('fr'))
                    userLocale = 'fr_CA'; else
                        userLocale = 'Eng';

                if (orderItems != null) {
                    // Loop through items and extract info needed to populate a list of items attached to current order

                    ckz_ctrl_LastOrder orderBuildIns = new ckz_ctrl_LastOrder();
                    map<string, Map<String, String>> mapsku = orderBuildIns.findMapBrandCategory1(listSkuord);
                    for (ccrz__E_OrderItem__c orderItem : orderItems) {
                        // Track items that are currently in the cart and those that were placed in the current order
                        brandCategory = new LIST<String>(); // Changed for Ensighten- Google Analytics
                        if (skusInCart.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)) {
                            quantityInCart = skusInCart.get(orderItem.ccrz__Product__r.ccrz__SKU__c);

                        }
                        string strPrdName = '';
                        string strUOM = '';
                        string strInventory = '';
                        if (userInfo.getLocale().containsIgnoreCase('fr') && !mapPrd18N.isEmpty()) {
                            strPrdName = mapPrd18N.get(orderItem.ccrz__Product__r.ccrz__SKU__c);
                            strUOM = orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c;
                        } else {
                            strPrdName = orderItem.ccrz__Product__r.name;
                            strUOM = orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c;
                        }

                        boolean expProduct = false;
                        boolean blockedProduct = false;
                        if (mapExpPriceList.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)) { //added for endated products in salesforce in orderbuilder and lastorder
                            expProduct = true;
                        } if (mapBlockPriceList.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)) { //added for endated products in salesforce in orderbuilder and lastorder
                            blockedProduct = true;
                        }
                        System.debug('---------expProduct=' + expProduct);
                        System.debug('---------blockedProduct=' + blockedProduct);
                        System.debug('---------discontinuedSku=' + discontinuedSku);
                        if (!discontinuedSku.contains(orderItem.ccrz__Product__r.ccrz__SKU__c) && !String.isBlank(orderItem.ccrz__Product__r.ccrz__SKU__c)) {

                            string brandValue = '';
                            string catergoryValue = '';
                            map<string, string> locMap = mapsku.get(orderItem.ccrz__Product__r.ccrz__SKU__c);

                            if (locMap != null) {
                                for (string key : locMap.keySet()) {
                                    if (key.contains('Brand')) {
                                        brandValue = locMap.get(key);
                                    }
                                    if (key.contains('Category')) {
                                        catergoryValue = locMap.get(key);
                                    }
                                }
                            }

                            lstOrde.add(new ckz_bean_OrderItem(orderItem.ccrz__Product__r.Id,
                                    strPrdName,
                                    orderItem.ccrz__Product__r.ccrz__SKU__c,
                                    orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c,
                                    (Integer) orderItem.ccrz__Product__r.ccrz__Quantityperunit__c,
                                    orderItem.ccrz__Product__r.ccrz__InventoryType__c,
                                    (Integer) orderItem.ccrz__Quantity__c, quantityInCart,
                                    productMediaMap.get(orderItem.ccrz__Product__r.Id),
                                    orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c,
                                    null,//orderItem.ccrz__Product__r.TradeMark__c, //Changing to Name Kapil.
                                    orderItem.ccrz__Product__r.ccrz__EndDate__c, expProduct, userLocale, blockedProduct, brandValue, catergoryValue));// Changed for Ensighten- Google Analytics
                            quantityInCart = 0;
                        }
                    }
                    orderItemList.addAll(lstOrde);//end of endated products in orderbuilder and lastorder

                }


                // Construct order object and add it to the list of orders
                orders.add(new ckz_bean_Order(deliveryDateLong, deliveryDateMonth, deliveryDateDay, deliveryDate, orderItemList));
                system.debug('Orderpassed===> ' + orders);

            }
        } else {
            System.debug('No orders were returned');
        }

        /*}
        catch(Exception e){
            System.debug('Exception in retrieveOrders method of ckz_util_OrderBuilder' + e);
        }*/
        return orders;
    }

    /**
    *   Method that will build a map of unique order items within a list of orders
    *
    *   @param List<ckz_bean_Order> orders
    */
    public Map<String, ckz_bean_OrderItem> buildUniqueOrderItemMap(List<ckz_bean_Order> orders) {
        Map<String, ckz_bean_OrderItem> uniqueOrderItemMap = new Map<String, ckz_bean_OrderItem>();

        // Loop through orders to build a list of unique order items
        for (ckz_bean_Order order : orders) {
            // Loop through each order item of the current order
            for (ckz_bean_OrderItem orderItem : order.orderItems) {
                String sku = orderItem.productSKU;

                // If the orderItem is already in the map don't add it
                if (!uniqueOrderItemMap.containsKey(sku)) {
                    // add the order item to the map
                    uniqueOrderItemMap.put(sku, orderItem);
                }
            }
        }


        return uniqueOrderItemMap;
    }

    /**
    *   Method that will build a list of OrderBuilderMap beans, which maps the orders to the uniquOrderItem
    *
    *   @param Map<String, ckz_bean_OrderItem> uniqueOrderItemMap
    *   @param List<ckz_bean_Order> orders
    */
    public List<ckz_bean_OrderBuilderMap> buildOrderBuilderMapList(Map<String, ckz_bean_OrderItem> uniqueOrderItemMap, List<ckz_bean_Order> orders) {
        List<ckz_bean_OrderBuilderMap> orderBuilderMapList = new List<ckz_bean_OrderBuilderMap>();

        // Loop through each unique order item
        for (String sku : uniqueOrderItemMap.keySet()) {
            List<Integer> quantities = new List<Integer>();

            // Loop through the orders to find the quantity of each unique order item
            for (ckz_bean_Order order : orders) {
                Integer qty = 0;

                // Loop through the order items
                for (ckz_bean_OrderItem currentItem : order.orderItems) {

                    if (currentItem.productSKU.equals(sku)) {

                        // Get the quantity of this item for the current order
                        qty = currentItem.quantity + qty;
                    }

                }

                // Add the quantity of unique item to list
                quantities.add(qty);
            }


            // Build the list of unique order items and the associated quantities for each order
            orderBuilderMapList.add(new ckz_bean_OrderBuilderMap(uniqueOrderItemMap.get(sku), quantities));

        }
        return orderBuilderMapList;
    }
}