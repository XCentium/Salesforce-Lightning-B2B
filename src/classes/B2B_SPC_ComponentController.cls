public with sharing class B2B_SPC_ComponentController {
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getAddressInfo(String effectiveAccountId, Boolean isShipping, Boolean isBilling){

        Map<String, Object> responseMap = new Map<String, Object>();

        List<ContactPointAddress> addresses = new List<ContactPointAddress>();
        List<ContactPointAddress> selectAddresses = new List<ContactPointAddress>();
        String defaultAddress = null;

        try {
            
            addresses = [SELECT Address, AddressType, Name, City, Country, IsDefault, IsPrimary FROM ContactPointAddress WHERE ParentId = :effectiveAccountId];

            for(ContactPointAddress addr : addresses) {

                if(isShipping && addr.AddressType == 'Shipping') {
                    selectAddresses.add(addr);

                    if(addr.IsDefault) {
                        defaultAddress = addr.Id;
                    }
                }
                else if(isBilling && addr.AddressType == 'Billing') {
                    selectAddresses.add(addr);

                    if(addr.IsDefault) {
                        defaultAddress = addr.Id;
                    }
                }

            }

        } catch (Exception err) {
            System.debug('Processing error' + ': ' + err.getMessage());
            System.debug('Line #: ' + err.getLineNumber());
            System.debug(err.getStackTraceString());

        }

        System.debug('defaultAddress: ' + defaultAddress);

        responseMap.put('addresses', selectAddresses);

        responseMap.put('defaultAddress', defaultAddress);

        return responseMap;
    }

    @AuraEnabled
    public static Map<String, String> fetchInitValues(String communityId, String effectiveAccountId, String cartId) {

        System.debug('begin fetchInitValues()');

        System.debug('communityId: ' + communityId);
        System.debug('effectiveAccountId: ' + effectiveAccountId);
        System.debug('cartId: ' + cartId);

        Map<String, String> responseMap = new Map<String, String>();
        
        String webstoreId = resolveCommunityIdToWebstoreId(communityId);

        responseMap.put('webstoreId', webstoreId);

        //responseMap.put('effectiveAccountId', effectiveAccountId);

        if(cartId == null && effectiveAccountId != '000000000000000') {
            ConnectApi.CartSummary cs = null;
            if(Test.isRunningTest()== false) {
                cs = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, effectiveAccountId, 'active');
            }
            else {
                cs = new ConnectApi.CartSummary();
                cs.cartId = cartId;
                cs.accountId = effectiveAccountId;
            }

            responseMap.put('cartId', cs.cartId);

            responseMap.put('effectiveAccountId', cs.accountId);
        }
        else {
            responseMap.put('cartId', cartId);
        }

        return responseMap;

    }

    /*
        This method is used to convert the community Id to the web store Id.
    */

    @AuraEnabled
    public static String resolveCommunityIdToWebstoreId(String communityId) {
        if(communityId == null || communityId == '') {
            return null;
        }
        
        String webstoreId = null;

        List<WebStoreNetwork> wsnList = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId];

        if(wsnList.size() > 0) {
            WebStoreNetwork wsn = wsnList.get(0);
            webstoreId = wsn.WebStoreId;
        }

        return webstoreId;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getCartSummary(String effectiveAccountId, String webstoreId, String activeOrCartId, Boolean recalculateTax){

        Map<String, String> responseMap = new Map<String, String>();

        System.debug('effectiveAccountId: ' + effectiveAccountId);
        System.debug('webstoreId: ' + webstoreId);
        System.debug('activeOrCartId: ' + activeOrCartId);
        System.debug('recalculateTax: ' + recalculateTax);

        ConnectApi.CartSummary cs = null;

        try {

            // Update the tax
            if(recalculateTax) {
                B2B_SPC_TaxSample.updateCartTax(activeOrCartId);
            }

            if(Test.isRunningTest() == false) {
                cs = ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeOrCartId);
                System.debug(cs);
            }
            else {
                cs = new ConnectApi.CartSummary();
                cs.grandTotalAmount = '1000';
                cs.totalTaxAmount = '10';
                cs.totalProductAmount = '990';
            }

            responseMap.put('grandTotalAmount', cs.grandTotalAmount);
            responseMap.put('totalTaxAmount', cs.totalTaxAmount);
            responseMap.put('totalProductAmount', cs.totalProductAmount);
            responseMap.put('discount', String.valueOf([SELECT Id, XC_TotalDiscount__c FROM WebCart WHERE Id = :activeOrCartId LIMIT 1].XC_TotalDiscount__c));

            // Get the shipping fee

            // Get the cart item records

            List<CartItem> cartItemObjects = [SELECT Id
            , CartDeliveryGroupId
            , CartDeliveryGroup.DeliveryMethodId
            FROM CartItem 
            WHERE CartId = :activeOrCartId 
            AND CartDeliveryGroupId != null];

            System.debug('cartItemObjects.size = ' + cartItemObjects.size());

            if(cartItemObjects.size() > 0) {
                CartItem cartItemObj = cartItemObjects.get(0);

                String cartDeliveryGroupId = cartItemObj.CartDeliveryGroupId;
                String deliveryMethodId = cartItemObj.CartDeliveryGroup.DeliveryMethodId;

                System.debug('cartDeliveryGroupId: ' + cartDeliveryGroupId);
                System.debug('deliveryMethodId: ' + deliveryMethodId);

                List<CartDeliveryGroupMethod> cdgmList = [SELECT Id
                , CartDeliveryGroupId
                , DeliveryMethodId
                , DeliveryMethod.Name
                , DeliveryMethod.Carrier
                , ExternalProvider
                , Name
                , ShippingFee 
                FROM CartDeliveryGroupMethod 
                WHERE CartDeliveryGroupId = :cartDeliveryGroupId
                AND DeliveryMethodId = :deliveryMethodId];

                if(cdgmList.size() > 0) {
                    CartDeliveryGroupMethod cdgm = cdgmList.get(0);

                    responseMap.put('shippingFee', cdgm.ShippingFee.format());
                }
                else {
                    System.debug('CartDeliveryGroupMethod not selected');
                    responseMap.put('shippingFee', '0');
                }
            }
            else {
                responseMap.put('shippingFee', '0');
            }

        } catch (Exception err) {

            System.debug('Processing error' + ': ' + err.getMessage());
            System.debug('Line #: ' + err.getLineNumber());
            System.debug(err.getStackTraceString());

            throw new AuraHandledException(err.getMessage());
        }        

        return responseMap;
    }

    /*
        Returns 
            a list of CartDeliveryGroupMethod records
            the Id of the selected OrderDeliveryMethod record as the selected option.

        Piggybacks off of the open-source B2BPrepareDeliveryMethodSelections.cls
        from https://github.com/forcedotcom/b2b-commerce-on-lightning-quickstart

        In the LWC, the user will select the Delivery method, and the CartDeliveryGroupMethod Id will be sent for processing.
    */
    @AuraEnabled
    public static Map<String, Object> fetchDeliveryMethods(String cartId){

        System.debug('begin fetchDeliveryMethods()');
        System.debug('cartId: ' + cartId);

        Map<String, Object> responseMap = new Map<String, Object>();

        List<ID> cartIds = new List<ID>();
        cartIds.add(cartId);

        try {
            // Use the open source class to get the shipping options and create the CartDeliveryGroupMethods for the cart
            B2B_SPC_DeliveryMethods.prepDeliveryMethodsInternal(cartIds);

            // Retrieve the CartDeliveryGroupMethods and return them as a List
            List<CartDeliveryGroupMethod> cdgmList = [SELECT Id, 
                CartDeliveryGroupId
                , DeliveryMethodId
                , DeliveryMethod.Name
                , DeliveryMethod.Carrier
                , ExternalProvider
                , Name
                , ShippingFee 
                FROM CartDeliveryGroupMethod 
                WHERE WebCartId = :cartId];

            if(cdgmList.size() > 0) {
                responseMap.put('cartDeliveryGroupMethods', cdgmList);
            }

            // Get the delivery method assigned to the CartItem records, if any
            List<CartItem> cartItemObjs = [SELECT Id, Name, Type, CartDeliveryGroupId, CartDeliveryGroup.DeliveryMethodId 
                FROM CartItem 
                WHERE CartId = :cartId 
                AND CartDeliveryGroupId != null];

            String deliveryMethodId = null;

            if(cartItemObjs.size() > 0) {
                CartItem cartItem = cartItemObjs.get(0);
                deliveryMethodId = cartItem.CartDeliveryGroup.DeliveryMethodId;
            }

            if(deliveryMethodId != null) {
                responseMap.put('selectedDeliveryMethodId', deliveryMethodId);
            }


        } catch (Exception e) {

            System.debug('Processing error' + ': ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }

        return responseMap;
    }

    /*
        Creates a CartItem "Charge" record for the selected delivery method.
        The selected order delivery method is assigned to the cart delivery group record.
    */
    @AuraEnabled
    public static Map<String, Object> setCartItemDeliveryGroup(String cartDeliveryGroupMethodId, String deliveryMethodId, String cartId) {

        System.debug('cartDeliveryGroupMethodId: ' + cartDeliveryGroupMethodId);
        System.debug('deliveryMethodId: ' + deliveryMethodId);
        System.debug('cartId: ' + cartId);

        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            // Get the selected OrderDeliveryMethod record
            // This has the Product record Id needed for the CartItem

            OrderDeliveryMethod deliveryMethod = null;

            List<OrderDeliveryMethod> dmList = [Select Id, Name, Carrier, ProductId from OrderDeliveryMethod where Id = :deliveryMethodId];

            if(dmList.size() > 0) {
                deliveryMethod = dmList.get(0);
            }
            else {
                throw new CustomException('OrderDeliveryMethod not found');
            }

            // Get the CartDeliveryGroupMethod record
            // This has the ShippingFee

            CartDeliveryGroupMethod cdgm = null;

            List<CartDeliveryGroupMethod> cdgmList = [SELECT Id, 
                CartDeliveryGroupId
                , ShippingFee 
                FROM CartDeliveryGroupMethod 
                WHERE Id = :cartDeliveryGroupMethodId
                AND WebCartId = :cartId];

            if(cdgmList.size() > 0) {
                cdgm = cdgmList.get(0);
            }
            else {
                throw new CustomException('CartDeliveryGroupMethod not found');
            }

            // Get the ID of the CartDeliveryGrou.
            // There is one CartDeliveryGroup per cart, and it is associated with every CartItem in the Cart.
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;

            System.debug('cartDeliveryGroupId: ' + cartDeliveryGroupId);

            // Get the existing CartItem record for the delivery charge
            List<CartItem> cartItemObjs = [Select Id from CartItem where CartId = :cartId and Type = 'Charge'];

            CartItem cartItemCharge = null;

            if(cartItemObjs.size() > 0) {
                System.debug('Existing CartItem for the Charge found');

                cartItemCharge = cartItemObjs.get(0);
            }
            else {

                System.debug('Creating new CartItem for the Charge');

                cartItemCharge = new CartItem(
                    Type = 'Charge',
                    Product2Id = deliveryMethod.ProductId,
                    Quantity = 1.0,
                    AdjustmentAmount = 0.0,
                    CartId = cartId,
                    CartDeliveryGroupId = cartDeliveryGroupId,
                    Name = 'Shipping Cost'
                );

            }

            cartItemCharge.TotalPrice = cdgm.ShippingFee;
            cartItemCharge.ListPrice = cdgm.ShippingFee;
            cartItemCharge.TotalListPrice = cdgm.ShippingFee;
            cartItemCharge.TotalLineAmount = cdgm.ShippingFee;

            upsert cartItemCharge;

            // A delivery method has to be associated to the cart delivery group.
            addOrderDeliveryMethodToCartDeliveryGroup(deliveryMethod.Id, cartDeliveryGroupId);

        } catch (Exception e) {
            System.debug('Processing error' + ': ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());

            B2B_SPC_ComponentUtil.addMessage(new B2B_SPC_ComponentUtil.Message('Error', e.getMessage(), B2B_SPC_ComponentUtil.ERROR), 0, responseMap);

            //throw new AuraHandledException(err.getMessage());
        }

        List<B2B_SPC_ComponentUtil.Message> retMessages = (List<B2B_SPC_ComponentUtil.Message>)responseMap.get('messages');

        String messagesJson = JSON.serialize(retMessages);
        System.debug('messagesJson: ' + messagesJson);
        responseMap.put('messagesJson', messagesJson);

        return responseMap;
    }

    private static void addOrderDeliveryMethodToCartDeliveryGroup(Id someOrderDeliveryMethodId, Id someCartDeliveryGroupId) {       
        // The OrderDeliveryMethod is added to the CartDeliveryGroup for the order to be properly created during checkout.
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id, DeliveryMethodId FROM CartDeliveryGroup WHERE Id= :someCartDeliveryGroupId][0];
        cartDeliveryGroup.DeliveryMethodId = someOrderDeliveryMethodId;
        update cartDeliveryGroup;
    }

    @AuraEnabled
    public static Map<String, Object> setCartDeliveryGroupShipToAddress(String contactPointAddress, String cartId){

        System.debug('begin setCartDeliveryGroupShipToAddress()');
        System.debug('contactPointAddress: ' + contactPointAddress);
        System.debug('cartId: ' + cartId);

        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            // Get the CartDeliveryGroup record
            CartDeliveryGroup deliveryGroup = null;

            List<CartDeliveryGroup> deliveryGroups = [Select Id from CartDeliveryGroup where CartId = :cartId];

            System.debug('deliveryGroups.size = ' + deliveryGroups.size());

            if(deliveryGroups.size() > 0) {
                deliveryGroup = deliveryGroups.get(0);
            }

            // Get the ContactPointAddress record

            ContactPointAddress pointAddress = null;

            List<ContactPointAddress> addresses = [Select Id, Name, Address from ContactPointAddress where Id = :contactPointAddress];

            System.debug('addresses.size = ' + addresses.size());

            if(addresses.size() > 0) {
                pointAddress = addresses.get(0);
            }

            // Update the CartDeliveryGroup with the ContactPointAddress info
            Address theAddress = (Address)pointAddress.Address;
            deliveryGroup.DeliverToCity = theAddress.getCity();
            deliveryGroup.DeliverToCountry = theAddress.getCountry();
            deliveryGroup.DeliverToGeocodeAccuracy = theAddress.getGeocodeAccuracy();
            deliveryGroup.DeliverToLatitude = theAddress.getLatitude();
            deliveryGroup.DeliverToLongitude = theAddress.getLongitude();
            deliveryGroup.DeliverToName = pointAddress.Name;
            deliveryGroup.DeliverToPostalCode = theAddress.getPostalCode();
            deliveryGroup.DeliverToState = theAddress.getState();
            deliveryGroup.DeliverToStreet = theAddress.getStreet();

            upsert deliveryGroup;

        } catch (Exception e) {

            System.debug('Processing error' + ': ' + e.getMessage());
            System.debug('Line #: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());

            B2B_SPC_ComponentUtil.addMessage(new B2B_SPC_ComponentUtil.Message('Error', e.getMessage(), B2B_SPC_ComponentUtil.ERROR), 0, responseMap);

            //throw new AuraHandledException(e.getMessage());
        }

        return responseMap;
    }

    public class CustomException extends Exception {}

}