/**
 * @FileName: XC_LWC_DataCtrlTest
 * @Description: Test methods for data controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/18/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest
private class XC_LWC_DataCtrlTest {
    @TestSetup
    static void setupTest() {
        setupHelper();
    }

    @IsTest
    static void getOrderPadOptions() {
        Test.startTest();
        XC_LWC_DataWrappers.OrderPadOptions options = XC_LWC_DataCtrl.getOrderPadOptions();
        Test.stopTest();

        System.assert(!options.categoryOptions.isEmpty());
        System.assert(!options.brandOptions.isEmpty());
        System.assert(!options.productOptions.isEmpty());
    }

    @IsTest
    static void refreshOrderPadOptionsCategory() {
        Test.startTest();
        XC_LWC_DataWrappers.OrderPadOptions options = XC_LWC_DataCtrl.refreshOrderPadOptions(
                'category',
                'Test Category 2',
                'Test Brand'
        );
        Test.stopTest();

        System.assert(!options.categoryOptions.isEmpty());
        System.assert(options.brandOptions.isEmpty());
        System.assert(options.productOptions.isEmpty());
    }

    @IsTest
    static void refreshOrderPadOptionsBrand() {
        Test.startTest();
        XC_LWC_DataWrappers.OrderPadOptions options = XC_LWC_DataCtrl.refreshOrderPadOptions(
                'brand',
                'Test Category',
                'Test Brand 2'
        );
        Test.stopTest();

        System.assert(!options.categoryOptions.isEmpty());
        System.assert(options.brandOptions.isEmpty());
        System.assert(options.productOptions.isEmpty());
    }

    // HELPER METHODS
    static void setupHelper() {
        WebStore store = (WebStore) XC_Util_TestData.createSObject(new WebStore(), true);

        ProductCatalog productCatalog = (ProductCatalog) XC_Util_TestData.createSObject(new ProductCatalog(), true);

        XC_Util_TestData.createSObject(new WebStoreCatalog(ProductCatalogId = productCatalog.Id, SalesStoreId = store.Id), true);

        ProductCategory productCategory = (ProductCategory) XC_Util_TestData.createSObject(
                new ProductCategory(
                        Name = 'Test Category',
                        CatalogId = productCatalog.Id,
                        IsNavigational = true
                ),
                true
        );

        Product2 p = (Product2) XC_Util_TestData.createSObject(new Product2(Brand__c = 'Test Brand'), true);

        XC_Util_TestData.createSObject(new ProductCategoryProduct(ProductCategoryId = productCategory.Id, ProductId = p.Id), true);
    }
}