public class tom_test_record_type_errors{

	public static testMethod void test_record_type_errors() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Subordinate');
 		System.assert(user.Id != null);
		System.assert(user.Manager_PTO__c != null);

 		// Give the subordinate some  vacation time
		pto_tests_common.set_pto_balance(user.Id, 320);
		pto_tests_common.validate_balances(user.Id, 320, 0);
		
    	Id id = ptoPackage.get_record_type_id('TEST', 'Invalid Status');
    	System.assert(id == null);
		
		Time_Off_Request__c[] tors = new Time_Off_Request__c[3];
		
		tors[0] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 3, 16), Date.newInstance(2007, 3, 16), false);
		tors[2] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
		pto_tests_common.insert_requests(tors, new Id[]{user.Id, user.Id, user.Id}, new String[]{'Not Submitted', 'Not Submitted', 'Not Submitted'});
		
		tors[0].Status__c = 'Invalid Status';
		tors[2].Status__c = 'Invalid Status';
		
		try {
			update tors;
			System.assert(false);
		} catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('There must be exactly one Record Type named \'TEST-Invalid Status\'.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('There must be exactly one Record Type named \'TEST-Invalid Status\'.') > -1);
			System.assert(e.getDmlIndex(1) == 2);
		}
	}

}