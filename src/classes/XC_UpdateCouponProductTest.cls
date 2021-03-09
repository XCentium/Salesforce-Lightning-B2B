/*******************************************************************************************
* @Name         XC_UpdateCouponProductTest
* @Author       Brian Zigarovich <brian.zigarovich@xcentium.com>
* @Date         01/24/2021
* @Group        Coupon API
* @Description  Test class.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Brian           01/24/2021          Initial Creation                    
*******************************************************************************************/
@isTest
class XC_UpdateCouponProductTest {

    @isTest
    static void updateProductTest() {
        Product2 prod = new Product2(
            Name = 'TEST',
            ProductCode = 'TEST',
            IsActive = true
        );
        insert prod;

        XC_Coupon__c coupon = new XC_Coupon__c(
            XC_CouponProduct__c = prod.Id,
            XC_CouponName__c = 'TEST2',
            XC_CouponCode__c = 'TEST2'
        );
        insert coupon;

        Test.startTest();
        System.assertNotEquals(null, XC_UpdateCouponProduct.updateProduct(new List<Id>{ coupon.Id }), 'Product mismatch');
        Test.stopTest();
    }
}