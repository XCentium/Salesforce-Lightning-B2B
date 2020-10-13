/**
 * @FileName: XC_LWC_CartCtrlTest
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest(SeeAllData=true) // Lightning B2B primarily uses ConnectApi methods for carts
private class XC_LWC_CartCtrlTest {

    @IsTest
    static void addItemToCart() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Parent_Product__c = '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id];
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        Test.startTest();
        XC_LWC_CartCtrl.addItemToCart(p.Id, '1', a.Id);
        Test.stopTest();

        ConnectApi.CartItemCollection cartItems = ConnectApi.CommerceCart.getCartItems(XC_Util_Query.currentWebStoreId, a.Id, 'active');

        System.assertNotEquals(null, cartItems);
    }

    @IsTest
    static void addItemsToCart() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        PricebookEntry pbe = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Parent_Product__c = '' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Id = :pbe.Product2Id];
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        Map<String,String> items = new Map<String,String>{
                p.Id => '1'
        };

        Test.startTest();
        XC_LWC_CartCtrl.addItemsToCart(items, a.Id);
        Test.stopTest();

        ConnectApi.CartItemCollection cartItems = ConnectApi.CommerceCart.getCartItems(XC_Util_Query.currentWebStoreId, a.Id, 'active');

        System.assertNotEquals(null, cartItems);
    }

    @IsTest
    static void fillCartFromCSV() {
        WebStorePricebook wpb = [SELECT Id, Pricebook2Id FROM WebStorePricebook WHERE WebStoreId = :XC_Util_Query.currentWebStoreId];
        List<PricebookEntry> pbes = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :wpb.Pricebook2Id AND Product2.Parent_Product__c = '' LIMIT 2];

        List<Id> productIds = new List<Id>();

        for (PricebookEntry pbe : pbes) {
            productIds.add(pbe.Product2Id);
        }

        List<Product2> products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE Id IN :productIds];
        Account a = [SELECT Id FROM Account WHERE IsBuyer = TRUE LIMIT 1];

        String csvContents = 'sku,qty';

        for (Product2 p : products) {
            csvContents += '\n' + p.StockKeepingUnit + ',1';
        }

        Test.startTest();
        XC_LWC_CartCtrl.fillCartFromCSV(csvContents, a.Id);
        Test.stopTest();

        ConnectApi.CartItemCollection cartItems = ConnectApi.CommerceCart.getCartItems(XC_Util_Query.currentWebStoreId, a.Id, 'active');

        System.assertNotEquals(null, cartItems);
    }
}