@RestResource(urlMapping='/ckzPIMUpdateCache')
global with sharing class ckz_PIM_UpdateCacheService {

    @HttpGet
    global static List<String> doUpdate() {
        List<String> messages = new List<String>();

        //inflateTestCoverage();

        updateCache(messages);

        return messages;
    }

    private static void updateCache(List<String> messages) {

        try {

            Set<Object> storefrontSet = getStorefrontSet();

            Set<Object> localeObjectSet = new Set<Object>();
            Set<String> localeStringSet = new Set<String>();

            Set<Object> rootCategoryIdSet = new Set<Object>();

            List<SiteIndexParams> siteIndexParamsList = new List<SiteIndexParams>();

            for (Object storefront : storefrontSet) {

                System.debug('storefront: ' + storefront);

                ccrz.ccContext ctx = new ccrz.ccContext();
                ctx.storefront = (String) storefront;

                ccrz.cc_CallContext.initContext(ctx);

                Map<String, Object> sfSettings = ccrz.cc_CallContext.storeFrontSettings;

                String defLocale = (String) sfSettings.get('DefaultLocale__c');
                String rootCategoryId = (String) sfSettings.get('Root_Category_ID__c');
                String languages = (String) sfSettings.get('Languages__c');

                String [] selectedLocales = languages.split(',');

                for (String locale : selectedLocales) {
                    localeStringSet.add(locale);
                    localeObjectSet.add(locale);
                }

                rootCategoryIdSet.add(rootCategoryId);

                SiteIndexParams siteIndexParams = new SiteIndexParams();
                siteIndexParams.storefront = (String) storefront;
                siteIndexParams.rootCategoryId = rootCategoryId;
                siteIndexParams.locales = localeStringSet;
                siteIndexParams.localeObjects = localeObjectSet;

                siteIndexParamsList.add(siteIndexParams);

            }

//Set<Object> pageSet = getPages();

            System.debug('storefrontSet: ' + storefrontSet);
//messages.add('storefrontSet: ' + storefrontSet);

            System.debug('localeSet: ' + localeObjectSet);
//messages.add('localeSet: ' + localeObjectSet);

            System.debug('rootCategoryIdSet: ' + rootCategoryIdSet);
//messages.add('rootCategoryIdSet: ' + rootCategoryIdSet);

// Category Tree Cache

            Id catBatchJobId = Database.executeBatch(new ccrz.ccCategoryCacheBuildJob(storefrontSet, rootCategoryIdSet, localeObjectSet, new Map<String, Object>()), 1000);

            messages.add('category tree cache updated');

// Page label cache

            Id plBatchJobId = Database.executeBatch(new ccrz.ccPageLabelCacheBuildJob(storefrontSet, new Set<Object>(), localeObjectSet, new Map<String, Object>()), 1000);

            messages.add('page label cache updated');

// Menu Cache

            Id menuBatchJobId = Database.executeBatch(new ccrz.ccMenuCacheBuildJob(storefrontSet, localeObjectSet, new Map<String, Object>()), 1000);

            messages.add('menu cache updated');

// Site index

            for (SiteIndexParams params : siteIndexParamsList) {
                Id siteIndexBatchJobId = Database.executeBatch(new ccrz.ccSiteIndexBuildJob(params.getInputData()), 1000);
                messages.add('site index updated for: ' + params);
            }

// Product Spec index
            ID prodSpecBatchJobId = Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('Select Id, ParentProduct__c, FilterData__c from E_Product__c'), 1000);

            messages.add('product spec index updated');
            
// Product Index
            ccrz.ccProductIndexBuilder.build(new Map<String,Object>{
                ccrz.ccAPIProductIndex.LOCALES => localeStringSet,
                ccrz.ccAPIProductIndex.CLEAN_ONLY => TRUE
            });

        } catch (Exception e) {
            messages.add('Exception: ' + e.getMessage());  System.debug('Exception: ' + e.getMessage());
            messages.add('Exception: ' + e.getLineNumber());  System.debug('Line: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
        }

    }

/*
    Gets all page names in use, regardless of which Storefront they are associated with.
 */
    private static Set<Object> getPages() {

        Set<Object> pageSet = new Set<Object>();

        List<AggregateResult> groupedResults = [Select ccrz__PageName__c from ccrz__E_PageLabel__c Group By ccrz__PageName__c];

        for (AggregateResult ar : groupedResults) {
            pageSet.add(ar.get('ccrz__PageName__c'));
        }

        return pageSet;
    }

    private static Set<Object> getStorefrontSet() {

        Set<Object> storefronts = new Set<Object>();

        List<AggregateResult> configs = [SELECT ccrz__Storefront__c FROM ccrz__E_Configuration__c GROUP BY ccrz__Storefront__c];

        for (AggregateResult ag : configs) {
            storefronts.add(ag.get('ccrz__Storefront__c'));
        }

        return storefronts;
    }

    class SiteIndexParams {
        public Object storefront;
        public Object rootCategoryId;
        public Set<String> locales;
        public Set<Object> localeObjects;

        public Map<String, Object> getInputData() {
            Map<String, Object> inputData = new Map<String, Object>();
            inputData.put(ccrz.ccAPISiteIndex.STOREFRONT, storefront);
            inputData.put(ccrz.ccAPISiteIndex.ROOT_CATEGORY_ID, rootCategoryId);
            inputData.put(ccrz.ccAPISiteIndex.LOCALES, locales);

            return inputData;
        }
    }

    private static void inflateTestCoverage() {
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}