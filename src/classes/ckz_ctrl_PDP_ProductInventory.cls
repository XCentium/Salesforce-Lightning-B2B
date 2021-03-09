/**
 * Created by brandon.rogers on 3/11/20.
 */

global with sharing class ckz_ctrl_PDP_ProductInventory {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getInventory(ccrz.cc_RemoteActionContext ctx, List<String> skuList, String idx) {

        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'getInventory');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'skuList: ' + skuList);
        System.debug('skuList: ' + skuList);

        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = false;
        result.inputContext = ctx;

        List<ccrz.cc_bean_Message> messages = new List<ccrz.cc_bean_Message>();

        try {

            Map<String, Object> resultMap = fetchProductPricing(skuList, ctx.storefront, ctx.userLocale);

            if (resultMap.size() > 0) {

                ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'getInventory: successful');

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message('Account update successful', ccrz.cc_bean_Message.MessageSeverity.INFO);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'error_update_contact';
                messages.add(msg);

                result.data = resultMap;
                resultMap.put('sku', skuList);
                resultMap.put('idx', idx);

                result.success = true;
            } else {

                System.debug('getInventory: account not found');
                ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'getInventory: inventory not found');

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message('Account not found', ccrz.cc_bean_Message.MessageSeverity.ERROR);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'error_update_contact';
                messages.add(msg);

            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR', e);

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(e.getMessage(), ccrz.cc_bean_Message.MessageSeverity.ERROR);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'error_update_contact';
            messages.add(msg);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'getInventory');
            ccrz.ccLog.close(result);
        }

        result.messages.addAll(messages);

        return result;

    }

    /*
        Gets the current price for all products retrieved from the selected order.
        The price on the order items is the price when the order was placed.
     */
    private static Map<String, Object> fetchProductPricing(List<String> skuList, String storefront, String locale) {

        System.debug('---- begin fetchProductPricing');

        Map<String, Object> resultMap = new Map<String, Object>();

        Set<String> searchIdSet = new Set<String>();

        searchIdSet.addAll(skuList);

        System.debug('searchIdSet: ' + searchIdSet);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccAPIProduct.PRODUCTSKULIST => searchIdSet
                //,ccrz.ccAPI.API_VERSION => 7
                , ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                , ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => false
                , ccrz.ccApiProduct.PRODUCTSTOREFRONT => storefront
                , ccrz.ccApiProduct.PRODUCTLOCALE => locale
                , ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
                        }
                }
        };

        try {
            Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(fetchInputData);

            System.debug('outputFetchData:');
            System.debug(JSON.serialize(outputFetchData));

            // for (String key : outputFetchData.keySet()) {
            //     System.debug('key = ' + key + ' > ' + outputFetchData.get(key));
            // }

            if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {

                List<Map<String, Object>> outputProductList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                for (Map<String, Object> outputProductMap : outputProductList) {

                    Map<String, Object> productMap = new Map<String, Object>();
                    String productName = (String) outputProductMap.get('sfdcName');
                    String productSku = (String) outputProductMap.get('SKU');

                    System.debug('product: ' + productSku + ' - ' + productName);
                    ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'product: ' + productSku + ' - ' + productName);

                    String productType = (String) outputProductMap.get('productType');

                    String fetchProductSfid = (String) outputProductMap.get('sfid');

                    List<Map<String, Object>> inventoryList = null;

                    if (outputProductMap.containsKey('productInventoryItemsS')) {
                        System.debug('inventory found');

                        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'productInventoryItemsS: ' + outputProductMap.get('productInventoryItemsS'));

                        inventoryList = (List<Map<String, Object>>) outputProductMap.get('productInventoryItemsS');

                        for (Map<String, Object> invObj : inventoryList) {
                            Date expShipDate = (Date) invObj.get('expectedShipDate');

                            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'expShipDate: ' + expShipDate);

                            if (expShipDate != null) {
                                //DateTime dt = DateTime.newInstance(expShipDate);

                                //String fmt = dt.format('yyyy-MM-dd');
                                String fmt = expShipDate.format();

                                ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_PDP_ProductInventory', 'fmt: ' + fmt);

                                invObj.put('expectedShipDateFmt', fmt);
                            } else {
                                invObj.put('expectedShipDateFmt', '');
                            }
                        }

                    } else {
                        System.debug('inventory not found');
                    }

                    resultMap.put(productSku, inventoryList);

                }
            } else {
                System.debug('product list was null');
            }
        } catch (Exception e) {
            // Error handling...

            System.debug('error message: ' + e.getMessage());
            System.debug('line number: ' + e.getLineNumber());

            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ckz_ctrl_PDP_ProductInventory', 'Exception: ' + e.getMessage());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ckz_ctrl_PDP_ProductInventory', 'Line: ' + e.getLineNumber());
        }

        System.debug('---- exit fetchProductPricing');

        System.debug('resultMap: ' + resultMap);

        return resultMap;

    }

}