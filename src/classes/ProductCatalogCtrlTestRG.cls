@isTest(SeeAllData=true)
public class ProductCatalogCtrlTestRG {
    static testmethod void noParameterTestMethod() {
        ProductCatalogCtrlRG.getProducts();
        ProductCatalogCtrlRG.getUserInfo();
    }
    
    static testmethod void cartSpecificTestMethods() {
        RG_Cart__c cart = ProductCatalogCtrlRG.getCart();
        RG_Cart_Item__c item = new RG_Cart_Item__c();
        item.RG_Cart__c = cart.Id;
        List<PricebookEntry> prod = [SELECT Id,Product2.Id,Product2.Name,Product2.Description,Product2.Product_Catalog_Image__c,UnitPrice FROM PricebookEntry WHERE PriceBook2.IsStandard = true ORDER BY Product2.Name LIMIT 1];
        item.Product__c = prod[0].Product2.Id;
        item.Name = prod[0].Product2.Name;
        item.Quantity__c = 5.0;
        item.Unit_Price__c = prod[0].UnitPrice;
        insert item;
        List<RG_Cart_Item__c> items = ProductCatalogCtrlRG.getCartItems(cart.Id);
        ProductCatalogCtrlRG.updateCartItems(items[0].Id, 1);
        ProductCatalogCtrlRG.updateUserInfo('Randy', 'Grewal', 'Salesforce', '50 Fremont St', 'San Francisco', 'CA', '94105');
        ProductCatalogCtrlRG.deleteCartItems(cart.Id);
        ProductCatalogCtrlRG.updateCart(cart.Id, items[0].Name, items[0].Product__c, 100.00, 10);
        ProductCatalogCtrlRG.closeOrder(cart.Id, '4141414141414141', '12/2017', '001', 10, 10);
    }
    
}