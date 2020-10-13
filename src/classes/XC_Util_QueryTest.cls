/**
 * @FileName: XC_Util_QueryTest
 * @Description: Test methods for query utility
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest
private class XC_Util_QueryTest {

    @IsTest
    static void getCurrentWebstoreId() {
        WebStore store = (WebStore) XC_Util_TestData.createSObject(new WebStore(), true);

        Test.startTest();
        Id webStoreId = XC_Util_Query.currentWebStoreId;
        Test.stopTest();

        System.assertEquals(store.Id, webStoreId);
    }

    @IsTest
    static void getProductVariantCategory() {
        ProductCatalog productCatalog = (ProductCatalog) XC_Util_TestData.createSObject(new ProductCatalog(), true);

        XC_Util_TestData.createSObject(
                new ProductCategory(
                        Name = XC_Util_Constants.PRODUCT_VARIANTS_CATEGORY,
                        CatalogId = productCatalog.Id
                ),
                true
        );

        Test.startTest();
        ProductCategory pc = XC_Util_Query.productVariantCategory;
        Test.stopTest();

        System.assertNotEquals(null, pc);
    }
}