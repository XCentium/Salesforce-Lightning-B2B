/**
 * Created by msobczak on 7/18/2018.
 */

@RestResource(urlMapping='/ckzSdoConfigUpdate')
global with sharing class CkzSDOConfigUpdateService {

    @HttpGet
    global static List<String> doGet() {

        List<String> messages = new List<String>();

        // Get all of the Storefronts defined in the Org.

        System.debug('Get all of the Storefronts defined in the Org.');

        Set<String> storefronts = new Set<String>();

        List<AggregateResult> configs = [SELECT ccrz__Storefront__c FROM ccrz__E_Configuration__c GROUP BY ccrz__Storefront__c];

        for(AggregateResult ag : configs) {
            storefronts.add((String)ag.get('ccrz__Storefront__c'));
        }

        // Get all of the Communities defined in the Org.

        System.debug('Get all of the Communities defined in the Org.');

        ConnectApi.CommunityPage communityPage = ConnectApi.Communities.getCommunities();

        List<ConnectApi.Community> communities = communityPage.communities;

        for(ConnectApi.Community community : communities) {

            System.debug(community.name + ' / ' + community.status + ' / ' + community.siteUrl);

            String siteUrl = community.siteUrl;

            Integer pos = siteUrl.lastIndexOf('/');

            String newDomain = siteUrl.substring(0, pos);  System.debug('newDomain: ' + newDomain);
            String newUnsecureDomain = newDomain.replaceFirst('https:', 'http:');  System.debug('newUnsecureDomain: ' + newUnsecureDomain);

            String communityStorefrontName = siteUrl.substring(pos + 1);

            if(storefronts.contains(communityStorefrontName)) {

                System.debug('storefront found: ' + communityStorefrontName);

                ccrz.ccContext ctx = new ccrz.ccContext();
                ctx.storefront = communityStorefrontName;
                ccrz.cc_CallContext.initContext(ctx);
                Map<String, Object> sfSettings = ccrz.cc_CallContext.storeFrontSettings;

                // Get the current settings

                String currentSiteUnsecureDomain = (String) sfSettings.get('Site_Unsecure_Domain__c');
                String currentSiteSecureDomain = (String) sfSettings.get('Site_Secure_Domain__c');

                if((currentSiteSecureDomain != newDomain) || (currentSiteUnsecureDomain != newUnsecureDomain)) {

                    System.debug('updating storefront: ' + communityStorefrontName);

                    ccrz.cc_util_Reflection.updateStoreFrontSettings(communityStorefrontName, 'Site_Unsecure_Domain__c', newUnsecureDomain);
                    ccrz.cc_util_Reflection.updateStoreFrontSettings(communityStorefrontName, 'Site_Secure_Domain__c', newDomain);

                    messages.add('Storefront updated: ' + communityStorefrontName);
                }

            }
        }

        if(messages.size() == 0) {
            messages.add('No storefronts updated');
        }

        return messages;
    }

}