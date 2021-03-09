trigger ckzUpdateAccountOrderAmount on ccrz__E_Order__c (after update) {

    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {

            // Get upgrade price list
            List<ccrz__E_AccountGroup__c> accGroupList = [Select Id, Name from ccrz__E_AccountGroup__c where Name = 'Gold Partner'];

            ccrz__E_AccountGroup__c accGroup = null;

            if(accGroupList.size() > 0) {
                accGroup = accGroupList.get(0);
            }

            Set<Id> accountIds = new Set<Id>();

            // Create a set of all of the account IDs
            for(ccrz__E_Order__c obj : Trigger.new) {

                Id accountId = obj.ccrz__Account__c;
                accountIds.add(accountId);
            }

            // Get all of the Account records

            List<Account> accountList = [Select Id, Name, B2B_Total_Order_Amount__c, ccrz__E_AccountGroup__c from Account where Id in :accountIds];

            // Put all of the Account records into a Map

            Map<Id, Account> accountMap = new Map<Id, Account>();

            for(Account obj : accountList) {
                accountMap.put(obj.Id, obj);
            }

            // Process each order, updating the total ammount field on the account

            for(ccrz__E_Order__c obj : Trigger.new) {

                if(obj.ccrz__OrderStatus__c == 'Order Submitted' && obj.ccrz__TotalAmount__c != null && obj.ccrz__TotalAmount__c > 0) {
                    Account account = accountMap.get(obj.ccrz__Account__c);

                    if(account.B2B_Total_Order_Amount__c == null) {
                        account.B2B_Total_Order_Amount__c = obj.ccrz__TotalAmount__c;
                    }
                    else {
                        account.B2B_Total_Order_Amount__c += obj.ccrz__TotalAmount__c;
                    }

                    // if(account.B2B_Total_Order_Amount__c > 24000 && account.ccrz__E_AccountGroup__c != accGroup.Id) {
                    //     account.ccrz__E_AccountGroup__c = accGroup.Id;
                    // }
                }

            }

            update accountList;

        }
    }

}