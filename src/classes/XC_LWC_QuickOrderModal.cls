public with sharing class XC_LWC_QuickOrderModal {
    public XC_LWC_QuickOrderModal() {

    }

    @AuraEnabled
    public static Map<String,String> addItemToCartWithId(String cartId, Map<String, String> mapOfSkuAndQuantity){
        Map<String, String> mapOfFailedToAddItems = new Map<String, String>();
        for(String productId: mapOfSkuAndQuantity.keySet()){
            try{
                XC_LWC_CartCtrlHelper.addItemToCartWithId(cartId, productId, mapOfSkuAndQuantity.get(productId));
            }catch(Exception e){
                mapOfFailedToAddItems.put(productId, e.getMessage());
            }
        }
        return mapOfFailedToAddItems;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAllProductsSimilarToProduct(String productId){
        List<Product2> listOfProducts = new List<Product2>();

        Product2 currentProduct = [select ID,StockKeepingUnit, Model_Id__c, name, xc_Att_1__c, xc_Att_2__c, xc_Att_3__c
            from Product2
            where id =:productId];
        if(currentProduct.Model_Id__c!=null){
                listOfProducts = [select ID,StockKeepingUnit, Model_Id__c, name, xc_Att_1__c, xc_Att_2__c, xc_Att_3__c
                    from Product2
                    where Model_Id__c =:currentProduct.Model_Id__c];
        }else{
            listOfProducts.add(currentProduct);
        }
        Set<String> setOfMetaDataKeys = new Set<String>();
        String[] attSplit;
        for(Product2 product: listOfProducts){
            if(product.xc_Att_1__c!=null){
                attSplit = product.xc_Att_1__c.split(':');
                setOfMetaDataKeys.add(attSplit[0]);
            }
            if(product.xc_Att_2__c!=null){
                attSplit = product.xc_Att_2__c.split(':');
                setOfMetaDataKeys.add(attSplit[0]);
            }
            if(product.xc_Att_3__c!=null){
                attSplit = product.xc_Att_3__c.split(':');
                setOfMetaDataKeys.add(attSplit[0]);
            }
        }

        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('listOfProducts', listOfProducts);
        returnMap.put('listOfCustomMetaData', getCustomMetaDataForKeys(setOfMetaDataKeys));
        return returnMap;
    }

    private static List<Commerce_Attribute__mdt> getCustomMetaDataForKeys(Set<String> setOfMetaDataKeys){
        return [select key__c, Display_Name__c, Display_Type__c, Values__c
            from Commerce_Attribute__mdt
            where key__c in :setOfMetaDataKeys];
    }
}