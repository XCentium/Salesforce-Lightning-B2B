public class tom_test_pto_bal_validation{

	public static testMethod void test_pto_balance_validation() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);
 
		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 160);
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

	    try {
			Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 3, 26), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (20.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

		Time_Off_Request__c tor1 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);		
		pto_tests_common.validate_time_off_request_status(tor1.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);

		Time_Off_Request__c tor_n1 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), true);		
		pto_tests_common.validate_time_off_request_status(tor_n1.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);

	    try {
			Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 4, 16), Date.newInstance(2007, 5, 18), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (19.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);
		
		Time_Off_Request__c tor_n2 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 6, 18), Date.newInstance(2007, 6, 18), true);		
		pto_tests_common.validate_time_off_request_status(tor_n2.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);

		Time_Off_Request__c tor2 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 6, 16), Date.newInstance(2007, 7, 19), false);		
		pto_tests_common.validate_time_off_request_status(tor2.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);

		delete new Time_Off_Request__c[]{tor_n1, tor_n2};
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		tor1.Status__c = 'Rejected';
		update tor1;
		pto_tests_common.validate_time_off_request_status(tor1.Id, subordinate.Id, 'Rejected');
		pto_tests_common.validate_balances(subordinate.Id, 160, 192);
		
		tor2.Status__c = 'Canceled';
		update tor2;
		pto_tests_common.validate_time_off_request_status(tor2.Id, subordinate.Id, 'Canceled');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
	    try {
			Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 3, 26), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (20.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
		Time_Off_Request__c tor3 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 3, 25), false);		
		pto_tests_common.validate_time_off_request_status(tor3.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
	    try {
			tor1.Status__c = 'Not Submitted';
			update tor1;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (-5.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
	    try {
			tor2.Status__c = 'Not Submitted';
			update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (-5.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		delete tor3;
		tor3 = null;
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

		tor1.Status__c = 'Not Submitted';
		update tor1;
		pto_tests_common.validate_time_off_request_status(tor1.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);
		
		tor2.Status__c = 'Not Submitted';
		update tor2;
		pto_tests_common.validate_time_off_request_status(tor2.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		delete tor1;
		tor1 = null;
		pto_tests_common.validate_balances(subordinate.Id, 160, 192);
		
		delete tor2;
		tor2 = null;
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
		Time_Off_Request__c tor4 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 3, 25), false);		
		pto_tests_common.validate_time_off_request_status(tor4.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);		
		
	    try {
			Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (-5.0 days) by more than 5 days.') > -1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);

		delete tor4;
		tor4 = null;
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
	}

}