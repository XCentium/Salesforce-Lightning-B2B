/**
 * Created by brandon.rogers on 2019-07-25.
 */

global with sharing class ckz_ctrl_ForecastedOrderingGrid {

    global String allSKUsJSON { get; set; }

    @RemoteAction
    global static List<String> fetchProductSKUs(ccrz.cc_RemoteActionContext ctx, String searchString) {
        System.debug('ckz_ctrl_ForecastedOrderingGrid: fetchProductSKUs');

        ccrz.cc_CallContext.initRemoteContext(ctx);
        System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: ctx: ' + ctx);

        System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: searchString: ' + searchString);

        List<String> dataList = new List<String>();

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccService.SEARCHSTRING => searchString
        };

        try {
            Map<String, Object> outputSearchData = ccrz.ccAPIProduct.search(inputData);

            System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: outputSearchData: ' + outputSearchData);

            Set<String> searchIdSet = null;

            if (outputSearchData.get(ccrz.ccService.SEARCHRESULTS) != null) {
                searchIdSet = (Set<String>) outputSearchData.get(ccrz.ccService.SEARCHRESULTS);

                System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: searchIdSet: ' + searchIdSet);
            }

            Map<String, Object> fetchInputData = new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTIDLIST => searchIdSet,
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
                    ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                            }
                    }
            };

            try {
                Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(fetchInputData);

                System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: outputFetchData:');
                System.debug(JSON.serialize(outputFetchData));

                Boolean success = (Boolean) outputFetchData.get(ccrz.ccApi.SUCCESS);

                System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: product fetch success = ' + success);

                if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {
                    // The cast to List<Map<String, Object>> is necessary...
                    List<Map<String, Object>> outputProductList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                    // The cast, again, is necessary...
                    for (Map<String, Object> outputProductMap : outputProductList) {

                        Map<String, Object> productMap = new Map<String, Object>();
                        String productName = (String) outputProductMap.get('sfdcName');

                        System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: productName: ' + productName);

                        String productType = (String) outputProductMap.get('productType');

                        if (productType == 'Product') {
                            String sku = (String) outputProductMap.get('SKU');

                            dataList.add(sku);
                        }
                    }
                } else {
                    System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: product list retrieved is null');
                }
            } catch (Exception e) {
                // Error handling...
                System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: error message: ' + e.getMessage());
                System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: line number: ' + e.getLineNumber());
            }

        } catch (Exception e) {
            // Error handling...
            System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: error message: ' + e.getMessage());
            System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: line number: ' + e.getLineNumber());
        }

        // allSKUsJSON = JSON.serialize(dataList);

        System.debug('ckz_ctrl_ForecastedOrderingGrid:fetchProductSKUs: dataList: ' + dataList);

        return dataList;
    }


    /*global void getAvailableProducts() {
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getAvailableProducts');

        String storefront = ccrz.cc_CallContext.storefront;
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getAvailableProducts:storefront', storefront);

        Map<String, String> pageParams = ccrz.cc_CallContext.currPageParameters;
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getAvailableProducts:pageParams', pageParams);

        Account a = ccrz.cc_CallContext.currAccount;
        if (a == null) a = ccrz.cc_CallContext.effAccount;
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getAvailableProducts:Account', a);

        // GET ACCOUNT GROUP PRICE LISTS
        List<ccrz__E_AccountGroupPriceList__c> accountGroupPriceLists = [
                SELECT  Id,
                        ccrz__Pricelist__c
                FROM    ccrz__E_AccountGroupPriceList__c
                WHERE   ccrz__AccountGroup__c = :a.ccrz__E_AccountGroup__c
                AND     ccrz__Enable__c = TRUE
                AND     ccrz__StartDate__c <= TODAY
                AND     ccrz__EndDate__c >= TODAY
        ];
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getSKUs:accountGroupPriceLists: ' + accountGroupPriceLists);

        // GET PRICE LISTS FROM ACCOUNT GROUP PRICE LISTS ???
        *//*List<ccrz__E_PriceList__c> priceLists = [
                SELECT  Id,
                        (SELECT Id FROM ccrz__E_AccountGroupPriceLists__r)
                FROM    ccrz__E_PriceList__c
                WHERE   ccrz__E_AccountGroupPriceLists__r IN :accountGroupPriceLists
        ];*//*
//        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getSKUs:priceLists: ' + priceLists);

        // SELECT SKU FROM Products WHERE Product Price List Item IN Price list AND Price List IN Account Group Price List ???
        List<ccrz__E_Product__c> availableProducts;

        *//*availableProducts = [
                SELECT ccrz__SKU__c
                FROM ccrz__E_Product__c
                WHERE ccrz__E_Product__r.ccrz__E_PriceListItem__c

        ];*//*

        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getSKUs:availableProducts: ' + availableProducts);

        allSKUsJSON = JSON.serialize(availableProducts);
        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:getSKUs:allSKUsJSON: ' + allSKUsJSON);
    }*/

}