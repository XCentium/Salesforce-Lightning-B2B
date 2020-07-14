/**
 * @FileName: XC_LWC_ProductCtrlHelper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/2/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_ProductCtrlHelper {

    public static List<DisplayableProduct> getSpotlightProducts() {
        List<Product2> products = [
                SELECT Id
                FROM Product2
                WHERE Spotlight_Product__c = TRUE
                LIMIT 3
        ];

        List<DisplayableProduct> displayableProducts = new List<DisplayableProduct>();

        for (Product2 p : products) {
            ConnectApi.ProductDetail productDetail = ConnectApi.CommerceCatalog.getProduct(
                    XC_Util_Query.currentWebstoreId,
                    p.Id,
                    '001B000001KUE39IAH',
                    null,
                    false,
                    null,
                    false,
                    true,
                    false
            );

            ConnectApi.ProductPrice productPrice = ConnectApi.CommerceStorePricing.getProductPrice(
                    XC_Util_Query.currentWebstoreId,
                    p.Id,
                    '001B000001KUE39IAH'
            );

            displayableProducts.add(new DisplayableProduct(p.Id, productDetail, productPrice));
        }

        return displayableProducts;
    }

    public class DisplayableProduct {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String imageAlternativeText;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String price;
        @AuraEnabled public String description;

        public DisplayableProduct(String pId, ConnectApi.ProductDetail productDetail, ConnectApi.ProductPrice productPrice) {
            Map<String,Object> fields = productDetail.fields;
            ConnectApi.ProductMedia defaultImage = (ConnectApi.ProductMedia) productDetail.defaultImage;

            this.id = pId;
            this.name = (String) fields.get('Name');
            this.imageUrl = defaultImage.url;
            this.imageAlternativeText = defaultImage.alternateText;
            this.currencyCode = productPrice.currencyIsoCode;
            this.price = productPrice.unitPrice;
            this.description = (String) fields.get('Description');
        }
    }
}