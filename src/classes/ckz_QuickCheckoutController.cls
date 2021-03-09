/**
 * Created by msobczak on 11/27/2018.
 */

public with sharing class ckz_QuickCheckoutController {

    @AuraEnabled
    public static Map<String, Object> updateCartForCheckout(String userId, String storefront, String currencyCode, String accountId, String locale, String cartId, String cartEncryptedId) {

        Map<String, Object> responseMap = new Map<String, Object>();

        System.debug('---- begin updateCartForCheckout');

        System.debug('userId: ' + userId);
        System.debug('storefront: ' + storefront);
        System.debug('currencyCode: ' + currencyCode);
        System.debug('accountId: ' + accountId);
        System.debug('locale: ' + locale);
        System.debug('cartId: ' + cartId);
        System.debug('cartEncryptedId: ' + cartEncryptedId);

        // See if the storefront uses LLI
        ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
        request.storefront = storefront;
        request.configSetting = 'eff.enabled';
        request.externallySafe = false;
        request.page = 'all';

        ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        // 2018-12-03 msobczak: context must be preset to get payment methods and to properly init cart item groups
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        ctx.userLocale = locale;
        ctx.userIsoCode = currencyCode;
        ctx.portalUserId = userId;

        if(configValue == 'TRUE') {
            ctx.effAccountId = accountId;
        }

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Savepoint sp = Database.setSavepoint();

        try {

            // Validate the cart (essentially a fetch)
            validateCart(cartId, responseMap);

            // Get the shipping addresses
            getAddress('Shipping', accountId, responseMap);

            // Get the billing addresses
            getAddress('Billing', accountId, responseMap);

            Boolean shippingAddressesFound = (Boolean) responseMap.get('ShippingAddressesFound');
            Boolean billingAddressesFound = (Boolean) responseMap.get('BillingAddressesFound');

            if (shippingAddressesFound == false) {
                String msg = (String)responseMap.get('ShippingAddressMsg');
                throw new CustomException(msg);
            }

            if (billingAddressesFound == false) {
                String msg = (String)responseMap.get('BillingAddressMsg');
                throw new CustomException(msg);
            }

            String shippingAddressId = (String) responseMap.get('ShippingDefaultAddressId');
            String billingAddressId = (String) responseMap.get('BillingDefaultAddressId');

            System.debug('billingAddressId = ' + billingAddressId);
            System.debug('shippingAddressId = ' + shippingAddressId);

            // See if the storefront uses LLI
            ckz_OrderFormCheckConfigSetting.ConfigSettingRequest request2 = new ckz_OrderFormCheckConfigSetting.ConfigSettingRequest();
            request2.storefront = storefront;
            request2.configSetting = 'co.uselli';
            request2.externallySafe = false;
            request2.page = 'ca';

            ckz_OrderFormCheckConfigSetting.ConfigSettingResponse response2 = ckz_OrderFormCheckConfigSetting.checkConfigSetting(request2);

            String configValue2 = response2.configValue;

            System.debug('LLI setting = ' + configValue2);

            Boolean cartItemGroupCreated = false;
            Boolean cartItemGroupUpdated = false;

            if (configValue2 == 'TRUE') {

                // 2018-12-03: Create a cart item group (but does not add items to it)
                //if(responseMap.containsKey('cartItemGroupId') == false) {
                // Create a cart item group and associate the default shipTo address to it.
                //    createCartItemGroup(cartId, shippingAddressId, responseMap);
                //}

                // 2018-12-03: This works, but creates an extra copy of the default CC Contact Address for the ship to.
                initCartItemGroup(cartEncryptedId, responseMap);

                /*
                initCartItemGroup(cartEncryptedId, responseMap);

                cartItemGroupCreated = (Boolean) responseMap.get('cartItemGroupCreated');

                if(cartItemGroupCreated) {
                    String cartItemGroupId = (String) responseMap.get('cartItemGroupId');

                    // Set the default shipping address on the cart item group
                    // 2018-12-03  msobczak: commented out to see if this is causing an issue with extra CC Contact Addresses being created.
                    // 2018-12-03  msobczak: associates the dupe CC Contact Address with the cart item group.
                    //reviseCartItemGroup(cartItemGroupId, shippingAddressId, responseMap);

                    //cartItemGroupUpdated = (Boolean) responseMap.get('cartItemGroupUpdated');

                    //if(cartItemGroupUpdated == false) {
                    //    String cartItemGroupUpdatedMsg = (String)responseMap.get('cartItemGroupUpdatedMsg');
                    //    throw new CustomException(cartItemGroupUpdatedMsg);
                    //}

                }
                else {
                    String cartItemGroupCreatedMsg = (String)responseMap.get('cartItemGroupCreatedMsg');
                    throw new CustomException(cartItemGroupCreatedMsg);
                }
                */

            } else {
                // Add the Ship To directly to the cart object.
                cartItemGroupCreated = true;
                cartItemGroupUpdated = true;
            }

            if (configValue2 == 'TRUE') {
                // LLI: Set the Billing Address on the cart object
                reviseCartHeader(cartId, storefront, billingAddressId, null, responseMap);
            }
            else {
                // Set the Billing and Shipping Addresses on the cart object
                reviseCartHeader(cartId, storefront, billingAddressId, shippingAddressId, responseMap);
            }

            Boolean cartHeaderRevised = (Boolean)responseMap.get('cartHeaderRevised');

            if(cartHeaderRevised == false) {
                String cartHeaderRevisedMsg = (String)responseMap.get('cartHeaderRevisedMsg');
                throw new CustomException(cartHeaderRevisedMsg);
            }

            Boolean cartValidated = (Boolean)responseMap.get('cartValidated');
            if(cartValidated == false) {
                String cartValidatedMsg = (String)responseMap.get('cartValidatedMsg');
                throw new CustomException(cartValidatedMsg);
            }


            // Get the payment methods
            fetchPaymentMethods(userId, storefront, responseMap);

            Boolean paymentMethodsRetrieved = (Boolean)responseMap.get('paymentMethodsRetrieved');
            responseMap.putAll(responseMap);

            if(paymentMethodsRetrieved == false) {
                throw new CustomException('Payment methods not retrieved or found');
            }

            responseMap.put('checkoutLoadSuccessful', true);
            responseMap.put('checkoutLoadMsg', 'Checkout successfully loaded');

        }
        catch (CustomException e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.put('checkoutLoadSuccessful', false);
            //responseMap.put('checkoutLoadMsg', 'Error encountered.  All transactions rolled back.');
            responseMap.put('checkoutLoadMsg', e.getMessage());
        }

        System.debug('---- end updateCartForCheckout');

        return responseMap;

    }

    private static void getAddress(String addressType, String accountId, Map<String, Object> responseMap) {

        System.debug('---- begin getAddress');

        responseMap.put(addressType + 'AddressesFound', false);
        responseMap.put(addressType + 'DefaultAddressesFound', false);
        responseMap.put(addressType + 'DefaultAddress', null);

        List<Map<String, Object>> addressList = new List<Map<String, Object>>();

        Map<String,Object> inputData = (new Map<String,Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                //,ccrz.ccAPIAddressBook.OWNERID => userId
                //,ccrz.ccAPIAddressBook.OWNERID => contactId
                ,ccrz.ccAPIAddressBook.ACCOUNTID => accountId
                ,ccrz.ccAPIAddressBook.TYPE => 'Shipping'
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPIAddressBook.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                        }
                }
        });

        try {
            Map<String, Object> outputData = ccrz.ccAPIAddressBook.fetch(inputData);

            Boolean isSuccess = (Boolean)outputData.get(ccrz.ccApi.SUCCESS);

            if(isSuccess == false) {
                responseMap.put(addressType + 'AddressMsg', addressType + ' address(s) not found');
                return;
            }

            responseMap.put(addressType + 'AddressMsg', addressType + ' address(s) found');
            responseMap.put(addressType + 'AddressesFound', true);

            //System.debug('outputData:');
            //System.debug(outputData);

            // The AddressBookList tells you what kind and if it is the default.
            // The AddressList contains the actual address.

            if (outputData.get(ccrz.ccAPIAddressBook.ADDRESSBOOKS) != null) {

                List<Map<String, Object>> addressBookList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIAddressBook.ADDRESSBOOKS);

                String EContactAddress = null;

                for (Map<String, Object> addressBook : addressBookList) {

                    //System.debug(addressBook);
                    Boolean isDefault = (Boolean) addressBook.get('default');

                    if (isDefault) {
                        EContactAddress = (String) addressBook.get('EContactAddress');
                        //System.debug('default EContactAddress = ' + EContactAddress);
                    }

                }

                if (EContactAddress == null) {
                    EContactAddress = (String) addressBookList.get(0).get('EContactAddress');
                }

                addressList = (List<Map<String, Object>>) outputData.get('addressList');

                Map<String, Object> defaultAddress = null;

                for (Map<String, Object> address : addressList) {

//            for(String key : address.keySet()) {
//                System.debug('key: ' + key + ', ' + address.get(key));
//            }

                    String currentSfid = (String) address.get('sfid');
                    //System.debug('currentSfid = ' + currentSfid);

                    if (currentSfid == EContactAddress) {
                        defaultAddress = address;
                        break;
                    }

                }

                if (defaultAddress != null) {
                    responseMap.put(addressType + 'DefaultAddressesFound', true);
                    responseMap.put(addressType + 'DefaultAddress', defaultAddress);
                    responseMap.put(addressType + 'DefaultAddressId', EContactAddress);
                    responseMap.put(addressType + 'DefaultAddressMsg', addressType + ' default address found');
                }

                System.debug('defaultAddress = ' + defaultAddress);
            }
            else {

            }

        } catch (Exception e) {
            responseMap.put(addressType + 'DefaultAddressMsg', 'Error: ' + e.getMessage());
            System.debug('Exception: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end getAddress');

    }

    /*
        Initialize a Cart Item Group.
        All items in the cart will be added to the group.
        The default shipping address is automatically assigned to the group.  This only works if a context is established prior to this call.
        2018-12-03  seems to result in a copy of the default CC Contact Address ship to being created and associated with the cart item group.
     */
    private static void initCartItemGroup(String cartEncryptedId, Map<String, Object> responseMap) {

        System.debug('---- begin initCartItemGroup');

        responseMap.put('cartItemGroupCreated', false);

        Map<String,Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_ENCID => cartEncryptedId
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA=>ccrz.ccApi.SZ_L  // Use Large to get cartItemGroup shipTo
                                ,ccrz.ccApi.SZ_REFETCH => true
                        }
                }

        };

        try {
            Map<String, Object> outputData = ccrz.ccApiCart.initItemGroups(inputData);

            Boolean isSuccess = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            if(isSuccess) {
                responseMap.put('cartItemGroupCreated', true);
                responseMap.put('cartItemGroupCreatedMsg', 'Cart Item Group created');

                // Get the new cart item group id and put it into the responseMap
                List<Map<String, Object>> cartList = (List<Map<String, Object>>)outputData.get('cartList');

                Map<String, Object> cartMap = cartList.get(0);

                List<Map<String, Object>> cartItemGroupList = (List<Map<String, Object>>)cartMap.get('ECartItemGroupsS');

                Map<String, Object> cartItemGroupMap = cartItemGroupList.get(0);

                String sfid = (String)cartItemGroupMap.get('sfid');
                System.debug('sfid = ' + sfid);

                responseMap.put('cartItemGroupId', sfid);

                // 2018-12-03  msobczak: added
                String shipToId = (String)cartItemGroupMap.get('shipTo');

                responseMap.put('cartItemGroupShipToId', shipToId);

            }
            else {
                responseMap.put('cartItemGroupCreatedMsg', 'Cart Item Group not created');
            }

        } catch (Exception e) {
            responseMap.put('cartItemGroupCreatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end initCartItemGroup');

    }

    /*
        Creates a new Cart Item Group and assigns the ship to address to all items in it.
     */
    private static void createCartItemGroup(String cartId, String shipToAddressId, Map<String, Object> responseMap) {

        System.debug('---- begin createCartItemGroup');

        System.debug('shipToAddressId = ' + shipToAddressId);

        responseMap.put('cartItemGroupCreated', false);

        Date requestedDate = Date.today();

        Map<String,Object> insertGroup = new Map<String,Object>{
                'cart' => cartId
                ,'note' => 'Headless commerce'
                ,'requestedDate' => requestedDate
                ,'shipTo' => shipToAddressId
                ,'shipAmount' => 0
                ,'shipMethod' => 'Overnight'
        };

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,'ECartItemGroupsS' => new List<Map<String,Object>>{insertGroup}
        };

        try {
            Map<String, Object> outputData = ccrz.ccApiCart.createCartItemGroup(inputData);

            Boolean cartGroupCreated = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            if(cartGroupCreated) {
                responseMap.put('cartItemGroupCreated', true);
                responseMap.put('cartItemGroupCreatedMsg', 'Cart group created');
            }
            else {
                responseMap.put('cartItemGroupCreatedMsg', 'Cart group not created');
            }

        } catch (Exception e) {
            responseMap.put('cartItemGroupCreatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end createCartItemGroup');

    }

    private static void reviseCartItemGroup(String cartItemGroupId, String shippingAddressId, Map<String, Object> responseMap) {

        System.debug('---- begin reviseCartItemGroup');

        System.debug('shippingAddressId = ' + shippingAddressId);

        responseMap.put('cartItemGroupUpdated', false);

        Date requestedDate = Date.today();

        Map<String,Object> updateGroup = new Map<String,Object>{
                'sfid' => cartItemGroupId,
                'note' => 'Headless commerce',
                'requestedDate' => requestedDate,
                'shipTo' => shippingAddressId
                //'shipAmount' => 100.00,
                //'shipMethod' => 'Overnight'
        };

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,'ECartItemGroupsS' => new List<Map<String,Object>>{updateGroup}
                //We pass in SIZING information if we want to re-fetch the cart data, with the updated cart item group
                /*,ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL,
                                ccrz.ccAPI.SZ_REFETCH => TRUE
                        }
                }*/
        };

        try {
            Map<String,Object> outputData = ccrz.ccApiCart.reviseCartItemGroup(inputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful = ' + wasSuccessful);

            if(wasSuccessful) {
                responseMap.put('cartItemGroupUpdated', true);
                responseMap.put('cartItemGroupUpdatedMsg', 'Cart item group updated with Shipping Address');
            }
            else {
                responseMap.put('cartItemGroupUpdatedMsg', 'Cart item group was not updated with Shipping Address');
            }

        }
        catch (Exception e) {
            responseMap.put('cartItemGroupUpdatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end addBillingAddressToCart');

    }

    /*
        Adds the default billing and shipping address to the cart obj.
        The shipping address is not applied when LLI is used.
     */
    private static void reviseCartHeader(String cartId, String storefront, String billingAddressId, String shippingAddressId, Map<String, Object> responseMap) {

        System.debug('---- begin reviseCartHeader');

        System.debug('billingAddressId = ' + billingAddressId);

        responseMap.put('cartHeaderRevised', false);

        Map<String, Object> cartInputData = new Map<String, Object>{
                'sfid' => cartId
                ,'billTo' => billingAddressId
                ,'storeFront' => storefront
                ,'shipTo' => shippingAddressId
        };

        List<Object> cartList = new List<Object>();
        cartList.add(cartInputData);

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                , ccrz.ccApiCart.CART_OBJLIST => cartList
        };

        try {

            Map<String, Object> outputData = ccrz.ccApiCart.revise(inputData);

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            if(wasSuccessful) {
                responseMap.put('cartHeaderRevised', true);
                responseMap.put('cartHeaderRevisedMsg', 'Cart header revised');
            }
            else {
                responseMap.put('cartHeaderRevisedMsg', 'Cart header was not revised');
            }
        }
        catch (Exception e) {
            responseMap.put('cartHeaderRevisedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end reviseCartHeader');

    }

    /*
        Return all payment methods for the userId.
        Requires creating a CKZ call context.
     */
    public static void fetchPaymentMethods(String userId, String storefront, Map<String, Object> responseMap) {

        System.debug('---- begin fetchPaymentMethods');

        responseMap.put('paymentMethodsRetrieved', false);

        try {

            // Get the SFIDs for the Stored Payment objects that the current user owns
            List<ccrz__E_StoredPayment__c> storedPaymentObjs = [Select Id, Name from ccrz__E_StoredPayment__c where OwnerId = :userId];

            Set<String> paymentMethodIds = new Set<String>();

            for(ccrz__E_StoredPayment__c sp : storedPaymentObjs) {
                paymentMethodIds.add(sp.Id);
            }

            Map<String,Object> inputData = new Map<String, Object>{
                    ccrz.ccAPIStoredPayment.STOREFRONT  => storefront
                    ,ccrz.ccAPIStoredPayment.ISENABLED => true
                    ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccAPIStoredPayment.IDS => paymentMethodIds
                    ,ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA=>ccrz.ccApi.SZ_S
                            }
                    }

            };

            Map<String,Object> outputData = ccrz.ccAPIStoredPayment.fetch(inputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('outputData: ' + outputData);

            System.debug('wasSuccessful = ' + wasSuccessful);

            if(wasSuccessful) {
                responseMap.put('paymentMethodsRetrieved', true);
                responseMap.put('paymentMethodsRetrievedMsg', 'Payment methods retrieved');

                List<Map<String, Object>> storedPaymentList = (List<Map<String, Object>>)outputData.get(ccrz.ccAPIStoredPayment.STOREDPAYMENTSLIST);

                /*
                    2019-07-22  msobczak: changed the code to filter by account.
                    This doesn't work because most of the payment methods are for the current account.
                    Need to filter by contact, but contact ID isn't included in the JSon data set.
                 */
/*
                List<Map<String, Object>> paymentOptions = new List<Map<String, Object>>();

                for(Map<String, Object> paymentMethod : storedPaymentList) {

                    Map<String, String> paymentOption = new Map<String, String>();

                    String paymentType = (String)paymentMethod.get('paymentType');
                    String accountNumber = (String)paymentMethod.get('accountNumber');
                    String accountType = (String)paymentMethod.get('accountType');
                    String sfid = (String)paymentMethod.get('sfid');
                    Boolean isDefault = (Boolean)paymentMethod.get('default');

                    System.debug(accountType + ': ' + accountNumber);

                    paymentOption.put('value', sfid);
                    paymentOption.put('label', accountType + ': ' + accountNumber);

                    paymentOptions.add(paymentOption);
                }

                responseMap.put('paymentOptions', paymentOptions);
                */
                responseMap.put('storedPaymentList', storedPaymentList);

            }
            else {
                responseMap.put('paymentMethodsRetrievedMsg', 'Payment methods not retrieved');
            }

        }
        catch (Exception e) {
            responseMap.put('paymentMethodsRetrievedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end fetchPaymentMethods');

    }

    /*
        Validates the cart.
        Required to convert to an order.

        Also retrieves the totalAmount and totalQuantity.

        the ccApiCart.validate() method essentially does a fetch.
     */
    private static void validateCart(String cartId, Map<String, Object> responseMap) {

        System.debug('---- begin validateCart');

        responseMap.put('cartValidated', false);
        responseMap.put('totalAmount', 0.00);
        responseMap.put('totalQuantity', 0);

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_ID => cartId
                ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L,
                                ccrz.ccApi.SZ_REFETCH => true
                        }
                }
        };

        try {

            Map<String, Object> outputData = ccrz.ccApiCart.validate(inputData);

            System.debug('outputData:');
            System.debug(outputData);

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful: ' + wasSuccessful);

            if(wasSuccessful) {

                Boolean allowCheckout = (Boolean) outputData.get(ccrz.ccApiCart.ALLOW_CHECKOUT);

                System.debug('allowCheckout: ' + allowCheckout);

                if(allowCheckout) {
                    responseMap.put('cartValidated', true);
                    responseMap.put('cartValidatedMsg', 'Cart is valid');
                }
                else {
                    responseMap.put('cartValidatedMsg', 'Cart is not valid');
                }

                List<Map<String, Object>> cartList = (List<Map<String, Object>>)outputData.get(ccrz.ccApiCart.CART_OBJLIST);

                Map<String, Object> cartMap = new Map<String, Object>();
                if(cartList.size() > 0) {
                    cartMap = cartList.get(0);
                }

                Decimal totalAmount = (Decimal)cartMap.get('totalAmount');

                // 2018-01-10  msobczak: modified to handle Decimal quantities
                Integer totalQuantity = null;
                Object totalQtyObj = cartMap.get('totalQuantity');

                if(totalQtyObj instanceof Decimal) {
                    totalQuantity = ((Decimal)totalQtyObj).intValue();
                }
                else {
                    totalQuantity = (Integer)totalQtyObj;
                }

                System.debug('totalAmount = ' + totalAmount);
                System.debug('totalQuantity = ' + totalQuantity);

                responseMap.put('totalAmount', totalAmount);
                responseMap.put('totalQuantity', totalQuantity);

                // 2019-02-07  msobczak: added
                //if(totalQuantity == null || totalAmount == null) {
                fetchCartTotals(cartId, responseMap);
                //}


                // Get the new cart item group id and put it into the responseMap
                // Look for cart item group

                if(cartMap.containsKey('ECartItemGroupsS')) {

                    List<Map<String, Object>> cartItemGroupList = (List<Map<String, Object>>) cartMap.get('ECartItemGroupsS');

                    Map<String, Object> cartItemGroupMap = cartItemGroupList.get(0);

                    String sfid = (String) cartItemGroupMap.get('sfid');
                    System.debug('sfid = ' + sfid);

                    responseMap.put('cartItemGroupId', sfid);

                    // 2018-12-03  msobczak: added
                    String shipToId = (String) cartItemGroupMap.get('shipTo');

                    responseMap.put('cartItemGroupShipToId', shipToId);
                }

            }
            else {
                responseMap.put('cartValidatedMsg', 'Cart validation was not successful');
            }

            if(outputData.containsKey(ccrz.ccApi.MESSAGES)) {

                System.debug('cartMessages: ');
                System.debug(outputData.get(ccrz.ccApi.MESSAGES));

                List<ccrz.cc_bean_Message> cartMessageBeans = (List<ccrz.cc_bean_Message>)ccrz.ccUtil.defv(outputData, ccrz.ccApi.MESSAGES, new List<ccrz.cc_bean_Message>());

                List<ckz_ApiMessage> cartMessageList = new List<ckz_ApiMessage>();

                for(ccrz.cc_bean_Message cartMessageBean : cartMessageBeans) {

                    ckz_ApiMessage m = new ckz_ApiMessage();

                    if(cartMessageBean.severity == ccrz.cc_bean_Message.MessageSeverity.ERROR) {
                        m.severity = 'ERROR';
                    }

                    if(cartMessageBean.severity == ccrz.cc_bean_Message.MessageSeverity.INFO) {
                        m.severity = 'INFO';
                    }

                    if(cartMessageBean.type == ccrz.cc_bean_Message.MessageType.CUSTOM) {
                        m.type = 'CUSTOM';
                    }

                    if(cartMessageBean.type == ccrz.cc_bean_Message.MessageType.STANDARD) {
                        m.type = 'STANDARD';
                    }

                    m.message = cartMessageBean.message;
                    cartMessageList.add(m);

                }

                //System.debug('cartMessageList: ' + cartMessageList);

                System.debug(JSON.serialize(cartMessageList));

                responseMap.put('cartValidationMessages', JSON.serialize(cartMessageList));
            }

        }
        catch (Exception e) {
            responseMap.put('cartValidatedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }

        System.debug('---- end validateCart');

    }

    /*
     * 2019-02-07  msobczak: added
     */
    private static void fetchCartTotals(String cartId, Map<String, Object> responseMap) {

        System.debug('---- begin fetchCartTotals');

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        Set<String> searchIdSet = new Set<String>();
        searchIdSet.add(cartId);

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_IDLIST => searchIdSet
                , ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                        }
                }

        };

        try {
            Map<String, Object> outputData = ccrz.ccApiCart.fetch(inputData);

            System.debug('outputData: ' + JSON.serialize(outputData));



            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful: ' + wasSuccessful);

            if (outputData.get(ccrz.ccApiCart.CART_OBJLIST) != null) {

                List<Map<String, Object>> cartList = (List<Map<String, Object>>) outputData.get(ccrz.ccApiCart.CART_OBJLIST);

                System.debug('cartList size = ' + cartList.size());

                Map<String, Object> cartMap = new Map<String, Object>();
                if(cartList.size() > 0) {
                    cartMap = cartList.get(0);
                }

                Decimal totalAmount = (Decimal)cartMap.get('totalAmount');  System.debug('totalAmount = ' + totalAmount);

                // 2018-01-10  msobczak: modified to handle Decimal quantities
                Integer totalQuantity = null;
                Object totalQtyObj = cartMap.get('totalQuantity');

                System.debug('totalQuantity = ' + totalQuantity);

                if(totalQtyObj instanceof Decimal) {
                    totalQuantity = ((Decimal)totalQtyObj).intValue();
                }
                else {
                    totalQuantity = (Integer)totalQtyObj;
                }

                System.debug('totalQuantity = ' + totalQuantity);
                System.debug('totalAmount = ' + totalAmount);

                responseMap.put('totalAmount', totalAmount);
                responseMap.put('totalQuantity', totalQuantity);

            }


        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

        }

        System.debug('---- end fetchCartTotals');

    }

    @AuraEnabled
    public static Map<String, Object> createOrder(String userId, String storefront, String cartId, String jsonPaymentInfo) {

        System.debug('---- begin createOrder');

        Map<String, Object> responseMap = new Map<String, Object>();

        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.storefront = storefront;
        //ctx.userLocale = locale;
        //ctx.userIsoCode = 'USD';
        ctx.portalUserId = userId;

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Savepoint sp = Database.setSavepoint();

        try {
            placeOrder(cartId, jsonPaymentInfo, responseMap);

            Boolean orderPlaced = (Boolean)responseMap.get('orderPlaced');

            if(orderPlaced == false) {
                String msg = (String)responseMap.get('orderPlacedMsg');
                throw new CustomException(msg);
            }

            String orderId = (String)responseMap.get('orderId');

            fetchOrder(orderId, responseMap);

            Boolean orderRetrieved = (Boolean)responseMap.get('orderRetrieved');

            if(orderRetrieved == false) {
                String msg = (String)responseMap.get('orderRetrievedMsg');
                throw new CustomException(msg);
            }

            responseMap.put('createOrderSuccessful', true);

        } catch (CustomException e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.put('createOrderSuccessful', false);

            responseMap.put('createOrderMsg', e.getMessage());
        }

        System.debug('---- end createOrder');

        return responseMap;

    }

    private static void placeOrder(String cartId, String jsonPaymentInfo, Map<String, Object> responseMap) {

        System.debug('---- begin placeOrder');

        System.debug('cartId = ' + cartId);
        System.debug('jsonPaymentInfo = ' + jsonPaymentInfo);

        responseMap.put('orderPlaced', false);

        try {

            System.debug('deserializing payment info');
            List<Object> temp = (List<Object>)JSON.deserializeUntyped(jsonPaymentInfo);
            System.debug('deserializing complete');

            System.debug('payment info = ' + temp);

            Map<String, Object> temp2 = (Map<String, Object>)temp.get(0);

            String pmt = JSON.serialize(temp2);

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApiCart.CART_ID => cartId
                    ,ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                    ,ccrz.ccApiCart.SKIP_VALID_CHECK => true
                    ,ccrz.ccApiCart.PAYMENTDATA => pmt
            };

            System.debug('placing order');
            Map<String, Object> outputData = ccrz.ccApiCart.place(inputData);
            System.debug('order placed');

            //General check, since the cart Id will be blank if not successful we technically do not need this.
            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful = ' + wasSuccessful);

            if(wasSuccessful) {

                String orderId = (String) outputData.get(ccrz.ccApiCart.ORDER_ID);

                responseMap.put('orderId', orderId);

                responseMap.put('orderPlaced', true);
                responseMap.put('orderPlacedMsg', 'Cart order placed successfully');
                System.debug('Cart order placed successfully');
            }
            else {
                System.debug('Cart order not successful');
                responseMap.put('orderPlacedMsg', 'Cart order not successful');
            }
        }
        catch (Exception e) {
            responseMap.put('orderPlacedMsg', 'Error: ' + e.getMessage());
            System.debug('Error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

        System.debug('---- end placeOrder');

    }

    private static void fetchOrder(String orderId, Map<String, Object> responseMap) {

        responseMap.put('orderRetrieved', false);

        Set<String> orderIdList = new Set<String>{orderId};

        Map<String, Object> orders = new Map<String, Object>();

//        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
//        ctx.storefront = storefront;
//        ctx.userLocale = 'en_US';
//        ctx.userIsoCode = 'USD';
//
//        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                , ccrz.ccAPIOrder.PARAM_ORDER_ID_LIST => orderIdList
        };

        try {
            Map<String, Object> outputData = ccrz.ccAPIOrder.fetch(inputData);

            //System.debug('outputData: ' + outputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            if(wasSuccessful) {

                if (outputData.get(ccrz.ccAPIOrder.ORDERLIST) != null) {

                    List<Map<String, Object>> outputOrderList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIOrder.ORDERLIST);

                    Map<String, Object> orderMap = outputOrderList.get(0);

                    String sfdcName = (String)orderMap.get('sfdcName');
                    String sfId = (String)orderMap.get('sfId');

                    responseMap.put('orderName', sfdcName);
                    responseMap.put('orderSfid', sfId);

                    responseMap.put('orderRetrieved', true);
                    responseMap.put('orderRetrievedMsg', 'Order #: ' + sfdcName);
                }

            }
            else {
                responseMap.put('orderRetrievedMsg', 'Order retrieve not successful');
            }

        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

        }

    }

    public class CustomException extends Exception {}

}