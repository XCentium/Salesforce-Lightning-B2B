public class tom_test_bulk_time_off_info {

	static testMethod void test_bulk_time_off_info() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		// Test to make sure that the Time_Off_Info__c cache is working properly
		// and doesn't result in any extra SOQL queries
		Map<String, User> users = pto_tests_common.get_test_user_ids();
		Set<Id> user_ids = new Set<Id>();
		for (String name : users.keySet()) {
			user_ids.add(users.get(name).Id);
		}
				
		System.assert(users.size() == 3);
		Map<Id, Time_Off_Info__c> tois_map = ptoPackage.get_user_time_off_info(user_ids);
		Map<Id, Time_Off_Info__c> tois_map_2 = ptoPackage.get_user_time_off_info(user_ids);
		for (String name : users.keySet()) {
			System.assert(tois_map.get(users.get(name).Id) != null);
			System.assert(tois_map_2.get(users.get(name).Id) != null);
			System.assert(tois_map.get(users.get(name).Id) == tois_map_2.get(users.get(name).Id));
		}
		
		// Now make sure we can set the balances in bulk and that they are set
		// correctly.
		pto_tests_common.set_pto_balance(new Id[]{users.get('Manager').Id, users.get('Subordinate').Id}, new Double[]{160, 100});
		pto_tests_common.validate_balances(users.get('Manager').Id, 160, 0);
		pto_tests_common.validate_balances(users.get('Subordinate').Id, 100, 0);
		
		// Clean out all data
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		// Bulk create some Time_Off_Info__c records, one for each user, and then a few more to cover all errors
		Time_Off_Info__c[] tois = new Time_Off_Info__c[0];
		Time_Off_Info__c toi = new Time_Off_Info__c();	// Missing User__c field
		tois.add(toi);
		toi = new Time_Off_Info__c(User__c = users.get('Manager').Id);
		tois.add(toi);
		toi = new Time_Off_Info__c(User__c = users.get('Subordinate').Id);
		tois.add(toi);
		toi = new Time_Off_Info__c(User__c = users.get('Subordinate').Id);	// Duplicate User__c field
		tois.add(toi);
	    try {
	    	insert tois;
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('The User__c field is required when inserting a new Time_Off_Info__c record.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('The User \'' + users.get('Subordinate').Id + '\' already has a Time_Off_Info__c record, and only one is permitted.') > -1);
			System.assert(e.getDmlIndex(1) == 3);
	    }
	    
	    System.assert([select count() from Time_Off_Info__c where User__c in :user_ids] == 0);

	    // Now actually insert some records successfully
	    tois.clear();
		toi = new Time_Off_Info__c(User__c = users.get('Manager').Id);
		tois.add(toi);
		toi = new Time_Off_Info__c(User__c = users.get('Subordinate').Id);
		tois.add(toi);
	    insert tois;
	    System.assert([select count() from Time_Off_Info__c where User__c in :user_ids] == 2);
	    
	    // Now make sure we can't enter record that have the same User__c as a record in the database
	    tois.clear();
		toi = new Time_Off_Info__c(User__c = users.get('Manager').Id);
		tois.add(toi);
		toi = new Time_Off_Info__c(User__c = users.get('Subordinate').Id);
		tois.add(toi);
	    try {
	    	insert tois;
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('The User \'' + users.get('Manager').Id + '\' already has a Time_Off_Info__c record, and only one is permitted.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('The User \'' + users.get('Subordinate').Id + '\' already has a Time_Off_Info__c record, and only one is permitted.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
	    }
		
/*	    
		// Next try and load in the Time_Off_Info__c record for the 'Subordinate2' user, whose Time_Off_Info__c record
		// does not yet exist
	    System.assert([select count() from Time_Off_Info__c where User__r.FirstName = 'Test' and User__r.LastName = 'Subordinate2'] == 0);
		Time_Off_Info__c sub_2_toi = ptoPackage.get_user_time_off_info(users.get('Subordinate2').Id);
	    System.assert([select count() from Time_Off_Info__c where User__r.FirstName = 'Test' and User__r.LastName = 'Subordinate2'] == 1);
		System.assert(sub_2_toi != null);
		System.assert(sub_2_toi.Payroll_System__r.Name == 'ZIX');
*/
		
		// Clean out all data
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		// Test bulkification of the user/manager cache
		Map<Id, User> user_manager_map = ptoPackage.get_user_and_manager(user_ids);
		System.assert(user_manager_map.get(users.get('Manager').Id) != null);
		System.assert(user_manager_map.get(users.get('Manager').Id).Id == users.get('Manager').Id);
		System.assert(user_manager_map.get(users.get('Manager').Id).Manager_PTO__c == null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id) != null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Id == users.get('Subordinate').Id);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Manager_PTO__c != null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Manager_PTO__c == users.get('Manager').Id);
		
		// And try it again to make sure the cache works. This should not add any SOQL statements!
		user_manager_map = ptoPackage.get_user_and_manager(user_ids);
		System.assert(user_manager_map.get(users.get('Manager').Id) != null);
		System.assert(user_manager_map.get(users.get('Manager').Id).Id == users.get('Manager').Id);
		System.assert(user_manager_map.get(users.get('Manager').Id).Manager_PTO__c == null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id) != null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Id == users.get('Subordinate').Id);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Manager_PTO__c != null);
		System.assert(user_manager_map.get(users.get('Subordinate').Id).Manager_PTO__c == users.get('Manager').Id);
	}

}