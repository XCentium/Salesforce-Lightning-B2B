global with sharing class ckz_OrderFormProductSearchController {

    @AuraEnabled
    public static Map<String, Object> findFilters(String userId, String accountId, String currencyCode, String storefront, String locale) {

        Map<String, Object> responseMap = new Map<String, Object>();

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

        responseMap.put('filterLoadSuccessful', true);

        try {

            // Use hard-coded category id
            Set<String> categoryIds = new Set<String>();
            //categoryIds.add('a533c000000Y76DAAS');

            // Retrieve ID for "All Products"
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccApiCategory.CATEGORYNAME => 'All Products'
            };

            Map<String, Object> outputData = ccrz.ccAPICategory.fetch(inputData);
            if (outputData.get(ccrz.ccAPICategory.CATEGORYLIST) != null) {

                List<Map<String, Object>> outputCategoryList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICategory.CATEGORYLIST);

                String categoryName = (String) outputCategoryList[0].get('sfdcName');
                System.debug('categoryName: ' + categoryName);
                String sfid = (String) outputCategoryList[0].get('sfid');
                categoryIds.add(sfid);
            }
            else {
                throw new CustomException ('All Products category not found');
            }

            Map<String, Object> inputData2 = new Map<String, Object>{
                    ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIProduct.CATEGORY_IDS => categoryIds

                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
                            }
                    }
            };

            Map<String, Object> outputSearchData = ccrz.ccAPIProduct.findFilters(inputData2);

            Boolean isSuccess = (Boolean)outputSearchData.get(ccrz.ccApi.SUCCESS);

            if(isSuccess) {
                List<Map<String, Object>> prodFilters = (List<Map<String, Object>>)outputSearchData.get('prodFilters');
                //responseMap.put('filters', prodFilters);
                responseMap.put('filters', outputSearchData);
            }
            else {
                throw new CustomException('Filters not returned');
            }
        }
        catch (CustomException e) {

            responseMap.put('filterLoadSuccessful', false);
            responseMap.put('filterLoadMsg', e.getMessage());
        }
        catch (Exception e) {

            responseMap.put('filterLoadSuccessful', false);
            responseMap.put('filterLoadMsg', e.getMessage());
        }

        return responseMap;

    }

    @AuraEnabled
    public static Map<String, Object> findProductsWithFilters(String userId, String accountId, String currencyCode, String storefront, String locale, String filterValuesJson) {

        Map<String, Object> responseMap = new Map<String, Object>();

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

        responseMap.put('findProductsSuccessful', true);

        try {

            // Use hard-coded category id
            Set<String> categoryIds = new Set<String>();

            // Retrieve ID for "All Products"
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccApiCategory.CATEGORYNAME => 'All Products'
            };

            Map<String, Object> outputData = ccrz.ccAPICategory.fetch(inputData);
            if (outputData.get(ccrz.ccAPICategory.CATEGORYLIST) != null) {

                List<Map<String, Object>> outputCategoryList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICategory.CATEGORYLIST);

                String categoryName = (String) outputCategoryList[0].get('sfdcName');
                System.debug('categoryName: ' + categoryName);
                String sfid = (String) outputCategoryList[0].get('sfid');
                categoryIds.add(sfid);
            }
            else {
                throw new CustomException ('All Products category not found');
            }

            System.debug('filterValuesJson: ' + filterValuesJson);

            List<Object> filterValues1 = (List<Object>)JSON.deserializeUntyped(filterValuesJson);

            System.debug('categoryIds: ' + categoryIds);


            System.debug('populating filterValues2...');

            List<Map<String, Object>> filterValues2 = new List<Map<String, Object>>();

            for(Object temp : filterValues1) {

                Map<String, Object> filterMap = (Map<String, Object>)temp;

                Map<String, Object> newFilterMap = new Map<String, Object>();

                newFilterMap.put('sfid', (String)filterMap.get('sfid'));

                List<Map<String, Object>> newSpecValues = new List<Map<String, Object>>();

                List<Object> specValues = (List<Object>)filterMap.get('specValues');

                for(Object temp2 : specValues) {

                    Map<String, Object> specValue = (Map<String, Object>)temp2;

                    Map<String, Object> newSpecValue = new Map<String, Object>();
                    newSpecValue.put('value', (String)specValue.get('value'));
                    newSpecValues.add(newSpecValue);
                }

                newFilterMap.put('specValues', newSpecValues);

                filterValues2.add(newFilterMap);
            }

            System.debug('filterValues2: ' + JSON.serialize(filterValues2));

            Map<String, Object> inputData2 = new Map<String, Object>{
                    ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIProduct.CATEGORY_IDS => categoryIds
                    ,ccrz.ccService.ORDERBY => ccrz.ccAPIProductIndex.BY_NAME
                    ,ccrz.ccAPIProduct.INCLUDE_COUNT => true
                    ,ccrz.ccAPIProduct.PRODUCT_LIMIT => 100
                    //,ccrz.ccAPIProduct.PRODUCT_FILTERS => filterValues2

            };

            if(filterValues2.size() > 0) {
                inputData2.put(ccrz.ccAPIProduct.PRODUCT_FILTERS, filterValues2);
            }

            System.debug('calling API');

            Map<String, Object> outputSearchData = ccrz.ccAPIProduct.find(inputData2);

            System.debug('back from API call');

            Boolean isSuccess = (Boolean)outputSearchData.get(ccrz.ccApi.SUCCESS);

            if(isSuccess) {

                System.debug('find call successful');

                if (outputSearchData.containsKey(ccrz.ccAPIProduct.PRODUCTLIST) != null) {

                    List<Object> productList = (List<Object>) outputSearchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                    System.debug('productList: ' + JSON.serialize(productList));
                    responseMap.put('productList', productList);

                }

            }
            else {

                System.debug('find call NOT successful');

                throw new CustomException('Products not returned');
            }
        }
        catch (CustomException e) {

            System.debug('Exception: ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());

            responseMap.put('findProductsSuccessful', false);
            responseMap.put('findProductsMsg', e.getMessage());
        }
        catch (Exception e) {

            System.debug('Exception: ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());

            responseMap.put('findProductsSuccessful', false);
            responseMap.put('findProductsMsg', e.getMessage());
        }

        return responseMap;

    }

    public class CustomException extends Exception {}

}