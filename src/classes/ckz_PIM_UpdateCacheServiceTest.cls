/**
 * Created by msobczak on 2/21/2019.
 */

@IsTest
private class ckz_PIM_UpdateCacheServiceTest {
    @IsTest
    static void testBehavior() {

//        Map<String,Map<String,Object>> inpData = new Map<String, Map<String, Object>>();
//        inpData.put(ccrz.ccApiTestData.DATAOPTIONS, null);
//
//        ccrz.ccApiTestData.setupData(inpData);

//        ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>> {
//                ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object> {
//                        'DefaultStore' => new Map<String,Object> {
//                                'Languages__c' => 'en_US,ja_JP'
//                        }
//                },
//                ccrz.ccApiTestData.CONFIG_SETTINGS => new Map<String,Object>{
//                        'ls.enabled' => 'true'
//                        ,'pi.usehk' => 'true'
//                        ,'sel.enabled' => 'true'
//                }
//        });
        //cc_test_TestDataSetup.loadData();

        //String configJSON = '[{"ConfigurationMetas":[{"Name":"a1s610000014pwU","APIName":"enabled","Description":"TRUE/FALSE: Show/Hide Company Social Widget","ExternallySafe":false,"Configurations":[{"TextValue":"TRUE","Storefront":"global","PageName":"all","Name":"a1t61000000UImC"}]}],"APIName":"csw","Name":"Company Social Widget"},{"ConfigurationMetas":[{"Name":"a1s610000014ptV","APIName":"enabled","Description":"TRUE/FALSE: Enable the top menu section","ExternallySafe":false,"Configurations":[{"TextValue":"TRUE","Storefront":"global","PageName":"all","Name":"a1t61000000UIjD"}]}],"APIName":"tm","Name":"Top Menu"}]';
//
//        Map<String, Object> inputData = new Map<String, Object>{
//                ccrz.ccApi.API_VERSION => 1,
//                ccrz.ccApiConfig.CONFIG_JSON => configJSON};
//
//        ccrz.ccApiConfig.setBulk(inputData);

//        E_StorefrontSettings__c sf = new E_StorefrontSettings__c(name='DefaultStore', Root_Category_ID__c='rootCatId', DefaultLocale__c='en_US');
//        INSERT sf;

        //ccrz.cc_hlpr_InitLoadCustomSettings.loadCloudCrazeApplicationSettings();
        //ccrz.cc_hlpr_InitLoadCustomSettings.loadCloudCrazeStorefrontSettings();

//        Map<String,Object> inpData = new Map<String,Object>{
//                'DefaultStore' => null
//        };
//
//        E_StorefrontSettings__c newStore = new E_StorefrontSettings__c(
//                Name = (Object)'DefaultStore'
//                ,ALLOW_ANONYMOUS_BROWSING__C = true
//                ,CURRENCIES__C = 'USD'
//                ,LANGUAGES__C = 'en_US'
//                ,CUSTOMER_PORTAL_ACCOUNT_NAME__C = 'PortalAccount'
//                ,CUSTOMERPORTALACCTGROUPNAME__C = 'PortalAccount'
//                ,DEFAULTCURRENCYCODE__C = 'USD'
//                ,DEFAULTLOCALE__C = 'en_US'
//                ,INVENTORYCHECKFLAG__C = false
//                ,QUOTING_ENABLED__C = true
//                ,ROOT_CATEGORY_ID__C = '999999'
//                ,SEARCHRANK_EXACTPRODUCTNUM__C = 700.0
//                ,SEARCHRANK_SHORTDESC__C = 50.0
//                ,SEARCHRANK_INDISPLAYNAME__C = 200.0
//                ,SEARCHRANK_INPRODNUM__C = 100.0
//                ,SKIP_TAX_CALCULATION__C = false
//                ,BASEPRICELIST__C = 'Enterprise'
//                ,Filter_Orders_Based_on_Owner__c = true
//        );

        Test.startTest();

        ckz_PIM_UpdateCacheService.doUpdate();

        Test.stopTest();


    }
}