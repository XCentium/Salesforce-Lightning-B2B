/**
 * Created by brandon.rogers on 4/1/19.
 */

global with sharing class ckz_ctrl_PDP_AssortmentBuilder {
    global Boolean doOverride { get; set; }
    global String cartId { get; set; }
    global Boolean doReconfigure { get; set; }
    global String lineId { get; set; }
    global Map<String, Decimal> productQtyMap { get; set; }
    private Map<String, String> product2SKU { get; set; }
    global String lineName { get; set; }

    global ckz_ctrl_PDP_AssortmentBuilder() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        doOverride = (!String.isBlank(params.get('doOverride')));
        cartId = (params.get('cartID'));
        lineId = (params.get('lineId'));
        doReconfigure = !String.isBlank(lineId);

        if (doReconfigure) {
            productQtyMap = new Map<String, Decimal>();
            product2SKU = new Map<String, String>();
            List<String> prodIds = new List<String>();
            ccrz__E_cartItem__c cartItem = [Select c.ccrz__cartItemType__c, c.ccrz__UnitOfMeasure__c, c.ccrz__Subscription_Frequency__c, c.ccrz__Subscription_Duration__c, c.ccrz__SubAmount__c, c.ccrz__StoreID__c, c.ccrz__RequestDate__c, c.ccrz__Quantity__c, c.ccrz__Product__c, c.ccrz__ProductType__c, c.ccrz__Price__c, c.ccrz__PercentDiscount__c, c.ccrz__ParentProduct__c, c.ccrz__ParentCartItem__c, c.ccrz__OriginalQuantity__c, c.ccrz__ItemTotal__c, c.ccrz__ItemStatus__c, c.ccrz__ItemLabel__c, c.ccrz__Is_Subscription_Selected__c, c.ccrz__DisplayProduct__c, c.ccrz__Coupon__c, c.ccrz__Comments__c, c.ccrz__Category__c, c.ccrz__Cart__c, c.ccrz__CartItemId__c, c.ccrz__AvailabilityMessage__c, c.ccrz__AdjustmentAmount__c, c.ccrz__AbsoluteDiscount__c, c.SystemModstamp, c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ccrz__Cart__c, ccrz__AbsoluteDiscount__c, ccrz__AdjustmentAmount__c, ccrz__AvailabilityMessage__c, ccrz__CartItemId__c, ccrz__Category__c, ccrz__Comments__c, ccrz__Coupon__c, ccrz__DisplayProduct__c, ccrz__ItemLabel__c, ccrz__ItemStatus__c, ccrz__ItemTotal__c, ccrz__ParentCartItem__c, ccrz__ParentProduct__c, ccrz__PercentDiscount__c, ccrz__Price__c, ccrz__ProductType__c, ccrz__Product__c, ccrz__Quantity__c, ccrz__RequestDate__c, ccrz__StoreID__c, ccrz__SubAmount__c, ccrz__UnitOfMeasure__c, ccrz__cartItemType__c, ccrz__Is_Subscription_Selected__c, ccrz__Subscription_Duration__c, ccrz__Subscription_Frequency__c, ccrz__OriginalQuantity__c From ccrz__Cart_Items__r) From ccrz__E_CartItem__c c where id = :lineId];
            lineName = cartItem.ccrz__ItemLabel__c;
            for (ccrz__E_cartItem__c childItem : cartItem.ccrz__Cart_Items__r) {
                prodIds.add(childItem.ccrz__Product__c);
            }
            List<ccrz__E_Product__c> products = [select id, ccrz__sku__c from ccrz__E_product__c where id in:prodIds];
            for (ccrz__E_Product__c product : products) {
                product2SKU.put(product.Id, product.ccrz__sku__c);
            }
            for (ccrz__E_cartItem__c childItem : cartItem.ccrz__Cart_Items__r) {
                productQtyMap.put(product2SKU.get(childItem.ccrz__Product__c), childItem.ccrz__Quantity__c);
            }
        }
    }

    global PageReference deleteOldLine() {
        ccrz.ccLog.log('@@ In ckz_ctrl_PDP_AssortmentBuilder, deleteOldLine @@');
        if (doReconfigure) {
            System.debug(lineId);
            ccrz__E_cartItem__c cartItem = [Select c.ccrz__cartItemType__c, c.ccrz__UnitOfMeasure__c, c.ccrz__Subscription_Frequency__c, c.ccrz__Subscription_Duration__c, c.ccrz__SubAmount__c, c.ccrz__StoreID__c, c.ccrz__RequestDate__c, c.ccrz__Quantity__c, c.ccrz__Product__c, c.ccrz__ProductType__c, c.ccrz__Price__c, c.ccrz__PercentDiscount__c, c.ccrz__ParentProduct__c, c.ccrz__ParentCartItem__c, c.ccrz__OriginalQuantity__c, c.ccrz__ItemTotal__c, c.ccrz__ItemStatus__c, c.ccrz__ItemLabel__c, c.ccrz__Is_Subscription_Selected__c, c.ccrz__DisplayProduct__c, c.ccrz__Coupon__c, c.ccrz__Comments__c, c.ccrz__Category__c, c.ccrz__Cart__c, c.ccrz__CartItemId__c, c.ccrz__AvailabilityMessage__c, c.ccrz__AdjustmentAmount__c, c.ccrz__AbsoluteDiscount__c, c.SystemModstamp, c.Name, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ccrz__Cart__c, ccrz__AbsoluteDiscount__c, ccrz__AdjustmentAmount__c, ccrz__AvailabilityMessage__c, ccrz__CartItemId__c, ccrz__Category__c, ccrz__Comments__c, ccrz__Coupon__c, ccrz__DisplayProduct__c, ccrz__ItemLabel__c, ccrz__ItemStatus__c, ccrz__ItemTotal__c, ccrz__ParentCartItem__c, ccrz__ParentProduct__c, ccrz__PercentDiscount__c, ccrz__Price__c, ccrz__ProductType__c, ccrz__Product__c, ccrz__Quantity__c, ccrz__RequestDate__c, ccrz__StoreID__c, ccrz__SubAmount__c, ccrz__UnitOfMeasure__c, ccrz__cartItemType__c, ccrz__Is_Subscription_Selected__c, ccrz__Subscription_Duration__c, ccrz__Subscription_Frequency__c, ccrz__OriginalQuantity__c From ccrz__Cart_Items__r) From ccrz__E_CartItem__c c where id = :lineId];
            delete cartItem.ccrz__Cart_Items__r;
            delete cartItem;
        }
        PageReference thePage = new PageReference('/ccrz__Cart?cartId=' + cartId);
        return thePage;
    }
}