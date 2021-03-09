trigger time_off_request_after_trig on Time_Off_Request__c bulk (after insert, after update) {
    if(System.isBatch()) return;
    System.assert(System.Trigger.new.size() > 0);
 
    // Delete any existing Requested_Day__c objects associated with Time_Off_Requests that have
    // changed the number of days being requested. 
    Set<Id> requests_with_days_to_delete = ptoPackage.determine_time_off_requests_with_days_to_delete(System.Trigger.isUpdate, System.Trigger.old, System.Trigger.new);
    if (requests_with_days_to_delete.size() > 0) {
        for (Requested_Day__c[] old_requests : [select Id from Requested_Day__c where (Time_Off_Request__c in :requests_with_days_to_delete) and (IsDeleted = false)]) {
            delete old_requests;
        }
    }

    Map<Id, Time_Off_Request__c> requests = new Map<Id, Time_Off_Request__c>();
    Map<Id, User> requestors_and_managers = new Map<Id, User>();
    Set<Id> tors_with_changing_vacation_days = new Set<Id>();
    Integer num_requests = System.Trigger.new.size();
    Requested_Day__c[] days = new Requested_Day__c[0];
    
    for (Integer i = 0; i < num_requests; i++) {
        System.assert(System.Trigger.new[i].Id != null);
        System.assert(System.Trigger.new[i].Start_Date__c != null);
        System.assert(System.Trigger.new[i].End_Date__c != null);
        
        // Manage sharing to requestor, owner, and payroll
        if (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c)) {
            System.assert(System.Trigger.new[i].Requestor__c != null);
            User requestor = ptoPackage.get_user_and_manager(System.Trigger.new[i].Requestor__c);
            System.assert(requestor != null);
            System.assert(requestor.Id != null);
            requestors_and_managers.put(requestor.Id, requestor);
            requests.put(System.Trigger.new[i].Id, System.Trigger.new[i]);
        }
        
        // Compute all the new days off
        if (System.Trigger.isInsert || (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c)) {
            tors_with_changing_vacation_days.add(System.Trigger.new[i].Id);
            Requested_Day__c[] days_for_tor = ptoPackage.compute_requested_days_for_requests(System.Trigger.new[i]);
            days.addAll(days_for_tor);
        }
    }
    
    // Take all the requests whose status has changed and manage sharing in bulk
    if (requests.size() > 0) {
        ptoPackage.manage_sharing_based_on_status(requests, requestors_and_managers, System.Trigger.isInsert);
    }
    
    // If we're updating the request, then make sure that all previous Requested_Day__c records
    // were deleted in the "before" trigger.
    if (tors_with_changing_vacation_days.size() > 0) {
        System.assert([select count() from Requested_Day__c where (Time_Off_Request__c in :tors_with_changing_vacation_days) and (IsDeleted = false)] == 0);
    }

    System.assert(days != null);
    if (days.size() > 0) {
        insert days;
    }
}