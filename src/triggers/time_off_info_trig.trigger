trigger time_off_info_trig on Time_Off_Info__c bulk (before insert, after insert) {
    if(System.isBatch()) return;
    System.assert(System.Trigger.isInsert);
    System.assert(System.Trigger.new.size() > 0);
 
    if (System.Trigger.isBefore) {
        Id payroll_queue_id = ptoPackage.get_payroll_queue().Id;
        
        Map<Id, Time_Off_Info__c> users_map = new Map<Id, Time_Off_Info__c>();
        
        Set<Id> users_to_get_data_from = new Set<Id>();
        for (Time_Off_Info__c toi : System.Trigger.new) {
            // Make sure the Time_Off_Info__c object has a User__c field, and that that 
            // User__c is not a duplicate within the array being inserted
            if (toi.User__c == null) {
                toi.User__c.addError('The User__c field is required when inserting a new Time_Off_Info__c record.');
            } else if (users_map.containsKey(toi.User__c)) {
                toi.User__c.addError('The User \'' + toi.User__c + '\' already has a Time_Off_Info__c record, and only one is permitted.');
            } else {
                users_map.put(toi.User__c, toi);
            }
            toi.OwnerId = payroll_queue_id;
            
            if ((toi.Name == null) || (toi.Employee_Number__c == null)) {
                users_to_get_data_from.add(toi.User__c);
            }
        }
        
        if (users_to_get_data_from.size() > 0) {
            Map<Id, User> id_user_map = new Map<Id, User>([select Employee_Number__c from User where Id in :users_to_get_data_from]);
            for (Time_Off_Info__c toi : System.Trigger.new) {
                if ((toi.Name == null) && (id_user_map.get(toi.User__c) != null)) {
                    toi.Name = id_user_map.get(toi.User__c).Employee_Number__c;
                }
                if ((toi.Employee_Number__c == null) && (id_user_map.get(toi.User__c) != null)) {
                    toi.Employee_Number__c = id_user_map.get(toi.User__c).Employee_Number__c;
                }
            }
        }
        
        // Now look through the database looking for duplicates
        if (users_map.size() > 0) {
            for (Time_Off_Info__c toi : [select Id, User__c from Time_Off_Info__c where User__c in :users_map.keySet()]) {
                System.assert(users_map.containsKey(toi.User__c));
                users_map.get(toi.User__c).User__c.addError('The User \'' + toi.User__c + '\' already has a Time_Off_Info__c record, and only one is permitted.');
            }
        }
    } else {
        System.assert(System.Trigger.isAfter);
        Time_Off_Info__Share[] shares = new Time_Off_Info__Share[0];
        for (Time_Off_Info__c toi : System.Trigger.new) {
            Time_Off_Info__Share share = new Time_Off_Info__Share(UserOrGroupId = toi.User__c, ParentId = toi.Id, AccessLevel = 'Read');
            shares.add(share);
        }
        insert shares;
    }

}