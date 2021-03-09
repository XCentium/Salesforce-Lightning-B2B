/**
 * Created by brandon.rogers on 2019-06-03.
 */

global with sharing class ckz_ctrl_ProductCatalog {

    global String categoryMediaJSON { get; set; }

    global ckz_ctrl_ProductCatalog() {
        ccrz.ccLog.log('ckz_ctrl_ProductCatalog');

        getCategoryMedia();
    }

    global void getCategoryMedia() {
        ccrz.ccLog.log('ckz_ctrl_ProductCatalog:getCategoryMedia');

        Map<String, String> pageParams = ccrz.cc_CallContext.currPageParameters;

        ccrz.ccLog.log('ckz_ctrl_ProductCatalog:getCategoryMedia:pageParams', pageParams);

        String catString = pageParams.get('categoryId');
        ccrz.ccLog.log('ckz_ctrl_ProductCatalog:getCategoryMedia:catString', catString);

        List<ccrz__E_CategoryMedia__c> categoryMedia;

        if (catString != null) {
            Id catId = Id.valueOf(catString);

            categoryMedia = [
                    SELECT Id,
                            ccrz__Category__c,
                            ccrz__Category__r.Name,
                            ccrz__ProductMediaSource__c,
                            ccrz__FilePath__c,
                            ccrz__Locale__c,
                            ccrz__MediaType__c,
                            ccrz__StaticResourceName__c,
                            ccrz__URI__c
                    FROM ccrz__E_CategoryMedia__c
                    WHERE ccrz__Category__c = :catId AND ccrz__MediaType__c = 'Category Image'
            ];

            ccrz.ccLog.log('ckz_ctrl_ProductCatalog:getCategoryMedia:categoryMedia: ' + categoryMedia);
        }

        categoryMediaJSON = JSON.serialize(categoryMedia);
        ccrz.ccLog.log('ckz_ctrl_ProductCatalog:getCategoryMedia:categoryMediaJSON: ' + categoryMediaJSON);
    }

}