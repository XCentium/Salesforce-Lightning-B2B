trigger SCCSyncCustomerAccountTrigger on Account (before insert, before update) {

    // Retrieve an instance of the connector-logger
    SCCFileLogger logger = SCCFileLogger.getInstance();
    Boolean result;

    try {
        if (Trigger.isInsert) {

        }
        if (Trigger.isUpdate) {

            // Wrapping the trigger logic inside the check -- if the toggle for trigger is set to true or not.
            if (SCCUtilityClass.isCustomerTriggerEnabled()) {

                // Create a map identify new / old accounts
                List<Account> newAccounts = Trigger.new;
                List<Account> oldAccounts = Trigger.old;
                Map<String, Object> patchDataMap = new Map<String, Object>();
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();

                // Loop over the collection of new account updates
                for (Integer i = 0; i < newAccounts.size(); i++) {

                    // Create a reference to the current new / old account being processed
                    Account newAcc = newAccounts.get(i);
                    Account oldAcc = oldAccounts.get(i);

                    // This is avoid calling future method when object updated by webservice from CC.
                    if (!newAcc.SFCC_update__c) {
                        for (String str : fieldMap.keySet()) {
                            logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Field name: ' + str + '. New value: ' + newAcc.get(str) + '. Old value: ' + oldAcc.get(str));
                            if (newAcc.get(str) != oldAcc.get(str)) {
                                logger.debug('SCCSyncCustomerAccountTrigger.IsUpdate', 'Patching commerce cloud for field ' + str);
                                patchDataMap.put(str, newAcc.get(str));
                            }
                        }
                        if (!patchDataMap.isEmpty()) {

                            // Call Commerce Cloud patch to push profile updates to B2C Commerce
                            result = SCCAccountHelper.patchCustProfile(patchDataMap, newAcc);

                        }

                    }

                    // Remove the new-account flag
                    newAcc.SFCC_update__c = false;

                }

            }

        }

    } catch (Exception e) {

        // Audit and display any errors that were thrown during trigger processing
        logger.error('SCCSyncCustomerAccountTrigger', 'Exception message : '
            + e.getMessage() + ' StackTrack '+ e.getStackTraceString());

    } finally {

        // Otherwise, flush the logger
        logger.flush();

    }

}