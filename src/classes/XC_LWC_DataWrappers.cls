/**
 * @FileName: XC_LWC_DataWrappers
 * @Description: Wrapper classes for data controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/27/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_DataWrappers {

    public class OrderPadOptions {
        @AuraEnabled public List<Map<String,String>> categoryOptions;
        @AuraEnabled public List<Map<String,String>> brandOptions;
        @AuraEnabled public List<Map<String,String>> productOptions;

        public String activeFilter;
        public String category;
        public String brand;

        public OrderPadOptions() {
            this.categoryOptions = new List<Map<String,String>>();
            this.brandOptions = new List<Map<String,String>>();
            this.productOptions = new List<Map<String,String>>();

            setOptions();
        }

        public OrderPadOptions(String activeFilter, String category, String brand) {
            this.categoryOptions = new List<Map<String,String>>();
            this.brandOptions = new List<Map<String,String>>();
            this.productOptions = new List<Map<String,String>>();
            this.activeFilter = activeFilter;
            this.category = category;
            this.brand = brand;

            setOptions();
        }

        private void setOptions() {
            WebStoreCatalog catalog = [
                    SELECT ProductCatalogId
                    FROM WebStoreCatalog
                    WHERE SalesStoreId = :XC_Util_Query.currentWebStoreId
            ];

            String categoryQuery = 'SELECT Id, Name FROM ProductCategory WHERE IsNavigational = TRUE ORDER BY Name ASC';

            List<ProductCategory> categories = Database.query(categoryQuery);

            for (ProductCategory cat : categories) {
                this.categoryOptions.add(new Map<String,String>{'label' => cat.Name, 'value' => cat.Name});
            }

            String productQuery = 'SELECT Id, ProductId, Product.Name, Product.Brand__c, ProductCategory.Name ' +
                    'FROM ProductCategoryProduct ' +
                    'WHERE ProductCategory.CatalogId = \'' + catalog.ProductCatalogId + '\' ' +
                    'AND ProductCategory.IsNavigational = TRUE ';

            if (this.activeFilter == 'category' && String.isNotBlank(this.category)) {
                productQuery += 'AND ProductCategory.Name = \'' + String.escapeSingleQuotes(this.category) + '\' ';
            }

            if (this.activeFilter == 'brand' || this.activeFilter == 'product') {
                if (String.isNotBlank(this.category)) {
                    productQuery += 'AND ProductCategory.Name = \'' + String.escapeSingleQuotes(this.category) + '\' ';
                }
                if (String.isNotBlank(this.brand)) {
                    productQuery += 'AND Product.Brand__c = \'' + String.escapeSingleQuotes(this.brand) + '\' ';
                }
            }

            productQuery += 'ORDER BY Product.Name ASC';

            List<ProductCategoryProduct> pcps = Database.query(productQuery);

            Set<String> brandSet = new Set<String>();

            for (ProductCategoryProduct pcp : pcps) {

                if (String.isBlank(this.category) && String.isBlank(this.brand)) {
                    this.productOptions.add(new Map<String,String>{'label' => pcp.Product.Name, 'value' => pcp.ProductId});
                }

                if (String.isBlank(this.category) && String.isNotBlank(this.brand) && pcp.Product.Brand__c == this.brand) {
                    this.productOptions.add(new Map<String,String>{'label' => pcp.Product.Name, 'value' => pcp.ProductId});
                }

                if (String.isNotBlank(this.category) && String.isBlank(this.brand) && pcp.ProductCategory.Name == this.category) {
                    this.productOptions.add(new Map<String,String>{'label' => pcp.Product.Name, 'value' => pcp.ProductId});
                }

                if (String.isNotBlank(this.category) && String.isNotBlank(this.brand) && pcp.Product.Brand__c == this.brand && pcp.ProductCategory.Name == this.category) {
                    this.productOptions.add(new Map<String,String>{'label' => pcp.Product.Name, 'value' => pcp.ProductId});
                }

                brandSet.add(pcp.Product.Brand__c);
            }

            List<String> brandList = new List<String>();
            brandList.addAll(brandSet);
            brandList.sort();

            for (String brand : brandList) {
                this.brandOptions.add(new Map<String,String>{'label' => brand, 'value' => brand});
            }
        }
    }
}