public class tom_test_cancellation {

	static testMethod void test_cancellation() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
	    try {
	    	ptoPackage.cancel_request_without_commit('a0030000006sWYmAAM');
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('There is no Time Off Request with ID \'a0030000006sWYmAAM\', so it cannot be canceled.') > -1);
	    }
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);

		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 160);
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

		Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 26), false);
		
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 48);

	    try {
	    	ptoPackage.cancel_request_without_commit(tor.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('A Time Off Request cannot be closed if it is in the Not Submitted state.') > -1);
	    }
		
		tor.Status__c = 'Pending Approval';
		tor.Date_Submitted__c = System.now();
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Pending Approval');
		pto_tests_common.validate_balances(subordinate.Id, 160, 48);
		
	    try {
	    	ptoPackage.cancel_request_without_commit(tor.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('A Time Off Request cannot be closed if it is in the Pending Approval state.') > -1);
	    }
		
		tor.Status__c = 'Approved';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Approved');
		pto_tests_common.validate_balances(subordinate.Id, 160, 48);
		
    	ptoPackage.cancel_request_without_commit(tor.Id);
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Canceled');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

	    try {
	    	ptoPackage.cancel_request_without_commit(tor.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('A Time Off Request cannot be closed if it is in the Canceled state.') > -1);
	    }
		
		tor.Status__c = 'Processed';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Processed');
		pto_tests_common.validate_balances(subordinate.Id, 160, 48);
		
	    try {
	    	ptoPackage.cancel_request_without_commit(tor.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('A Time Off Request cannot be closed if it is in the Processed state.') > -1);
	    }
		
		tor.Status__c = 'Rejected';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Rejected');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
    	ptoPackage.cancel_request_without_commit(tor.Id);
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Canceled');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
		tor.Status__c = 'Requires Re-Approval';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Requires Re-Approval');
		pto_tests_common.validate_balances(subordinate.Id, 160, 48);
		
    	ptoPackage.cancel_request_without_commit(tor.Id);
		pto_tests_common.validate_time_off_request_status(tor.Id, subordinate.Id, 'Canceled');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
	}

}