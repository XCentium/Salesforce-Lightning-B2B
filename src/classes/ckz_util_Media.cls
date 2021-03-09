/**
 * Created by brandon.rogers on 4/22/19.
 */

global with sharing class ckz_util_Media {
    public static String SITE_DOMAIN = '';
    public static String STORE_NAME = '';

    public ckz_util_Media(String Bottler) {
        //commenting below line for INC5070018
        // SITE_DOMAIN = System.URL.getSalesforceBaseUrl().gethost();//Added for GLCC
        //ckz_bean_CustomSettings cs = new ckz_bean_CustomSettings();
        //Uncommenting below line for INC5070018
        SITE_DOMAIN = 'cloudcrazetrial-15f77f93d41.force.com';//cs.getValue('Site', 'site_domain');
        STORE_NAME = 'Outlet';//cs.getValue('Site', 'store_name',Bottler);
    }


    /**
    *   Method used to retrieve the product media image.
    *   It will return it to a media wrapper bean that will hold all the necessary product media information.
    *
    *   @param List<String> product ids
    *   @param String media type (Product Image Thumbnail, Product Image, Product Search Image)
    *   @param String locale
    */
    public Map<Id, ckz_bean_MediaWrapper> getProductMedia(List<String> pids, String mediaType, String locale) {
        Date currDate = System.today();
        List<String> localeList = new List<String> ();


        if (locale == null || locale.trim().length() == 0 || locale == 'en_US') {
            //if locale is empty or equals 'en_US', localeList contains one "default" locale which is 'en_US'
            locale = 'en_US';
            localeList.add(locale);
            localeList.add(null);
        } else if (locale.containsIgnoreCase('fr')) {
            locale = 'fr%';
            localeList.add(locale);
            localeList.add(null);
        } else {
            //otherwise, localeList contains two locales, one is default locale 'en_US', the other one is user's locale
            localeList.add('en_US');
            localeList.add(locale);
            localeList.add(null);
        }

        Map<Id, ckz_bean_MediaWrapper> attachmentMap = new Map<Id, ckz_bean_MediaWrapper>();
        System.debug('======localeList--->' + localeList);
        System.debug('======mediaType--->' + mediaType);
        System.debug('======pids--->' + pids);
        List<ccrz__E_ProductMedia__c> pmList = [
                Select e.ccrz__AltMessage__c, e.ccrz__filePath__c, e.ccrz__EndDate__c, e.Id, e.ccrz__Product__c,
                        e.ccrz__Product__r.Id, e.ccrz__Product__r.Name, e.ccrz__Sequence__c, e.ccrz__StartDate__c, e.ccrz__URI__c,
                        e.ccrz__MediaType__c, ccrz__ProductMediaSource__c, ccrz__StaticResourceName__c, (SELECT Id, Name, ParentId FROM Attachments)
                from ccrz__E_ProductMedia__c e
                where e.ccrz__Product__r.Id in :pids
                and e.ccrz__MediaType__c = :mediaType
                and (e.ccrz__locale__c like :localeList)
                and e.ccrz__Enabled__c = true
                and (e.ccrz__StartDate__c = null or e.ccrz__StartDate__c <= :currDate)
                and (e.ccrz__EndDate__c = null or e.ccrz__EndDate__c >= :currDate)
        ];

        Map<Id, ckz_bean_MediaWrapper> attachmentMapFr = new Map<Id, ckz_bean_MediaWrapper>();
        for (ccrz__E_ProductMedia__c pm : pmList) {
            System.debug('=====ProductMediaSource__c--->' + pm);
            if ('Attachment' == pm.ccrz__ProductMediaSource__c) {
                List<Attachment> attachmentList = pm.Attachments;
                for (Attachment a : attachmentList) {
                    if (!(attachmentMap.containsKey(pm.ccrz__Product__c))) {
                        ckz_bean_MediaWrapper wrapper = new ckz_bean_MediaWrapper();
                        wrapper.uri = a.Id;
                        wrapper.sourceType = pm.ccrz__ProductMediaSource__c;
                        wrapper.altMessage = pm.ccrz__AltMessage__c;
                        wrapper.mediaName = a.Name;


                        wrapper.imageFullPath = 'https://' + SITE_DOMAIN + '/' + STORE_NAME + '/servlet/servlet.FileDownload?file=' + a.id;
                        attachmentMap.put(pm.ccrz__Product__c, wrapper);
                    }
                }
            } else if ('URI' == pm.ccrz__ProductMediaSource__c) {

                ckz_bean_MediaWrapper wrapper = new ckz_bean_MediaWrapper();
                wrapper.uri = pm.ccrz__URI__c;
                wrapper.sourceType = pm.ccrz__ProductMediaSource__c;
                wrapper.altMessage = pm.ccrz__AltMessage__c;
                //wrapper.mediaName = a.Name;
                wrapper.imageFullPath = pm.ccrz__URI__c;
                attachmentMap.put(pm.ccrz__Product__c, wrapper);
            }


        }
        system.debug('Attchment ===> ' + attachmentMap);
        return attachmentMap;
    }

    /**
    *   Method used to retrieve the category media image.
    *   It will return it to a media wrapper bean that will hold all the necessary product media information.
    *
    *   @param List<String> category ids
    *   @param String media type (Category Image Thumbnail, Category Image)
    *   @param String locale
    */
    public Map<Id, ckz_bean_MediaWrapper> getCategoryMedia(List<String> cids, String mediaType, String locale) //Modified for DSD Phase 2 Release 2||Modified to fetch locale/country and user type and get images specific to that locale.
    {
        String uType = UserInfo.getUserType();
        Date currDate = System.today();
        List<String> localeList = new List<String> ();
        if (locale == null || locale.trim().length() == 0 || locale == 'en_US') {
            //if locale is empty or equals 'en_US', localeList contains one "default" locale which is 'en_US'
            if (uType.containsIgnoreCase('Guest')) {
                localeList.add('en_CA');
                localeList.add(null);
            }
            locale = 'en_US';
            localeList.add(locale);
            localeList.add(null);
        } else if (locale.containsIgnoreCase('fr')) {
            locale = 'fr%';
            localeList.add(locale);
        } else {
            //otherwise, localeList contains two locales, one is default locale 'en_US', the other one is user's locale
            localeList.add(locale);
            localeList.add(null);
        }

        Map<Id, ckz_bean_MediaWrapper> attachmentMap = new Map<Id, ckz_bean_MediaWrapper>();
        System.debug('======localeList--->' + localeList);
        System.debug('======mediaType--->' + mediaType);
        System.debug('======cids--->' + cids);
        List<ccrz__E_CategoryMedia__c> cmList = [
                Select e.ccrz__AltMessage__c, e.ccrz__FilePath__c, e.ccrz__EndDate__c, e.Id, e.ccrz__Category__c,
                        e.ccrz__Category__r.Id, e.ccrz__Category__r.Name, e.ccrz__Sequence__c, e.ccrz__StartDate__c, e.ccrz__URI__c,
                        e.ccrz__MediaType__c, ccrz__ProductMediaSource__c, ccrz__StaticResourceName__c, (SELECT Id, Name, ParentId FROM Attachments)
                from ccrz__E_CategoryMedia__c e
                where e.ccrz__Category__r.Id in :cids
                and e.ccrz__MediaType__c = :mediaType
                //and (e.MediaLocale__c like :localeList)
                and e.ccrz__Enabled__c = true
                and (e.ccrz__StartDate__c = null or e.ccrz__StartDate__c <= :currDate)
                and (e.ccrz__EndDate__c = null or e.ccrz__EndDate__c >= :currDate)
                order by e.ccrz__Sequence__c asc nulls last
        ];
        for (ccrz__E_CategoryMedia__c cm : cmList) {
            System.debug('=====CategoryMediaSource__c--->' + cm);
            if ('Attachment' == cm.ccrz__ProductMediaSource__c) {
                List<Attachment> attachmentList = cm.Attachments;
                for (Attachment a : attachmentList) {
                    if (!(attachmentMap.containsKey(cm.ccrz__Category__c))) {
                        ckz_bean_MediaWrapper wrapper = new ckz_bean_MediaWrapper();
                        wrapper.uri = a.Id;
                        wrapper.sourceType = cm.ccrz__ProductMediaSource__c;
                        wrapper.altMessage = cm.ccrz__AltMessage__c;
                        wrapper.mediaName = a.Name;
                        wrapper.position = (Integer) cm.ccrz__Sequence__c;

                        wrapper.imageFullPath = 'https://' + SITE_DOMAIN + '/' + STORE_NAME + '/servlet/servlet.FileDownload?file=' + a.id;
                        System.debug('=====media wrapper--->' + wrapper);
                        attachmentMap.put(cm.ccrz__Category__c, wrapper);
                    }
                }
            }
        }
        return attachmentMap;
    }

    /**
    *   Method used to retrieve the customized Coke Specials media images.
    *   It will return it to a media wrapper bean that will hold all the necessary media information.
    *
    *   @param String locale
    */
    /*
    public List<ckz_bean_MediaWrapper> retrieveSpecials(String accountId, String locale)
    {
        Date currDate = System.today();
        List<String> localeList = new List<String> ();
        if(locale == null || locale.trim().length() == 0 || locale == 'en_US')
        {
            //if locale is empty or equals 'en_US', localeList contains one "default" locale which is 'en_US'
            locale='en_US';
            localeList.add(locale);
            localeList.add(null);
        }
        else if(locale.containsIgnoreCase('fr')){
            locale='fr%';
            localeList.add(locale);
        }
        else
        {
            //otherwise, localeList contains two locales, one is default locale 'en_US', the other one is user's locale
            localeList.add('en_US');
            localeList.add(locale);
            localeList.add(null);
        }

        List<ckz_bean_MediaWrapper> wrapperList = new List<ckz_bean_MediaWrapper>();
        System.debug('======localeList--->' + localeList);

        List<CCR_Specials__c> specialsList = [Select e.Account__c, e.AltMessage__c, e.FilePath__c, e.EndDate__c, e.Name, e.StartDate__c, e.Position__c, e.SKU__c,
                                            (SELECT Id, Name, ParentId FROM Attachments)
                                            from CCR_Specials__c e
                                            where e.Account__c = :accountId
                                            and (e.Locale__c like :localeList)
                                            and e.Enabled__c = true
                                            and (e.StartDate__c = null or e.StartDate__c <= :currDate)
                                            and (e.EndDate__c = null or e.EndDate__c >= :currDate)
                                            order by e.Position__c];
        System.debug('======accountId--->' + accountId);
        System.debug('======specialsList size--->' + specialsList.size());

        for(CCR_Specials__c sp: specialsList)
        {
            List<Attachment> attachmentList = sp.Attachments;
            for(Attachment a: attachmentList)
            {
                ckz_bean_MediaWrapper wrapper = new ckz_bean_MediaWrapper();
                wrapper.uri = a.Id;
                wrapper.altMessage = sp.AltMessage__c;
                wrapper.mediaName = a.Name;
                wrapper.position = (Integer) sp.Position__c;
                wrapper.description = sp.SKU__c;

                wrapper.imageFullPath = 'https://' + SITE_DOMAIN + '/' + STORE_NAME + '/servlet/servlet.FileDownload?file='+a.id;
                wrapperList.add(wrapper);
            }
        }
        return wrapperList;
    }*/
}