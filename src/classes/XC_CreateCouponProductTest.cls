/*******************************************************************************************
* @Name         XC_CreateCouponProductTEst
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
class XC_CreateCouponProductTest {

    @isTest
    static void createProductTest() {
        XC_Coupon__c coupon = new XC_Coupon__c(
            XC_CouponName__c = 'TEST',
            XC_CouponCode__c = 'TEST'
        );
        insert coupon;

        Test.startTest();
        System.assertNotEquals(null, XC_CreateCouponProduct.createProduct(new List<Id>{ coupon.Id }), 'Product mismatch');
        Test.stopTest();
    }
}