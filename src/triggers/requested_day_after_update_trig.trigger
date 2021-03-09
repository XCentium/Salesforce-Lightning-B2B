// When a Request_Day__c is processed or "unprocessed" by payroll (i.e. the Pay_Cycle__c field
// either becomes null or becomes set), or when the record is marked/unmarked for processing by payroll,
// then we need to update the pending balances we are maintaining, 
// because once a day off is processed by payroll, then it will be reflected in the actual balances,
// and so we don't need to keep track of it in the pending balances. To do this we start with the
// days being updated whose Pay_Cycle__c field is being set/unset. Then, from those objects, find the 
// corresponding Time_Off_Request__c parents, along with each parent's Requestor__c (a User object).
// Then, find all the Time_Off_Info__c records for those Requestors (Users), which is where the  pending
// balances are stored. Finally, loop through all those Time_Off_Info__c records and update their 
// pending balances.
trigger requested_day_after_update_trig on Requested_Day__c bulk (after update) {
    if(System.isBatch()) return;
    System.assert(System.Trigger.old != null); 
    System.assert(System.Trigger.new != null);
    System.assert(System.Trigger.old.size() == System.Trigger.new.size());
    System.assert(System.Trigger.new.size() > 0);
    
    if (System.Trigger.new.size() > 0) {
        // Find all the objects being updated where the Pay_Cycle__c field is either be set or unset.
        Set<Id> days_requiring_balance_updates = new Set<Id>();
        Set<Integer> indexes_requiring_balance_updates = new Set<Integer>();
        for (Integer i = 0; i < System.Trigger.new.size(); i++) {
//          if (((System.Trigger.old[i].Pay_Cycle__c == null) && (System.Trigger.new[i].Pay_Cycle__c != null)) || ((System.Trigger.old[i].Pay_Cycle__c != null) && (System.Trigger.new[i].Pay_Cycle__c == null)) || (System.Trigger.old[i].Do_not_include_in_Pay_Cycle__c && !System.Trigger.new[i].Do_not_include_in_Pay_Cycle__c) || (!System.Trigger.old[i].Do_not_include_in_Pay_Cycle__c && System.Trigger.new[i].Do_not_include_in_Pay_Cycle__c)) {
            if (((System.Trigger.old[i].Pay_Cycle__c == null) && (System.Trigger.new[i].Pay_Cycle__c != null)) || ((System.Trigger.old[i].Pay_Cycle__c != null) && (System.Trigger.new[i].Pay_Cycle__c == null))) {
                days_requiring_balance_updates.add(System.Trigger.new[i].Id);
                indexes_requiring_balance_updates.add(i);
            }
        } 
        
        System.assert(days_requiring_balance_updates.size() == indexes_requiring_balance_updates.size());
        
        if (days_requiring_balance_updates.size() > 0) {
            Map<Id, Id> tor_to_requestor_map = new Map<Id, Id>();           // Map from Time_Off_Request__c.Id to Time_Off_Request__c.Requestor__c
            for (Requested_Day__c day : [select Time_Off_Request__c, Time_Off_Request__r.Requestor__c from Requested_Day__c where Id in :days_requiring_balance_updates]) {
                tor_to_requestor_map.put(day.Time_Off_Request__c, day.Time_Off_Request__r.Requestor__c);
            }
            
            System.assert(tor_to_requestor_map.size() > 0);
            System.assert(tor_to_requestor_map.size() <= days_requiring_balance_updates.size());
            
            Map<Id, Time_Off_Info__c> user_time_off_info_map = ptoPackage.get_user_time_off_info(tor_to_requestor_map.values());
            
            System.assert(user_time_off_info_map != null);
            
            for (Integer index : indexes_requiring_balance_updates) {
                System.assert(System.Trigger.new[index].Time_Off_Request__c != null);
                System.assert(tor_to_requestor_map.containsKey(System.Trigger.new[index].Time_Off_Request__c));
                Id requestor = tor_to_requestor_map.get(System.Trigger.new[index].Time_Off_Request__c);
                System.assert(requestor != null);
                
                Time_Off_Info__c toi = user_time_off_info_map.get(requestor);
                if (toi != null) {
//                  if (((System.Trigger.new[index].Pay_Cycle__c != null) && !System.Trigger.old[index].Do_not_include_in_Pay_Cycle__c) || ((System.Trigger.old[index].Pay_Cycle__c == null) && System.Trigger.new[index].Do_not_include_in_Pay_Cycle__c)) {
                    if (System.Trigger.new[index].Pay_Cycle__c != null) {
                        if (System.Trigger.new[index].Hours__c > 0) {
                            toi.Pending_PTO_Balance_Hours__c -= System.Trigger.new[index].Hours__c;
                        }
                    } else {
//                  } else if ((System.Trigger.new[index].Pay_Cycle__c == null) && !System.Trigger.new[index].Do_not_include_in_Pay_Cycle__c) {
                        if (System.Trigger.new[index].Hours__c > 0) {
                            toi.Pending_PTO_Balance_Hours__c += System.Trigger.new[index].Hours__c;
                        }
                    }
                }
            }
            
            if (user_time_off_info_map.size() > 0) {
                update user_time_off_info_map.values();
            }
        }
    }
}