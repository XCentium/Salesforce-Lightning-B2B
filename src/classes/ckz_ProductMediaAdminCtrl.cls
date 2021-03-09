public with sharing class ckz_ProductMediaAdminCtrl {

    private static List<String> prodMediaImages = new List<String> {'Product Image', 'Product Image Thumbnail', 'Product Search Image'};

    @AuraEnabled
    public static Map<String, Object> createProductMedia(String productId, String uri, String mediaType) {
        Map<String, Object> responseMap = new Map<String, Object>();

        Integer totAdd = 0;

        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');

        try {

            if(mediaType == 'Product Images (all three)') {

                deleteProductMediaImages(productId);

                for(String m : prodMediaImages) {

                    createRecord(productId, uri, m);
                    totAdd++;
                }
            }
            else {
                createRecord(productId, uri, mediaType);
                totAdd++;
            }

            responseMap.put('resultMsg', 'Total records created = ' + totAdd);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media created');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
            responseMap.put('errorMsg', e.getMessage());
        }

        return responseMap;
    }

    private static void createRecord(String productId, String uri, String mediaType) {
        ccrz__E_ProductMedia__c obj = new ccrz__E_ProductMedia__c();

        obj.ccrz__Enabled__c = true;
        obj.ccrz__MediaType__c = mediaType;
        obj.ccrz__ProductMediaSource__c = 'URI';
        obj.ccrz__Sequence__c = 500;
        obj.ccrz__Locale__c = 'en_US';
        obj.ccrz__URI__c = uri;
        obj.ccrz__StartDate__c = Date.today().addDays(-1);
        obj.ccrz__EndDate__c = Date.valueOf('2099-12-31');
        obj.ccrz__Product__c = productId;

        insert obj;
    }

    @AuraEnabled
    public static Map<String, Object> deleteProductMedia(String recordId) {
        Map<String, Object> responseMap = new Map<String, Object>();

        Integer totAdd = 0;

        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');

        try {

            ccrz__E_ProductMedia__c obj = new ccrz__E_ProductMedia__c();
            obj.Id = recordId;

            delete obj;

            totAdd++;

            responseMap.put('resultMsg', 'Total records deleted = ' + totAdd);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media deleted');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
            responseMap.put('errorMsg', e.getMessage());
        }

        return responseMap;
    }

    /*
        This method is used when updating the existing "big three" product media records.
     */
    private static void deleteProductMediaImages(String productId) {
        Map<String, Object> responseMap = new Map<String, Object>();

        Integer totDel = 0;

        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');

        try {

            List<ccrz__E_ProductMedia__c> productMediaList = [SELECT Id, Name FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c = :productId and ccrz__MediaType__c in :prodMediaImages];

            if(productMediaList.isEmpty()) {
                return;
            }

            totDel = productMediaList.size();

            delete productMediaList;

            totDel++;

            responseMap.put('resultMsg', 'Total records deleted = ' + totDel);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media deleted');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
            responseMap.put('errorMsg', e.getMessage());
        }

    }
    
    @AuraEnabled
    public static Map<String, Object> deleteAllProductMedia(String productId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        
        Integer totDel = 0;
        
        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');
        
        try {
            List<ccrz__E_ProductMedia__c> productMediaList = [SELECT Id, Name FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c = :productId];
            
            if(productMediaList.isEmpty()) {
                throw new CustomException('No Product Media to delete');
            }
            
            totDel = productMediaList.size();
            
            delete productMediaList;
            
            responseMap.put('resultMsg', 'Total records deleted = ' + totDel);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media to delete');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
        	responseMap.put('errorMsg', e.getMessage());
        }
        
        return responseMap;
    }

    @AuraEnabled
    public static Map<String, Object> deleteSelectedProductMedia(String productId, List<String>ids) {
        Map<String, Object> responseMap = new Map<String, Object>();

        Integer totDel = 0;

        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');

        try {
            List<ccrz__E_ProductMedia__c> productMediaList = [SELECT Id, Name FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c = :productId and Id in :ids];

            if(productMediaList.isEmpty()) {
                throw new CustomException('No Product Media to delete');
            }

            totDel = productMediaList.size();

            delete productMediaList;

            responseMap.put('resultMsg', 'Total records deleted = ' + totDel);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media to delete');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
            responseMap.put('errorMsg', e.getMessage());
        }

        return responseMap;
    }

    @AuraEnabled
    public static List<ccrz__E_ProductMedia__c> fetchAllProductMedia(String productId) {
        List<ccrz__E_ProductMedia__c> productMediaList = new List<ccrz__E_ProductMedia__c>();

        try {
            productMediaList = [SELECT Id, Name,
                    ccrz__Enabled__c,
                    ccrz__MediaType__c,
                    ccrz__ProductMediaSource__c,
                    ccrz__Sequence__c,
                    ccrz__Locale__c,
                    ccrz__URI__c,
                    ccrz__StaticResourceName__c,
                    ccrz__FilePath__c,
                    ccrz__StartDate__c,
                    ccrz__EndDate__c
            FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c = :productId];

            if(productMediaList.isEmpty()) {
                throw new CustomException('No Product Media to delete');
            }

        }
        catch(CustomException e) {

        }
        catch (Exception e) {

        }

        return productMediaList;
    }

    @AuraEnabled
    public static Map<String, Object> updateRecords(List<ccrz__E_ProductMedia__c> records){

        Map<String, Object> responseMap = new Map<String, Object>();

        System.debug('records: ');
        System.debug(records);

        Integer totUpd = records.size();

        responseMap.put('isError', false);
        responseMap.put('errorMsg', '');
        responseMap.put('resultMsg', '');
        
        try {
            
            update records;
            
            responseMap.put('resultMsg', 'Total records updated = ' + totUpd);
        }
        catch(CustomException e) {
            responseMap.put('resultMsg', 'No Product Media to update');
        }
        catch (Exception e) {
            responseMap.put('isError', true);
        	responseMap.put('errorMsg', e.getMessage());
        }
        
        return responseMap;
    }
    
    class CustomException extends Exception {}

}