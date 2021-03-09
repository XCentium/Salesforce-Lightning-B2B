/*******************************************************************************************
* @Name         XC_CreateCouponProduct
* @Author       Brian Zigarovich <brian.zigarovich@xcentium.com>
* @Date         01/21/2021
* @Group        Coupon API
* @Description  Creates coupon product.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Brian           01/21/2021          Initial Creation                    
*******************************************************************************************/
public with sharing class XC_CreateCouponProduct {

    /**************************************************************************************
    * @Description  Creates coupon product
    * @Param        couponIds - list of ids to create coupon for
    * @Return       list of new product IDs
    * @Example
    **************************************************************************************/
    @InvocableMethod(label='Create Coupon Product' description='Creates coupon product record.')
    public static List<Id> createProduct(List<Id> couponIds) {
        XC_Coupon__c coupon = [
            SELECT Id, XC_CouponName__c, XC_CouponCode__c
            FROM XC_Coupon__c
            WHERE Id = :couponIds[0]
        ];

        // Create product
        Product2 prod = new Product2(
            Name = coupon.XC_CouponName__c,
            ProductCode = coupon.XC_CouponCode__c,
            IsActive = true
        );
        insert prod;

        // Link product
        coupon.XC_CouponProduct__c = prod.Id;
        update coupon;

        return new List<Id>{ prod.Id };
    }
}