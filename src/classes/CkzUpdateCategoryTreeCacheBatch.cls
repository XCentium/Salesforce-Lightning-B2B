global with sharing class CkzUpdateCategoryTreeCacheBatch implements Database.batchable<String>, Database.AllowsCallouts {
    
public List<String> storefrontList = new List<String>();
    private final Datetime buildTS;

    public boolean sendEmailDebug = false;

    public CkzUpdateCategoryTreeCacheBatch(List<String> temp) {
        storefrontList = temp;

        buildTS = Datetime.now();
    }

    global List<String> start(Database.BatchableContext BC) {
        return storefrontList;
    }

    global void execute(Database.BatchableContext BC, List<String> batch) {

        String emailBody = '';

        try {

            Set<Object> storefrontSet = new Set<Object>();
            storefrontSet.add(batch.get(0));

            Set<Object> localeObjectSet = new Set<Object>();
            Set<String> localeStringSet = new Set<String>();

            Set<Object> rootCategoryIdSet = new Set<Object>();

            Object storefront = batch.get(0);

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

            System.debug('storefrontSet: ' + batch);
            //messages.add('storefrontSet: ' + storefrontSet);
            emailBody += '<p>storefrontSet: ' + JSON.serialize(storefrontSet) + '</p>';

            System.debug('localeSet: ' + localeObjectSet);
            //messages.add('localeSet: ' + localeObjectSet);
            emailBody += '<p>localeObjectSet: ' + JSON.serialize(localeObjectSet) + '</p>';

            System.debug('rootCategoryIdSet: ' + rootCategoryIdSet);
            //messages.add('rootCategoryIdSet: ' + rootCategoryIdSet);
            emailBody += '<p>rootCategoryIdSet: ' + JSON.serialize(rootCategoryIdSet) + '</p>';

            // Category Tree Cache

            //Id catBatchJobId = Database.executeBatch(new ccrz.ccCategoryCacheBuildJob(storefrontSet, rootCategoryIdSet, localeObjectSet, new Map<String, Object>()), 1000);

            ccrz.ccMultiSetIterator iterator = new ccrz.ccMultiSetIterator(new List<Set<Object>>{storefrontSet,rootCategoryIdSet,localeObjectSet});

            List<List<Object>> scope = new List<List<Object>>();
            while(iterator.hasNext()) {
                scope.add(iterator.next());
            }

            executeCategoryCacheRefresh(BC, scope);

        } catch (Exception e) {

            emailBody += '<p>Exception: ' + e.getMessage() + '</p>';
            emailBody += '<p>Line #: ' + e.getLineNumber() + '</p>';
        }

        sendEmailMsg(emailBody);

    }

    global void finish(Database.BatchableContext BC) {
        (new ccrz.ccCategoryCacheBuilder()).disableOld(new Map<String, Object>());
    }

    global void executeCategoryCacheRefresh(Database.BatchableContext bc, List<List<Object>> scope){
        for(List<Object> cacheScope:scope){
            String storefrontName = (String)cacheScope[0];
            String rootCategoryId = (String)cacheScope[1];
            String categoryLocale = (String)cacheScope[2];

            Map<String,Object> returnData = ccrz.ccAPICategory.fetchCategoryTree(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                    ccrz.ccApiCategory.ROOTCATEGORYID => rootCategoryId,
                    ccrz.ccApiCategory.CATEGORYLOCALE => categoryLocale,
                    ccrz.ccAPICategory.STOREFRONT => storefrontName
            });

            String categoryTreeJSON = JSON.serialize((List<Map<String,Object>>)returnData.get(ccrz.ccAPICategory.CATEGORYTREE));

            Map<String,Object> writeRes = ccrz.ccApiPublicCache.startWrite(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                    ccrz.ccApiPublicCache.CACHE_NAME => ccrz.ccCategoryCacheBuilder.CACHE_NAME,
                    ccrz.ccApiPublicCache.STORE_NAME => storefrontName,
                    ccrz.ccApiPublicCache.PAGENAME => 'all',
                    ccrz.ccApiPublicCache.LOCALE => categoryLocale,
                    ccrz.ccApiPublicCache.BUILD_GROUP => (String)bc.getJobId(),
                    ccrz.ccApiPublicCache.BUILD_TIMESTAMP => buildTS
            });

            Map<String,Object> appendRes = ccrz.ccApiPublicCache.appendTo(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                    ccrz.ccApiPublicCache.CACHE_NAME => ccrz.ccCategoryCacheBuilder.CACHE_NAME,
                    ccrz.ccApiPublicCache.CONTEXT => writeRes.get(ccrz.ccApiPublicCache.CONTEXT),
                    ccrz.ccApiPublicCache.CONTENT => categoryTreeJSON
            });

            ccrz.ccApiPublicCache.close(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                    ccrz.ccApiPublicCache.CACHE_NAME => ccrz.ccCategoryCacheBuilder.CACHE_NAME,
                    ccrz.ccApiPublicCache.CONTEXT => appendRes.get(ccrz.ccApiPublicCache.CONTEXT)
            });
        }
    }

    private void sendEmailMsg(String emailBody) {

        if (sendEmailDebug == false) {
            return;
        }

        List<Messaging.SingleEmailMessage> mails =
                new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        sendTo.add('msobczak@salesforce.com');
        mail.setToAddresses(sendTo);

        // Step 3: Set who the email is sent from
        mail.setReplyTo('msobczak@salesforce.com');
        mail.setSenderDisplayName('Michael Sobczak');

        mail.setSubject('CkzUpdateCategoryTreeCacheBatch log');

        mail.setHtmlBody(emailBody);

        mails.add(mail);

        Messaging.sendEmail(mails);
    }

}