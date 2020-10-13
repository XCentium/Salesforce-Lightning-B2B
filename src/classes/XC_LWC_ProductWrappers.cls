/**
 * @FileName: XC_LWC_ProductWrappers
 * @Description: Wrapper classes for product controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/20/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_ProductWrappers {

    public class ProductDetails {
        @AuraEnabled public ConnectApi.ProductDetail productDetail;
        @AuraEnabled public List<Product_Tab__c> productTabs;
        @AuraEnabled public List<Product2> childProducts;
        @AuraEnabled public Boolean showDescription;

        public ProductDetails(Id productId, Id effectiveAccountId) {
            this.showDescription = true;

            this.productDetail = ConnectApi.CommerceCatalog.getProduct(
                    XC_Util_Query.currentWebStoreId,
                    productId,
                    effectiveAccountID,
                    null,
                    false,
                    null,
                    false,
                    true,
                    false
            );

            this.productTabs = [SELECT Id, Name, Type__c, Content__c, URL__c FROM Product_Tab__c WHERE Product__c = :productId];
            this.childProducts = [SELECT Id FROM Product2 WHERE Parent_Product__c = :productId];
        }
    }

    public class SpotlightProduct {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String imageAlternativeText;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public String price;
        @AuraEnabled public String description;

        public SpotlightProduct(String pId, ConnectApi.ProductDetail productDetail, ConnectApi.ProductPrice productPrice) {
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

    public class ProductAttributes {
        @AuraEnabled public List<ProductAttribute> attributes;
        @AuraEnabled public Map<String,Map<String,String>> attributesByProduct;

        public ProductAttributes(List<Product2> products) {
            this.attributes = new List<ProductAttribute>();
            this.attributesByProduct = new Map<String,Map<String,String>>();

            setAttributes(products);
        }

        private void setAttributes(List<Product2> products) {
            Map<String,Set<String>> attributeMap = new Map<String,Set<String>>();

            for (Product2 p : products) {
                for (Product_Attribute__c att : p.Product_Attributes__r) {
                    Set<String> values = attributeMap.get(att.Attribute__r.Attribute__c);

                    if (values == null) {
                        values = new Set<String>();
                    }

                    values.add(att.Attribute__r.Value__c);

                    attributeMap.put(att.Attribute__r.Attribute__c, values);

                    Map<String,String> pAtts = this.attributesByProduct.get(p.Id);

                    if (pAtts == null) {
                        pAtts = new Map<String,String>();
                    }

                    pAtts.put(att.Attribute__r.Attribute__c, att.Attribute__r.Value__c);

                    this.attributesByProduct.put(p.Id, pAtts);
                }
            }

            for (String att : attributeMap.keySet()) {
                this.attributes.add(new ProductAttribute(att, attributeMap.get(att)));
            }
        }
    }

    public class ProductAttribute {
        @AuraEnabled public String name;
        @AuraEnabled public List<Map<String,String>> values;

        public ProductAttribute(String name, Set<String> values) {
            this.name = name;
            this.values = new List<Map<String,String>>();
            setValues(values);
        }

        private void setValues(Set<String> values) {
            for (String value : values) {
                this.values.add(new Map<String,String>{'label' => value, 'value' => value});
            }
        }
    }

    public class ProductAggregates {
        @AuraEnabled public String colName;
        @AuraEnabled public String rowName;
        @AuraEnabled public List<AttributeValue> colValues;
        @AuraEnabled public List<AttributeValue> rowValues;

        public ProductAggregates(Product2 parentProduct, List<Product_Attribute__c> attributes) {
            this.colName = parentProduct.Aggregate_Column__c;
            this.rowName = parentProduct.Aggregate_Row__c;
            this.colValues = new List<AttributeValue>();
            this.rowValues = new List<AttributeValue>();

            setProductAggregates(parentProduct, attributes);
        }

        private void setProductAggregates(Product2 parentProduct, List<Product_Attribute__c> attributes) {
            Set<String> tempColValues = new Set<String>();
            Set<String> tempRowValues = new Set<String>();
            Map<String,String> productIdMap = new Map<String,String>();
            Map<Id,List<String>> attributeMap = new Map<Id,List<String>>();

            List<String> colSequence = new List<String>();

            if (String.isNotBlank(parentProduct.Aggregate_Column_Sequence__c)) {
                colSequence = parentProduct.Aggregate_Column_Sequence__c.split(';');
            }

            List<String> rowSequence = new List<String>();

            if (String.isNotBlank(parentProduct.Aggregate_Row_Sequence__c)) {
                rowSequence = parentProduct.Aggregate_Row_Sequence__c.split(';');
            }

            for (Product_Attribute__c att : attributes) {
                List<String> pAtts = attributeMap.get(att.Product__c);

                if (pAtts == null) {
                    pAtts = new List<String>{'',''};
                }

                if (att.Attribute__r.Attribute__c == parentProduct.Aggregate_Column__c) {
                    pAtts[0] = att.Attribute__r.Value__c;
                    tempColValues.add(att.Attribute__r.Value__c);
                }
                else {
                    pAtts[1] = att.Attribute__r.Value__c;
                    tempRowValues.add(att.Attribute__r.Value__c);
                }

                attributeMap.put(att.Product__c, pAtts);
            }

            for (String colValue : tempColValues) {
                this.colValues.add(new AttributeValue(colValue, colSequence.indexOf(colValue)));
            }

            this.colValues.sort();
            System.debug(this.colValues);

            List<String> rowValueList = new List<String>();
            rowValueList.addAll(tempRowValues);
            rowValueList.sort();

            for (Id pId : attributeMap.keySet()) {
                List<String> pAtts = attributeMap.get(pId);
                productIdMap.put(pAtts[1] + ':' + pAtts[0], pId);
            }

            for (String rowValue : tempRowValues) {
                this.rowValues.add(new AttributeValue(rowValue, rowSequence.indexOf(rowValue), tempColValues, productIdMap));
            }

            this.rowValues.sort();
            System.debug(this.rowValues);
        }
    }

    public class AttributeValue implements Comparable {
        @AuraEnabled public String value;
        @AuraEnabled public Map<String,Boolean> keyMap;

        public Integer sequence;

        public AttributeValue(String attributeValue, Integer sequence) {
            this.value = attributeValue;
            this.sequence = sequence;
        }

        public AttributeValue(String attributeValue, Integer sequence, Set<String> colValues, Map<String,Id> productIdMap) {
            this.value = attributeValue;
            this.sequence = sequence;
            this.keyMap = new Map<String,Boolean>();

            for (String colValue : colValues) {
                String key = productIdMap.get(attributeValue + ':' + colValue);
                Boolean available = true;

                if (String.isBlank(key)) {
                    key = 'no-product';
                    available = false;
                }

                this.keyMap.put(key, available);
            }
        }

        public Integer compareTo(Object compareTo) {
            AttributeValue attVal = (AttributeValue) compareTo;

            if (this.sequence == attVal.sequence) return 0;
            if (this.sequence > attVal.sequence) return 1;

            return -1;
        }
    }
}