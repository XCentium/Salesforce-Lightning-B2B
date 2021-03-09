/**
 * Created by brandon.rogers on 9/4/18.
 */

global class cc_ctrl_CartUpload {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult parseCSV(final ccrz.cc_RemoteActionContext ctx, String csvBlob, boolean newCart) {
        String csv;
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult resp = new ccrz.cc_RemoteActionResult();
        resp.success = true;

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try {
            List<String> skus = new List<String>();
            Map<String, String> prodMap = new Map<String, String>();
            Map<String, Object> newMap = new Map<String, Object>();
            List<ccrz.ccApiCart.LineData> linesToAdd = new List<ccrz.ccApiCart.LineData>();

            List<String> lines = csvBlob.split('\n');
            boolean isFirst = true;
            String sku;
            Integer qty;
            String couponCode;
            boolean hasCoupon = false;

            String storefront = ctx.storefront;
            String locale = ctx.userLocale;

            List<ccrz.cc_bean_Message> verifySkusMessages = verifySkus(storefront, locale, lines);

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:parseCSV', 'verifySkusMessages size = ' + verifySkusMessages.size());

            if(verifySkusMessages.size() == 0) {
                List<ccrz.cc_bean_Message> importMessages = importData(ctx, csvBlob, newCart, lines, resp);
                retMessages.addAll(importMessages);
            }
            else {
                retMessages.addAll(verifySkusMessages);
            }


        } catch (Exception err) {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'EXCEPTION: ' + err.getMessage() + err.getStackTraceString());
        } finally {
            ccrz.ccLog.close(resp);
            resp.messages.addAll(retMessages);
        }


        return resp;
    }

    private static List<ccrz.cc_bean_Message> verifySkus(String storefront, String locale, List<String> lines) {

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        Set<String> skus = new Set<String>();
        Set<String> skusFound = new Set<String>();

        boolean isFirst = true;

        for (String singleLine : lines) {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'Parsing line' + singleLine);
            if (!isFirst) {
                List<String> values = singleLine.split(',');
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'values-----' + values);
                if (values[0] != null) {

                    String sku = values[0];
                    skus.add(sku);

                }
            } else {
                isFirst = false;
            }
        }

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'skus: ' + skus);

        Map<String, Object> fetchInputData = new Map<String, Object>{
                ccrz.ccAPIProduct.PRODUCTSKULIST => skus
                ,ccrz.ccAPI.API_VERSION => 7
                ,ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true
                ,ccrz.ccApiProduct.INCLUDE_ATTRIBUTE_PRICING => true
                ,ccrz.ccApiProduct.PRODUCTSTOREFRONT => storefront
                ,ccrz.ccApiProduct.PRODUCTLOCALE => locale
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M  // Medium needed to get ADC fields
                        }
                }
        };

        try {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'fetching products...');

            Map<String, Object> outputFetchData = ccrz.ccAPIProduct.fetch(fetchInputData);

            Boolean isSuccess = (Boolean)outputFetchData.get(ccrz.ccApi.SUCCESS);
            System.debug('isSuccess = ' + isSuccess);

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'isSuccess: ' + isSuccess);

            // Build a Set of product sfids that have sub-prod terms.
            Set<String> sptProductSet = new Set<String>();

            if (outputFetchData.get('sptList') != null) {

                List<Map<String, Object>> sptList = (List<Map<String, Object>>) outputFetchData.get('sptList');

                System.debug('sptMap...');

                for (Map<String, Object> sptMap : sptList) {
                    String productSfid = (String) sptMap.get('product');
                    sptProductSet.add(productSfid);
                }

            }

            System.debug('sptProductSet = ' + sptProductSet);

            if (outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {

                List<Map<String, Object>> outputProductList = (List<Map<String, Object>>) outputFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);

                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'outputProductList size = ' + outputProductList.size());

                for(Map<String, Object> outputProductMap : outputProductList) {

                    String productSfid = (String) outputProductMap.get('sfid');

                    System.debug('productSfid = ' + productSfid);

                    String productName = (String) outputProductMap.get('sfdcName');

                    System.debug('productName: ' + productName);

                    String productType = (String) outputProductMap.get('productType');

                    String sku = (String) outputProductMap.get('SKU');

                    skusFound.add(sku);

                    if(productType != 'Product') {

                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'Invalid product type: ' + productType + ', SKU: ' + sku);

                        ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
                        msgErr.message = 'Invalid product type: ' + productType + ', SKU: ' + sku;
                        msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                        msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                        msgErr.classToAppend = 'messagingSection-CsvUpload-Info';
                        retMessages.add(msgErr);
                    }

                    if(sptProductSet.contains(productSfid)) {

                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'Invalid product type: Subscription, SKU: ' + sku);

                        ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
                        msgErr.message = 'Invalid product type: Subscription, SKU: ' + sku;
                        msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                        msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                        msgErr.classToAppend = 'messagingSection-CsvUpload-Info';
                        retMessages.add(msgErr);
                    }

                    if(outputProductMap.containsKey('primaryAttr') && outputProductMap.get('primaryAttr') != null) {
                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'Invalid product type: Subscription, SKU: ' + sku);

                        ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
                        msgErr.message = 'Invalid product type: ADC, SKU: ' + sku;
                        msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                        msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                        msgErr.classToAppend = 'messagingSection-CsvUpload-Info';
                        retMessages.add(msgErr);
                    }

                }
            }

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'skusFound = ' + skusFound);

            for(String inputSku : skus) {

                if(skusFound.contains(inputSku) == false) {

                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'invalid SKU: ' + inputSku);

                    ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
                    msgErr.message = 'Invalid SKU: ' + inputSku;
                    msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                    msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                    msgErr.classToAppend = 'messagingSection-CsvUpload-Info';
                    retMessages.add(msgErr);

                }

            }

        } catch (Exception err) {
            // Error handling...
            System.debug('error message: ' + err.getMessage());
            System.debug('line number: ' + err.getLineNumber());

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:verifySkus', 'Exception: ' + err.getMessage() + err.getStackTraceString());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error: ' + err.getMessage();
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-UserRoles-Info';
            retMessages.add(msgErr);
        }

        return retMessages;

    }

    private static List<ccrz.cc_bean_Message> importData(ccrz.cc_RemoteActionContext ctx, String csvBlob, boolean newCart, List<String> lines, ccrz.cc_RemoteActionResult resp) {

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        System.debug('newCart = ' + newCart);

        try {
            List<ccrz.ccApiCart.LineData> linesToAdd = new List<ccrz.ccApiCart.LineData>();

            boolean isFirst = true;
            String sku;
            Integer qty;
            String couponCode;
            boolean hasCoupon = false;

            for (String singleLine : lines) {
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'Parsing line' + singleLine);
                if (!isFirst) {
                    List<String> values = singleLine.split(',');
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'values-----' + values);
                    if (values[0] != null) {
                        ccrz.ccApiCart.LineData lineToAdd = new ccrz.ccApiCart.LineData();
                        sku = values[0];
                        if ('coupon'.equalsIgnoreCase(sku) && values.size() > 1) {
                            couponCode = values[1].trim();
                            hasCoupon = true;
                        } else {
                            if (values.size() == 1 || String.isEmpty(values[1]) || String.isBlank(values[1])) {
                                qty = 1;
                            } else {
                                qty = Integer.valueOf(values[1].trim());
                            }
                            lineToAdd.sku = sku;
                            lineToAdd.quantity = qty;
                            linesToAdd.add(lineToAdd);
                        }
                    }
                } else {
                    isFirst = false;
                }
            }

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'linesToAdd size = ' + linesToAdd.size());

            String cartId = ctx.currentCartId;

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'cartId = ' + cartId);

            if (newCart || cartId == null || String.isBlank(cartId)) {
                Map<String, Object> createResults = ccrz.ccApiCart.create(
                        new Map<String, Object>{
                                ccrz.ccApi.API_VERSION => 7,
                                ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>>{
                                        new Map<String, Object>()
                                }
                        }
                );
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'The create success was: ' + (Boolean) createResults.get(ccrz.ccApi.SUCCESS));

                resp.success = (Boolean) createResults.get(ccrz.ccApi.SUCCESS);
                cartId = (String) createResults.get(ccrz.ccApiCart.CART_ENCID);
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'New Cart Id: ' + cartId);
            }

            if (linesToAdd.size() > 0) {
                Map<String, Object> addResults = ccrz.ccApiCart.addTo(new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => 7,
                        ccrz.ccApiCart.CART_ENCID => cartId,
                        ccrz.ccApiCart.LINE_DATA => linesToAdd
                });
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'The addto success was: ' + (Boolean) addResults.get(ccrz.ccApi.SUCCESS));
                resp.success = resp.success && (Boolean) addResults.get(ccrz.ccApi.SUCCESS);

                if (hasCoupon) {
                    Map<String, Object> couponResults = ccrz.ccApiCart.addTo(new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => 4,
                            ccrz.ccApiCart.CART_ENCID => cartId,
                            ccrz.ccApiCart.COUPON_CODE => couponCode
                    });
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'The coupon success was: ' + (Boolean) couponResults.get(ccrz.ccApi.SUCCESS));
                    resp.success = resp.success && (Boolean) couponResults.get(ccrz.ccApi.SUCCESS);
                }

                Map<String, Object> priceResults = ccrz.ccApiCart.price(new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => 7,
                        ccrz.ccApiCart.CART_ENCID => cartId
                });
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'The price success was: ' + (Boolean) priceResults.get(ccrz.ccApi.SUCCESS));
                resp.success = resp.success && (Boolean) priceResults.get(ccrz.ccApi.SUCCESS);

                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
                //msg.labelId              = 'BudgetOverrideApproved' ;
                msg.message = 'CSV File uploaded';
                msg.type                 = ccrz.cc_bean_Message.MessageType.CUSTOM ;
                msg.severity             = ccrz.cc_bean_Message.MessageSeverity.INFO ;
                msg.classToAppend        = 'messagingSection-CsvUpload-Info';

                retMessages.add(msg);

            }
            resp.data = new Map<String, String>{
                    'cartId' => cartId
            };
        } catch (Exception err) {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'CSV Message:importData', 'Exception: ' + err.getMessage() + err.getStackTraceString());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error: ' + err.getMessage();
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-UserRoles-Info';
            retMessages.add(msgErr);

        } finally {
            //ccrz.ccLog.close(resp);
            //resp.messages.addAll(retMessages);
        }

        return retMessages;
    }
}