global with sharing class ckz_ctrl_UserRolesMyAccount {

    /*
     * Used in My Account
     */

    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchUserRolesForUserAccount(ccrz.cc_RemoteActionContext ctx) {

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:E', 'fetchPriceGroupsForUser');
        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        response.success = false;
        response.inputContext = ctx;

        System.debug('currAccountId: ' + ccrz.cc_CallContext.currAccountId);
        System.debug('ctx.effAccountId: ' + ctx.effAccountId);
        System.debug('currPageParameters: ' + ccrz.cc_CallContext.currPageParameters);
        System.debug('isRemoteCall: ' + ccrz.cc_CallContext.isRemoteCall);

        Map<String, Object> dataMap = new Map<String, Object>();

        try {
            String effectiveAccountId = '';

            if(ctx.effAccountId != null && ctx.effAccountId != '') {
                effectiveAccountId = ctx.effAccountId;
            }
            else {
                effectiveAccountId = ccrz.cc_CallContext.effAccountId;
            }

            System.debug('effectiveAccountId: ' + effectiveAccountId);

            ccrz.cc_CallContext.initRemoteContext(ctx);

            List<Contact> contactList = new List<Contact>();
            List<ckz_bean_UserRoles> roleList = new List<ckz_bean_UserRoles>();

            String accId = ccrz.cc_CallContext.effAccountId;
            Id myContactId = ccrz.cc_CallContext.currContact.Id;

            Contact myContact = [SELECT ckz_Budget_Administrator__c FROM Contact where Id = :myContactId];
            Boolean canSetRoles = myContact.ckz_Budget_Administrator__c;

            if (canSetRoles) {

                String eff_enabled = getConfigSetting('eff.enabled', 'all', ccrz.cc_CallContext.storefront);

                String budlimftchmode = getConfigSetting('ma.budlimftchmode', 'all', ccrz.cc_CallContext.storefront);

                if(eff_enabled == 'TRUE') {
                    if(budlimftchmode == 'ParentHierarchy') {
                        contactList = getContactListEffAccts(accId);
                    }
                    else {
                        contactList = getContactListStandard(accId);
                    }
                }
                else {
                    contactList = getContactListStandard(accId);
                }

                for (Contact c : contactList) {
                    ckz_bean_UserRoles roles = new ckz_bean_UserRoles();
                    roles.canOrder = c.ckz_Budget_Can_Order__c;
                    roles.budgetLimit = c.ckz_Budget_Limit__c;
                    roles.requiresApproval = c.ckz_Budget_Requires_Approval__c;
                    roles.isAdmin = c.ckz_Budget_Administrator__c;
                    roles.lastName = c.LastName;
                    roles.firstName = c.FirstName;
                    roles.contactId = c.Id;
                    roleList.add(roles);
                }
            }

            dataMap.put('canSetRoles', canSetRoles);
            dataMap.put('userRoles', roleList);

            response.data = dataMap;
            response.success = true;
        } catch (Exception ex) {
            ccrz.ccLog.log('ckz_ctrl_UserRoles:fetchUserRolesForUserAccount:responseFalse');
            response.success = false;
            ccrz.ccLog.log(LoggingLevel.ERROR, 'message', ex.getMessage());
        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'fetchUserRolesForUserAccount');
            ccrz.ccLog.close(response);
        }

        ccrz.ccLog.log('ckz_ctrl_UserRoles:fetchUserRolesForUserAccount:response: ' + response);
        return response;

    }

    private static string getConfigSetting(String settingName, String page, String storefront) {
        String settingValue = '';

        Map<String,Object> inputConfigData = new Map<String,Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                ,ccrz.ccApiConfig.STORE_NAME => storefront
                ,ccrz.ccApiConfig.PAGE_NAME => page
                ,ccrz.ccApiConfig.USE_CACHE => TRUE
                ,ccrz.ccApiConfig.EXTERNALLY_SAFE => FALSE
                ,ccrz.ccApiConfig.RETURN_SERIAL => FALSE
        };

        Map<String, String> configMap = (Map<String, String>)ccrz.ccAPIConfig.fetch(inputConfigData).get(ccrz.ccAPIConfig.CONFIGURATIONS);

        settingValue = configMap.get(settingName);


        return settingValue;
    }

    private static List<Contact> getContactListStandard(String accId) {

        System.debug('getContactListStandard');

        List<Contact> contactList = [
                SELECT Id, FirstName, LastName,
                        ckz_Budget_Administrator__c, ckz_Budget_Can_Order__c,
                        ckz_Budget_Requires_Approval__c, ckz_Budget_Limit__c
                FROM Contact
                WHERE AccountId = :accId
                ORDER BY LastName ASC
        ];

        return contactList;
    }

    private static List<Contact> getContactListEffAccts(String accId) {

        System.debug('getContactListEffAccts');

        List<Contact> contactList = new List<Contact>();

        // Get the current account object.
        Account currentAccount = [SELECT Id, Name, ckz_Id18__c, ckz_Account_Hierarchy_Id18s__c FROM Account WHERE Id = :accId];
        String id18 = currentAccount.ckz_Id18__c;
        ccrz.ccLog.log('ckz_ctrl_UserRoles - id18: ' + id18);
        System.debug('ckz_ctrl_UserRoles - id18: ' + id18);

        String likeString = '%' + id18 + '%';

        // Get all accounts with this parent in the hierarchy
        List<Account> accountList = [SELECT Id, Name,
        (SELECT Id, FirstName, LastName,
                ckz_Budget_Administrator__c, ckz_Budget_Can_Order__c,
                ckz_Budget_Requires_Approval__c, ckz_Budget_Limit__c
        FROM Contacts
        ORDER BY LastName ASC)
        FROM Account
        WHERE ckz_Account_Hierarchy_Id18s__c like :likeString];

        ccrz.ccLog.log('ckz_ctrl_UserRoles - accountList.size = ' + accountList.size());

        // Put all of the contacts into a List for sorting
        List<ContactWrapper> contactWrappers = new List<ContactWrapper>();
        for(Account account : accountList) {
            for(Contact contact : account.Contacts) {
                ContactWrapper wrapper = new ContactWrapper(contact);
                contactWrappers.add(wrapper);
            }
        }

        contactWrappers.sort();

        // Transform the wrapper list to a list of Contact objects
        for(ContactWrapper wrapper : contactWrappers) {
            contactList.add(wrapper.contact);
        }

        return contactList;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateContact(ccrz.cc_RemoteActionContext ctx, String jsonData) {

        ccrz.cc_CallContext.initRemoteContext(ctx);

        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        Boolean isSuccess = false;
        Contact theContact = null;

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try
        {
            Map<String,Object> formData = (Map<String,Object>)JSON.deserializeUntyped(jsonData);

            String ContactId = (String)formData.get('contactId');
            Boolean canOrder = (Boolean)formData.get('canOrder');

            String temp = (String)formData.get('budgetLimit');
            Decimal budgetLimit = temp != '' ? Decimal.valueOf((String)formData.get('budgetLimit')) : 0;

            Boolean requiresApproval = (Boolean)formData.get('requiresApproval');

            System.debug('ckz_ctrl_UserRoles:updateContact, contactId: ' + contactId);
            System.debug('ckz_ctrl_UserRoles:updateContact, canOrder: ' + canOrder);
            System.debug('ckz_ctrl_UserRoles:updateContact, budgetLimit: ' + budgetLimit);
            System.debug('ckz_ctrl_UserRoles:updateContact, requiresApproval: ' + requiresApproval);

            theContact = [
                    SELECT Id, FirstName, LastName,
                            ckz_Budget_Administrator__c, ckz_Budget_Can_Order__c,
                            ckz_Budget_Requires_Approval__c, ckz_Budget_Limit__c
                    FROM Contact
                    WHERE Id = :ContactId
            ];

            theContact.ckz_Budget_Can_Order__c = canOrder;
            theContact.ckz_Budget_Requires_Approval__c = requiresApproval;
            theContact.ckz_Budget_Limit__c = budgetLimit;

            update theContact;

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
            //msg.labelId              = 'BudgetOverrideApproved' ;
            msg.message = 'Changes successfully saved for user: ' + theContact.FirstName + ' ' + theContact.LastName;
            msg.type                 = ccrz.cc_bean_Message.MessageType.CUSTOM ;
            msg.severity             = ccrz.cc_bean_Message.MessageSeverity.INFO ;
            msg.classToAppend        = 'messagingSection-UserRoles-Info';

            retMessages.add(msg);

            isSuccess = true;

        } catch (Exception ex) {
            System.debug('ckz_ctrl_UserRoles:updateContact:responseFalse');
            isSuccess = false;
            System.debug('message: ' + ex.getMessage());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error saving changes to contact: ' + theContact.FirstName + ' ' + theContact.LastName;
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-UserRoles-Info';
            retMessages.add(msgErr);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'updateContact');
            ccrz.ccLog.close(response);

            response.success = isSuccess;
            response.inputContext = ctx;
            response.messages.addAll(retMessages);
            response.data = null;

        }

        ccrz.ccLog.log('ckz_ctrl_ContractSelector:updateContact:response: ' + response);
        return response;

    }

    /*
        This class is used to sort Contact objects by LastName.
     */
    global class ContactWrapper implements Comparable {
        public Contact contact;

        public ContactWrapper(Contact contact) {
            this.contact = contact;
        }

        global Integer compareTo(Object compareTo) {
            ContactWrapper compareToContact = (ContactWrapper)compareTo;

            Integer returnValue = 0;
            if(contact.LastName > compareToContact.contact.LastName) {
                returnValue = 1;
            }
            else {
                returnValue = -1;
            }

            return returnValue;
        }
    }

}