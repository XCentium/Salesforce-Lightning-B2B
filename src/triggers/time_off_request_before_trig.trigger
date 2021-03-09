trigger time_off_request_before_trig on Time_Off_Request__c bulk (before insert, before update) {
    if(System.isBatch()) return;
    System.assert(System.Trigger.new.size() > 0);
    
    // Beispiel Kommentar
    // First, load and cache time off info records and users/managers, to minimize SOQL queries
    Set<Id> users_needing_tois = new Set<Id>();
    Map<Id, Time_Off_Info__c> tor_toi_map = null;
    Set<Id> required_requestors_and_managers = new Set<Id>();
    Map<Id, User> users_and_managers = null;
    for (Integer i = 0; i < System.Trigger.new.size(); i++) {
        if (System.Trigger.new[i].Start_Date__c == null) {
            System.Trigger.new[i].Start_Date__c.addError('The Start Date is required.');
        }
        if (System.Trigger.new[i].End_Date__c == null) {
            System.Trigger.new[i].End_Date__c.addError('The End Date is required.');
        }
        
        if (System.Trigger.isInsert) {
            // Set the Requestor__c field to the current user when the record is first created
            System.Trigger.new[i].Requestor__c = System.Trigger.new[i].OwnerId;
        }

        if (System.Trigger.isInsert || 
                (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c) ||
                (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) ||
                (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c)) {
            // For these users, we will need their Time_Off_Info__c record later...
            System.assert(System.Trigger.new[i].Requestor__c != null);
            users_needing_tois.add(System.Trigger.new[i].Requestor__c);
        }
        if (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c) || 
                (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || 
                (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c)) {
            required_requestors_and_managers.add(System.Trigger.new[i].Requestor__c);
        }
    }
    if (users_needing_tois.size() > 0) {
        tor_toi_map = ptoPackage.get_user_time_off_info(users_needing_tois);
    }
    if (required_requestors_and_managers.size() > 0) {
        users_and_managers = ptoPackage.get_user_and_manager(required_requestors_and_managers);
    }
    
    // Now cache the record type IDs
    Set<String> record_type_id_names = new Set<String>();
    for (Integer i = 0; i < System.Trigger.new.size(); i++) {
        if ((System.Trigger.new[i].Start_Date__c != null) && (System.Trigger.new[i].End_Date__c != null)) {
            // If the Status__c field is null (which it shouldn't be), set it to Not Submitted
            if (System.Trigger.new[i].Status__c == null) {
                System.Trigger.new[i].Status__c = 'Not Submitted';
            }
        
            // If the Balance_Correction__c field is null (which it shouldn't be), set it to false
            if (System.Trigger.new[i].Balance_Correction__c == null) {
                System.Trigger.new[i].Balance_Correction__c = false;
            }
        
            // If the request is Approved but the date or number of days has changed, then change the Status
            if (System.Trigger.isUpdate && 
                    ((System.Trigger.new[i].Status__c == 'Approved') || (System.Trigger.new[i].Status__c == 'Rejected')) && 
                    ((System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || 
                        (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c))) {
                System.Trigger.new[i].Status__c = 'Requires Re-Approval';
            }
            
            // Now determine the name of the record type, which is a combination of the record type prefix stored
            // in the Payroll_System__c object and the request's status.
            if (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c)) {
                System.assert(users_needing_tois.contains(System.Trigger.new[i].Requestor__c));
                Time_Off_Info__c toi = tor_toi_map.get(System.Trigger.new[i].Requestor__c);
    
                if (System.Trigger.isInsert) {
                    System.assert(System.Trigger.new[i].Requestor__c == System.Trigger.new[i].OwnerId);
                    
                    if (toi == null) {
                        System.Trigger.new[i].addError('You cannot create Time Off Requests because your Time-Off Balances and your Payroll System have not been configured.');
                    } else {
                        System.Trigger.new[i].Payroll_System__c = toi.Payroll_System__c;
                        System.assert((toi.Payroll_System__c == null) || (toi.Payroll_System__r.Enabled_For_Time_Off_Manager__c != null));
                        if ((toi.Payroll_System__c == null) || !toi.Payroll_System__r.Enabled_For_Time_Off_Manager__c) {
                            System.Trigger.new[i].addError('You can not create Time Off Requests because your payroll system is not enabled for this application.');
                        }
                        
                        if ((toi.Disable_time_off_requests__c != null) && toi.Disable_time_off_requests__c) {
                            System.Trigger.new[i].addError('You can not create Time Off Requests because you are not eligible for time off.');
                        }
                        
                        // New records must be created in the Not Submitted state
                        if (System.Trigger.new[i].Status__c != 'Not Submitted') {
                            System.Trigger.new[i].addError('New Time Off Requests must be created with a Status of \'Not Submitted\'.');
                        }
                        
                        // User must have non-null Employee Number to submit time-off requests
                        User requestor = users_and_managers.get(System.Trigger.new[i].Requestor__c);
                        System.assert(requestor != null);
                        if (requestor.Employee_Number__c == null) {
                            System.Trigger.new[i].addError('You cannot create Time Off Requests because your Employee Number is not configured.');
                        }
                        
                        // The Employee Number is set automatically as a default value from the User record, but sometimes
                        // the active user is not the actual "requestor" (which is determined by the initial Owner), and
                        // so we should really pull this out of the Time Off Info record, if the value there exists.
                        if (toi.Employee_Number__c != null) {
                            System.Trigger.new[i].Employee_Number__c = toi.Employee_Number__c;
                        }
                    }
                }
                
                if ((toi != null) && (toi.Payroll_System__c != null)) {
                    if (toi.Payroll_System__r.Record_Type_Prefix__c == null) {
                        System.Trigger.new[i].addError('You can not create Time Off Requests because your payroll system is not properly configured.');
                    } else {
                        String name = toi.Payroll_System__r.Record_Type_Prefix__c + '-' + System.Trigger.new[i].Status__c;
                        record_type_id_names.add(name);
                    }
                }
                
                if (!System.Trigger.isInsert) {
                    if (System.Trigger.old[i].Status__c == 'Pending Approval') {
                        System.assert(System.Trigger.new[i].Status__c != 'Pending Approval');
                        System.Trigger.new[i].Pending_Approval__c = false;
                    } else if (System.Trigger.new[i].Status__c == 'Pending Approval') {
                        System.assert(System.Trigger.old[i].Status__c != 'Pending Approval');
                        System.Trigger.new[i].Pending_Approval__c = true;
                    }
                }
            }
        }
    }

    Map<String, Id> record_type_name_id_map = null;
    if (record_type_id_names.size() > 0) {
        record_type_name_id_map = ptoPackage.get_record_type_ids(record_type_id_names);
        System.assert(record_type_name_id_map != null);
    }
    
    for (Integer i = 0; i < System.Trigger.new.size(); i++) {
        if ((System.Trigger.new[i].Start_Date__c != null) && (System.Trigger.new[i].End_Date__c != null)) {
            // Make sure that the Requestor__c doesn't change
            if (System.Trigger.isUpdate && (System.Trigger.old[i].Requestor__c != System.Trigger.new[i].Requestor__c)) {
                System.Trigger.new[i].Requestor__c.addError('The Requestor field cannot be changed.');
            }
    
            if ((System.Trigger.new[i].Payroll_System__c != null) && (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c) || (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c))) {
                Time_Off_Info__c toi = tor_toi_map.get(System.Trigger.new[i].Requestor__c);
                Double max_number_of_days_off_in_one_request = ptoPackage.max_number_of_days_off_in_one_request_default;
                if ((toi != null) && (toi.Payroll_System__r != null) && (toi.Payroll_System__r.Max_Days_in_a_Single_Request__c != null)) {
                    max_number_of_days_off_in_one_request = toi.Payroll_System__r.Max_Days_in_a_Single_Request__c;
                }
                
                Integer number_of_days_off = ptoPackage.compute_number_of_days_off(System.Trigger.new[i], true);
                if (number_of_days_off == 0) {
                    System.Trigger.new[i].Start_Date__c.addError('You cannot request time off for zero days.');
                    System.Trigger.new[i].End_Date__c.addError('You cannot request time off for zero days.');
                }
                if (Math.abs(number_of_days_off) > max_number_of_days_off_in_one_request) {
                    System.Trigger.new[i].Start_Date__c.addError('You cannot request time off for more than ' + max_number_of_days_off_in_one_request + ' days.');
                    System.Trigger.new[i].End_Date__c.addError('You cannot request time off for more than ' + max_number_of_days_off_in_one_request + ' days.');
                }
            }
            
            if (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c)) {
                // Find the ID for the requestor and the requestor's manager, if any
                User requestor = users_and_managers.get(System.Trigger.new[i].Requestor__c);
                System.assert(requestor != null);
                ptoPackage.set_owner_based_on_status(System.Trigger.new[i], requestor, System.Trigger.isInsert);
                System.assert((requestor.LastName != null) && (requestor.LastName.length() > 0));
                if ((requestor.FirstName != null) && (requestor.FirstName.length() > 0)) {
                    System.Trigger.new[i].Employee_Name__c = requestor.FirstName + ' ' + requestor.LastName;
                } else {
                    System.Trigger.new[i].Employee_Name__c = requestor.LastName;
                }
                
                // Set the record type
                Time_Off_Info__c toi = tor_toi_map.get(System.Trigger.new[i].Requestor__c);
                if ((toi != null) && (toi.Payroll_System__c != null) && (toi.Payroll_System__r.Record_Type_Prefix__c != null)) {
                    String record_type_name = toi.Payroll_System__r.Record_Type_Prefix__c + '-' + System.Trigger.new[i].Status__c;
    
                    Id record_type_id = record_type_name_id_map.get(record_type_name);
                    if (record_type_id == null) {
                        System.Trigger.new[i].RecordTypeId.addError('There must be exactly one Record Type named \'' + record_type_name + '\'.');
                    } else {
                        System.Trigger.new[i].RecordTypeId = record_type_id;
                    }
                }
            }
        }

        // If the request is marked as Processed, then do not allow the number of requested days to be changed
        if (System.Trigger.new[i].Status__c == 'Processed') {
            System.assert(System.Trigger.isUpdate);
            if (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) {
                System.Trigger.new[i].Start_Date__c.addError('You may not modify the start date for a Time Off Request that has already been processed.');
            }
            if (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c) {
                System.Trigger.new[i].End_Date__c.addError('You may not modify the end date for a Time Off Request that has already been processed.');
            }
        }
    }
    
    Map<Id, Time_Off_Info__c> tois_to_update = new Map<Id, Time_Off_Info__c>();
    
    for (Integer i = 0; i < System.Trigger.new.size(); i++) {
        // This check shouldn't be needed, because ptoPackage.adjust_pending_time_off has even finer grained
        // checks, but this seems to work around some governor issues.
        if ((System.Trigger.new[i].Start_Date__c != null) && (System.Trigger.new[i].End_Date__c != null) && 
            (System.Trigger.isInsert || (System.Trigger.old[i].Status__c != System.Trigger.new[i].Status__c) || 
                (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || 
                (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c))) {
            Time_Off_Request__c old_request = null;
            if (System.Trigger.isUpdate) {
                old_request = System.Trigger.old[i];
            }
            System.assert(System.Trigger.new[i] != null);
            Time_Off_Info__c toi = ptoPackage.adjust_pending_time_off(tor_toi_map, old_request, System.Trigger.new[i], System.Trigger.isInsert);
            if ((toi != null) && !tois_to_update.containsKey(toi.Id)) {
                tois_to_update.put(toi.Id, toi);
            }
        }
    }

    if (tois_to_update.size() > 0) {
        Time_Off_Info__c[] tois = tois_to_update.values();
        update tois;
        // Clear the cache for these records
        ptoPackage.remove_user_time_off_info(tois);
    }

    // Look for overlapping days, either in the new requests or from prior requests
    Map<Date, Map<Id, List<Time_Off_Request__c>>> days_off = new Map<Date, Map<Id, List<Time_Off_Request__c>>>();
    for (Integer i = 0; i < System.Trigger.new.size(); i++) {
        if ((!System.Trigger.new[i].Balance_Correction__c) && 
                (System.Trigger.isInsert || 
                (System.Trigger.old[i].Start_Date__c != System.Trigger.new[i].Start_Date__c) || 
                (System.Trigger.old[i].End_Date__c != System.Trigger.new[i].End_Date__c))) {
            
            if (System.Trigger.new[i].Payroll_System__c != null) {
                Set<Date> holidays = ptoPackage.get_holidays(System.Trigger.new[i].Payroll_System__c);
                
                for (Date curr_date = System.Trigger.new[i].Start_Date__c; curr_date <= System.Trigger.new[i].End_Date__c; curr_date = curr_date.addDays(1)) {
                    if (!holidays.contains(curr_date) && !ptoPackage.is_weekend(curr_date)) {
                        if (days_off.containsKey(curr_date) && days_off.get(curr_date).containsKey(System.Trigger.new[i].Requestor__c)) {
                            System.Trigger.new[i].addError('You have already requested time off during this same time period.');
                            List<Time_Off_Request__c> tors_with_day_off = days_off.get(curr_date).get(System.Trigger.new[i].Requestor__c);
                            System.assert((tors_with_day_off != null) && (tors_with_day_off.size() == 1));
                            for (Time_Off_Request__c tor : tors_with_day_off) {
                                tor.addError('You have already requested time off during this same time period.');
                            }
                        } else {
                            List<Time_Off_Request__c> tors_with_day_off = new List<Time_Off_Request__c>();
                            Map<Id, List<Time_Off_Request__c>> days_off_for_date = days_off.get(curr_date);
                            if (days_off_for_date == null) {
                                days_off_for_date = new Map<Id, List<Time_Off_Request__c>>();
                                days_off.put(curr_date, days_off_for_date);
                            }
                            days_off_for_date.put(System.Trigger.new[i].Requestor__c, tors_with_day_off);
                            tors_with_day_off.add(System.Trigger.new[i]);
                        }
                    }
                }
            }
        }
    }
    
    if (days_off.size() > 0) {
        Set<Id> requests_with_days_to_delete = ptoPackage.determine_time_off_requests_with_days_to_delete(System.Trigger.isUpdate, System.Trigger.old, System.Trigger.new);
        for (Requested_Day__c day : [select Requested_Day__c, Time_Off_Request__r.Requestor__c from Requested_Day__c where 
                                        (Time_Off_Request__r.Requestor__c in :required_requestors_and_managers) and 
                                        (Requested_Day__c in :days_off.keySet()) and 
                                        (Time_Off_Request__r.Status__c != 'Canceled') and 
                                        (Time_Off_Request__r.Status__c != 'Rejected') and 
                                        (not (Time_Off_Request__c in :requests_with_days_to_delete)) and
                                        (Hours__c > 0) and 
                                        (IsDeleted = false)]) {
            if (days_off.containsKey(day.Requested_Day__c) && days_off.get(day.Requested_Day__c).containsKey(day.Time_Off_Request__r.Requestor__c)) {
                List<Time_Off_Request__c> tors_with_day_off = days_off.get(day.Requested_Day__c).get(day.Time_Off_Request__r.Requestor__c);
                for (Time_Off_Request__c tor : tors_with_day_off) {
                    tor.addError('You have already requested time off during this same time period.');
                }
            }
        }
    }
}