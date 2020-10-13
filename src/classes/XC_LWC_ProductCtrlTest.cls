/**
 * @FileName: XC_LWC_ProductCtrlTest
 * @Description: Product controller test
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest(SeeAllData=true) // Lightning B2B primarily uses ConnectApi methods for products
private class XC_LWC_ProductCtrlTest {

    @IsTest
    static void getProduct() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Parent_Product__c = '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        Test.startTest();
        XC_LWC_ProductWrappers.ProductDetails wrapper = XC_LWC_ProductCtrl.getProduct(p.Id, a.Id);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.productDetail);
        System.assert(wrapper.showDescription);
    }

    @IsTest
    static void getSpotlightProducts() {
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        Test.startTest();
        List<XC_LWC_ProductWrappers.SpotlightProduct> spotlightProducts = XC_LWC_ProductCtrl.getSpotlightProducts(a.Id);
        Test.stopTest();

        System.assertNotEquals(null, spotlightProducts);
    }

    @IsTest
    static void getProductPrice() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Parent_Product__c = '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        Test.startTest();
        ConnectApi.ProductPrice price = XC_LWC_ProductCtrl.getProductPrice(p.Id, a.Id);
        Test.stopTest();

        System.assertEquals(pbe.UnitPrice, Decimal.valueOf(price.unitPrice));
    }

    @IsTest
    static void getProductAttributes() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Aggregate_Column__c != '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1];

        Test.startTest();
        XC_LWC_ProductWrappers.ProductAttributes wrapper = XC_LWC_ProductCtrl.getProductAttributes(p.Id);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
    }

    @IsTest
    static void getProductAggregates() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Aggregate_Column__c != '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id LIMIT 1];

        Test.startTest();
        XC_LWC_ProductWrappers.ProductAggregates wrapper = XC_LWC_ProductCtrl.getProductAggregates(p.Id);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
    }
}