/**
 * Created by msobczak on 2/27/2019.
 *
 * Several lines of code below have CPQ Connector dependencies been commented out.
 * Uncomment those lines after you have installed the CPQ Connector.
 *
 */

public with sharing class ckz_OrderFormPanelController {

    @AuraEnabled
    public static Map<String, Object> fetchInfo(String recordId) {

        Id contactId = null;

        System.debug('recordId = ' + recordId);

        Map<String, Object> userInfoMap = createUserInfoMap();

        if(recordId == null) {
            return userInfoMap;
        }

        String objectName = findObjectNameFromRecordIdPrefix(recordId);
        System.debug('objectName: ' + objectName);

        if(recordId.startsWith('500')) {
            // Case object
            Case caseObj = [Select Id, CaseNumber, ContactId from Case where Id = :recordId];

            if(caseObj != null) {
                contactId = caseObj.ContactId;
                System.debug('contactId from case = ' + contactId);
            }
        }
        else if(objectName.equals('ccrz__E_Cart__c')) {
            // CC Cart object

            System.debug('getting info from CC Cart');
            getInfoFromCartObj(recordId, userInfoMap);
            contactId = (String)userInfoMap.get('contactId');

        }
        else if(objectName.equalsIgnoreCase('SBQQ__Quote__c')) {

            // CPQ Quote object

            // CPQ Dependency: uncomment the following lines after you have the CPQ connector installed.
            //SBQQ__Quote__c quoteObj = [Select Id, Name, Ecommerce_Cart__c from SBQQ__Quote__c where Id = :recordId];
            //Id cartId = quoteObj.Ecommerce_Cart__c;
            //getInfoFromCartObj(cartId, userInfoMap);

            contactId = (String)userInfoMap.get('contactId');

        }
        else if(recordId.startsWith('005')) {
            // Starting with a User object (Community page)
            User user = [Select Id, Name, ContactId from User where Id = :recordId];
            contactId = user.ContactId;
        }
        else if(recordId.startsWith('003')) {
            // Starting with a Contact object
            contactId = recordId;
        }
        else {
            // Unrecognized record in underlying page
            contactId = null;
        }

        Contact contact = null;
        ccrz__E_AccountGroup__c ag = null;
        Account account = null;
        User user = null;

        System.debug('fetching contact: ' + contactId);

        if(contactId != null) {
            
            List<Contact> contactList = [Select Id, Name, AccountId from Contact where Id = :contactId];

            if(contactList.size() > 0) {
                contact = contactList.get(0);
            }

            if(contact != null) {
                account = [Select Id, Name, ccrz__E_AccountGroup__c from Account where Id = :contact.AccountId];
                List<User> userList = [Select Id, Name, LocaleSidKey, ccrz__CC_CurrencyCode__c from User where ContactId = :contactId];

                if(userList.size() > 0) {
                    user = userList.get(0);
                }
            }

            if(account != null && account.ccrz__E_AccountGroup__c != null) {
                ag = [Select Id, Name from ccrz__E_AccountGroup__c where Id = :account.ccrz__E_AccountGroup__c];
            }

            userInfoMap.put('objectApiName', objectName);
            userInfoMap.put('contactId', contactId);
            
            // 2020-04-28  msobczak: added
            if(ag != null) {
            	userInfoMap.put('accountGroupName', ag.Name);
            	userInfoMap.put('accountGroup', ag);
            }

            if(account != null) {
                userInfoMap.put('accountId', account.Id);
                userInfoMap.put('accountName', account.Name);
            }
            
            if(user != null) {
                userInfoMap.put('userId', user.Id);
                userInfoMap.put('locale', user.LocaleSidKey);
                userInfoMap.put('userName', user.Name);
                userInfoMap.put('currencyCode', user.ccrz__CC_CurrencyCode__c);
            }
        }

        return userInfoMap;
    }

    private static void getInfoFromCartObj(String recordId, Map<String, Object> userInfoMap) {

        // CPQ Dependency: uncomment the first line and comment the second line after you have the CPQ connector installed.
        //ccrz__E_Cart__c cartObj = [Select Id, Name, ccrz__Contact__c, ccrz__EncryptedId__c, ccrz__Storefront__c, Quote__c, ccrz__CartStatus__c, ccrz__EffectiveAccountID__c from ccrz__E_Cart__c where Id = :recordId];
        ccrz__E_Cart__c cartObj = [Select Id, Name, ccrz__Contact__c, ccrz__EncryptedId__c, ccrz__Storefront__c, ccrz__CartStatus__c, ccrz__EffectiveAccountID__c from ccrz__E_Cart__c where Id = :recordId];

        Id contactId = cartObj.ccrz__Contact__c;

        userInfoMap.put('cartId', cartObj.Id);
        userInfoMap.put('cartEncryptedId', cartObj.ccrz__EncryptedId__c);
        userInfoMap.put('selectedObjectName', 'cart');
        userInfoMap.put('orderType', 'cart');
        userInfoMap.put('selectedStorefront', cartObj.ccrz__Storefront__c);
        userInfoMap.put('contactId', contactId);
        userInfoMap.put('cartStatus', cartObj.ccrz__CartStatus__c);

        // CPQ Dependency: uncomment the following line after you have the CPQ connector installed.
        //userInfoMap.put('quoteId', cartObj.Quote__c);
    }

    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                //System.debug('Prefix is ' + prefix);

                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    private static Map<String, Object> createUserInfoMap() {
        Map<String, Object> userInfoMap = new Map<String, Object>();

        userInfoMap.put('accountGroupName', null);
        userInfoMap.put('accountGroup', null);

        userInfoMap.put('objectApiName', null);
        userInfoMap.put('contactId', null);
            
        userInfoMap.put('accountGroupName', null);
        userInfoMap.put('accountGroup', null);

        userInfoMap.put('accountId', null);
        userInfoMap.put('accountName', null);
        userInfoMap.put('userId', null);
        userInfoMap.put('locale', null);
        userInfoMap.put('userName', null);
        userInfoMap.put('currencyCode', null);

        userInfoMap.put('cartId', null);
        userInfoMap.put('cartEncryptedId', null);
        userInfoMap.put('selectedObjectName', null);
        userInfoMap.put('orderType', null);
        userInfoMap.put('selectedStorefront', null);
        userInfoMap.put('contactId', null);
        userInfoMap.put('cartStatus', null);

        return userInfoMap;
    }

}