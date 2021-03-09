/*******************************************************************************************
* @Name         XC_UpdateCouponProduct
* @Author       Brian Zigarovich <brian.zigarovich@xcentium.com>
* @Date         01/21/2021
* @Group        Coupon API
* @Description  Updates coupon product.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Brian           01/21/2021          Initial Creation                    
*******************************************************************************************/
public with sharing class XC_UpdateCouponProduct {

    /**************************************************************************************
    * @Description  Updates coupon product
    * @Param        couponIds - list of ids to create coupon for
    * @Return       list of updated product IDs
    * @Example
    **************************************************************************************/
    @InvocableMethod(label='Update Coupon Product' description='Updates coupon product record.')
    public static List<Id> updateProduct(List<Id> couponIds) {
        XC_Coupon__c coupon = [
            SELECT Id, XC_CouponName__c, XC_CouponCode__c, XC_CouponProduct__c
            FROM XC_Coupon__c
            WHERE Id = :couponIds[0]
        ];

        // Create product
        Product2 prod = new Product2(
            Id = coupon.XC_CouponProduct__c,
            Name = coupon.XC_CouponName__c,
            ProductCode = coupon.XC_CouponCode__c,
            IsActive = true
        );
        update prod;

        return new List<Id>{ prod.Id };
    }
}