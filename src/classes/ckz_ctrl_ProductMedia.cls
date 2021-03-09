/**
 * Created by brandon.rogers on 3/29/19.
 */

global class ckz_ctrl_ProductMedia {
    public boolean displayProductMedia { get; set; }
    public String contentProductMedia { get; set; }

    global ckz_ctrl_ProductMedia() {
        String productSKU;
        productSKU = Apexpages.currentPage().getParameters().get('sku');
        displayProductMedia = false;
        contentProductMedia = 'Before';
        getProductMedia(productSKU);
    }

    private void getProductMedia(String SKU) {

        ccrz__E_Product__c currentProduct = [select id from ccrz__E_Product__c where ccrz__SKU__c = :SKU];

        List<ccrz__E_ProductTab__c> ProductMediaRecord = [select id, ccrz__Content__c from ccrz__E_ProductTab__c where ccrz__Product__c = :currentProduct.Id and ccrz__Tab__c = 'Product Media'];
        if (ProductMediaRecord.isEmpty() == false) {
            displayProductMedia = true;
            contentProductMedia = ProductMediaRecord[0].ccrz__Content__c;
        } else {
            contentProductMedia = 'null record';
        }
    }
}