/**
 * Created by msobczak on 11/1/2018.
 */

global with sharing class ckz_OrderItemsProductController {

    @AuraEnabled
    public static List<Map<String, Object>> fetchProductSuggestions(String userId, String accountId, String currencyCode, String storefront, String locale, String searchString) {

        System.debug('inside fetchProduct');

        System.debug('userId: ' + userId);
        System.debug('accountId: ' + accountId);
        System.debug('currencyCode: ' + currencyCode);
        System.debug('storefront: ' + storefront);
        System.debug('locale: ' + locale);
        System.debug('searchString: ' + searchString);

        // See if the storefront uses LLI
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

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                ,ccrz.ccAPIProduct.PRODUCTSTOREFRONT => storefront
                ,ccrz.ccAPIProduct.PRODUCTLOCALE => locale
                ,ccrz.ccService.SEARCHSTRING => searchString
        };

        try {
            Map<String, Object> outputSearchData = ccrz.ccAPIProduct.search(inputData);

            System.debug('outputSearchData: ' + outputSearchData);

            Set<String> searchIdSet = null;

            if (outputSearchData.get(ccrz.ccService.SEARCHRESULTS) != null) {
                searchIdSet = (Set<String>) outputSearchData.get(ccrz.ccService.SEARCHRESULTS);

                System.debug('searchIdSet: ' + searchIdSet);
            }
            
            Map<String, Object> fetchInputData = new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTIDLIST => searchIdSet
                    ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true
                    ,ccrz.ccAPIProduct.PRODUCTSTOREFRONT => storefront
                    ,ccrz.ccAPIProduct.PRODUCTLOCALE => locale
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_M
                            }
                    }
            };

            try {
                Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(fetchInputData);

                System.debug('outputFetchData:');
                System.debug(JSON.serialize(outputFetchData));

                Boolean success = (Boolean)outputFetchData.get(ccrz.ccApi.SUCCESS);

                System.debug('product fetch success = ' + success);

                if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {

                    List<Map<String, Object>> productList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                    for(Map<String, Object> productMap : productList) {

                        Map<String, Object> productsMap = new Map<String, Object>();
                        String productName = (String) productMap.get('sfdcName');

                        System.debug('productName: ' + productName);

                        String productType = (String) productMap.get('productType');

                        if (productType == 'Product') {

                            productMap.put('productName', productName);
                            productMap.put('sfid', (String) productMap.get('sfid'));
                            productMap.put('price', (Decimal) productMap.get('price'));
                            productMap.put('sku', (String) productMap.get('SKU'));
                            //productMap.put('productStatus', outputProductMap.get('productStatus'));

                            // 2019-10-10  msobczak: add product media to each order item

                            List<Map<String, Object>> productMediaList = (List<Map<String, Object>>)productMap.get('EProductMediasS');
                            //orderItemMap.put('EProductMediasS', productMediaList);

                            for(Map<String, Object> productMedia : productMediaList) {
                                String mediaType = (String)productMedia.get('mediaType');

                                if(mediaType == 'Product Image Thumbnail') {
                                    productMap.put('thumbnailImage', productMedia);
                                    break;
                                }
                            }

                            dataList.add(productMap);

                        }
                    }
                }
                else {
                    System.debug('product list retrieved is null');
                }
            } catch (Exception e) {
                // Error handling...
                System.debug('error message: ' + e.getMessage());
                System.debug('line number: ' + e.getLineNumber());
            }

        } catch (Exception e) {
            // Error handling...
            System.debug('error message: ' + e.getMessage());
            System.debug('line number: ' + e.getLineNumber());
        }

        return dataList;
    }

    /*
        Following is no longer used.
     */
    @AuraEnabled
    public static Map<String, Object> fetchProduct(String storefront, String locale, String searchString) {

        System.debug('inside fetchProduct');

        System.debug('storefront: ' + storefront);
        System.debug('locale: ' + locale);
        System.debug('searchString: ' + searchString);

//        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
//        ctx.storefront = storefront;
//        ctx.userLocale = locale;
//        ctx.userIsoCode = 'USD';
//
//        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Map<String, Object> dataMap = new Map<String, Object>();

        Map<String, Object> inputData = new Map<String, Object>{
                //ccrz.ccAPI.API_VERSION => 8,
                ccrz.ccAPI.API_VERSION => 7,
                ccrz.ccAPIProduct.PRODUCTSTOREFRONT => storefront,
                ccrz.ccAPIProduct.PRODUCTLOCALE => locale,
                ccrz.ccService.SEARCHSTRING => searchString
        };

        try {
            Map<String, Object> outputSearchData = ccrz.ccAPIProduct.search(inputData);

            System.debug('outputSearchData: ' + outputSearchData);

            if (outputSearchData.get('searchResults') != null) {
                // The cast to Set<String> is necessary...
                //Set<String> searchIdSet = (Set<String>) outputSearchData.get(ccrz.ccService.QUERYRESULTS);
                Set<String> searchIdSet = (Set<String>) outputSearchData.get('searchResults');

                System.debug('searchIdSet: ' + searchIdSet);

                // Call search with the set?
                Map<String, Object> fetchInputData = new Map<String, Object>{
                        ccrz.ccAPIProduct.PRODUCTIDLIST => searchIdSet
                        ,ccrz.ccAPI.API_VERSION => 6
                        //,ccrz.ccApi.SIZING => ccrz.ccAPI.SZ_M
                        ,ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true

                        ,ccrz.ccApi.SIZING => new Map<String, Object>{
                                ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S
                                }
                        }
                };

                try {
                    Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(inputData);

                    System.debug('outputFetchData: ' + outputFetchData);

                    for(String key : outputFetchData.keySet()) {
                        System.debug('key: ' + key);
                    }

                    if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {
                        // The cast to List<Map<String, Object>> is necessary...
                        List<Map<String, Object>> outputProductList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                        // The cast, again, is necessary...

                        String productName = (String) outputProductList[0].get('sfdcName');

                        System.debug('productName: ' + productName);

                        String productStatus = (String) outputProductList[0].get('productStatus');
                        String productType = (String) outputProductList[0].get('productType');

                        if((productStatus == 'Released' || productStatus == 'Not Orderable') &&
                                (productType == 'Product')) {

                            dataMap.put('productName', productName);
                            dataMap.put('sfid', (String) outputProductList[0].get('sfid'));
                            dataMap.put('price', (Decimal) outputProductList[0].get('price'));
                            dataMap.put('sku', (String) outputProductList[0].get('SKU'));
                            dataMap.put('productStatus', (String) outputProductList[0].get('productStatus'));

                            dataMap.put('outputProduct', outputProductList[0]);

                        }
                    }
                } catch (Exception e) {
                    // Error handling...
                    System.debug('error message: ' + e.getMessage());
                    System.debug('line number: ' + e.getLineNumber());
                }
            }
        } catch (Exception e) {
            // Error handling...
            System.debug('error message: ' + e.getMessage());
            System.debug('line number: ' + e.getLineNumber());
        }

        System.debug('dataMap: ' + dataMap);
        return dataMap;
    }

}