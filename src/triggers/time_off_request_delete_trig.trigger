trigger time_off_request_delete_trig on Time_Off_Request__c bulk (before delete) {
    if(System.isBatch()) return;
    System.assert(System.Trigger.old.size() > 0);
    
    if (System.Trigger.old.size() > 0) {
        Time_Off_Request__c[] tors_to_delete = new Time_Off_Request__c[0];
        
        for (Time_Off_Request__c tor : System.Trigger.old) {
            // You can only delete Time Off Requests that are in the 'Not Submitted' state.
            if (tor.Status__c != 'Not Submitted') {
                tor.Status__c.addError('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.');
            } else {
                tors_to_delete.add(tor);
            }
        }
        
        // Remove the PTO balance from the Requestor's pending balance
        if (tors_to_delete.size() > 0) {
            Map<Id, Time_Off_Info__c> tois = ptoPackage.get_requestor_time_off_info(tors_to_delete);
            
            // Get Time Off Balance Info for the user
            for (Time_Off_Request__c tor : tors_to_delete) {
                Time_Off_Info__c toi = tois.get(tor.Requestor__c);
                System.assert((toi != null) && (toi.Pending_PTO_Balance_Hours__c != null));
                Integer number_of_days_off = ptoPackage.compute_number_of_days_off(tor);
                System.assert(number_of_days_off >= 0);
                toi.Pending_PTO_Balance_Hours__c -= (number_of_days_off * 8);
            }
            update tois.values();
        }
    }
}