/**
 * Created by brandon.rogers on 4/22/19.
 */

public with sharing class ckz_util_Utils {
    public ckz_util_Utils() {

    }

    public static ccrz.cc_RemoteActionResult initAction(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.inputContext = ctx;
        result.success = false;
        return result;
    }

    public static ccrz.cc_bean_Message buildExceptionMessage(Exception e) {
        ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
        msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
        msg.classToAppend = 'messagingSection-Error';
        msg.message = e.getStackTraceString() + ' ' + e.getMessage();
        msg.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
        return msg;
    }

    public static ccrz.cc_bean_Message buildErrorMessage(String message, String labelId, String classToAppend) {
        return buildMessage(message, labelId, classToAppend, ccrz.cc_bean_Message.MessageSeverity.ERROR);
    }

    public static ccrz.cc_bean_Message buildMessage(String message, String labelId, String classToAppend, ccrz.cc_bean_Message.MessageSeverity severity) {
        ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
        msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
        if (classToAppend != null)
            msg.classToAppend = classToAppend; else
                msg.classToAppend = 'messagingSection-Error';
        msg.message = message;
        msg.labelId = labelId;
        msg.severity = severity;
        return msg;
    }

    /**
     *
     * description
     *
     * @param: name	description
     * @return return_type
     */
    //public static String getAlternatePageLabelJSON(String storefront, String pageName, String language) {
    public static String getAlternatePageLabelJSON() {

        // get store name
        String storefront = ccrz.cc_util_storefront.getStoreName();
        if (String.isBlank(storefront)) {
            String storeName = Site.getPathPrefix();
            if (String.isNotBlank(storeName)) {
                Integer index = storeName.indexOf('/');
                if (index != -1) {
                    storeName = storeName.subString(index + 1);
                }
            }
            storefront = storeName;
        }

        // get page name
        String pageName = null;
        String reqPath = ApexPages.currentPage().getUrl();

        if (reqPath != null) {
            String subStr = reqPath;
            Integer idx1 = reqPath.lastIndexOf('/');
            Integer idx2 = reqPath.lastIndexOf('?');

            if (idx1 != -1 && idx2 != -1) {
                subStr = reqPath.subString(idx1 + 1, idx2);
            } else if (idx1 != -1 && idx2 == -1) {
                subStr = reqPath.substring(idx1 + 1);
            }

            String[] pageParts = subStr.split('__');
            if (pageParts.size() > 1) {
                pageName = pageParts[1];
            } else {
                pageName = pageParts[0];
            }
        }

        // get language
        String language = ccrz.cc_util_Locale.getUserLanguage();
        try {
            if (ApexPages.currentPage().getCookies().containsKey('ccr_landing_language')) {
                Cookie languageCookie = ApexPages.currentPage().getCookies().get('ccr_landing_language');
                language = languageCookie.getValue();
                System.debug('\n\n@@languageCookie: ' + languageCookie + '\n\n');
            }
        } catch (Exception e) {

        }

        final List<ccrz__E_PageLabel__c> pageLabels = null;
        if (String.isNotBlank(storefront)) {
            storefront = String.escapeSingleQuotes(storefront);
        } else {
            storefront = 'Global';
        }
        if (String.isNotBlank(language)) {
            language = String.escapeSingleQuotes(language);
        } else {
            language = 'en_US';
        }
        if (String.isNotBlank(pageName)) {
            pageName = String.escapeSingleQuotes(pageName);
        } else {
            pageName = 'All';
        }

        String childQuery = String.isNotBlank(language) ? ', (SELECT Id, ccrz__Value__c, ccrz__Language__c FROM ccrz__CC_PageLabeli18ns__r WHERE ccrz__Language__c=:language) ' : '';
        String mainQuery = 'SELECT e.ccrz__Value__c, e.ccrz__Storefront__c, e.ccrz__PageName__c, e.Name, e.Id, e.ccrz__Sequence__c ' + childQuery + ' FROM ccrz__E_PageLabel__c e WHERE (ccrz__storeFront__c = \'Global\' OR ccrz__storeFront__c=:storefront) AND (ccrz__pageName__c=\'All\' OR ccrz__pageName__c=:pageName)';
        mainQuery += ' ORDER BY e.ccrz__Sequence__c ASC';

        System.debug('\n\n@@storefront: ' + storefront + '\n\n');
        System.debug('\n\n@@language: ' + language + '\n\n');
        System.debug('\n\n@@pageName: ' + pageName + '\n\n');
        System.debug('\n\n@@mainQuery: ' + mainQuery + '\n\n');

        pageLabels = Database.query(mainQuery);

        System.debug('\n\n@@pageLabels: ' + pageLabels + '\n\n');

        if (pageLabels != null) {
            for (ccrz__E_PageLabel__c pl : pageLabels) {
                //supersede value__c in e_pagelabel__c with value__c in child i18n page label.
                List<ccrz__E_PageLabelI18N__c> ppls = pl.ccrz__CC_PageLabeli18ns__r;
                for (ccrz__E_PageLabelI18N__c pli18n : ppls) {
                    if (String.isNotBlank(pli18n.ccrz__Value__c)) {
                        pl.ccrz__Value__c = pli18n.ccrz__Value__c;
                        System.debug('\n\n@@pl.ccrz__Value__c: ' + pl.ccrz__Value__c + '\n\n');
                        System.debug('\n\n@@pli18n.ccrz__Value__c: ' + pli18n.ccrz__Value__c + '\n\n');
                    }
                }
            }
        }

        final Map<String, String> name2Label = new Map<String, String>();
        if (pageLabels != null) {
            for (ccrz__E_PageLabel__c pl : pageLabels) {
                if (storefront == pl.ccrz__Storefront__c && pageName == pl.ccrz__PageName__c) {
                    name2Label.put(pl.name, pl.ccrz__Value__c);
                } else if ('Global' == pl.ccrz__Storefront__c && pageName == pl.ccrz__PageName__c) {
                    name2Label.put(pl.name, pl.ccrz__Value__c);
                } else if (storefront == pl.ccrz__Storefront__c && 'All' == pl.ccrz__PageName__c) {
                    name2Label.put(pl.name, pl.ccrz__Value__c);
                } else {
                    name2Label.put(pl.name, pl.ccrz__Value__c);
                }
            }
        }

        return JSON.serialize(name2Label);
    }
}