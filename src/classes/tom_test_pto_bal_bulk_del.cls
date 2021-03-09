public class tom_test_pto_bal_bulk_del{

	public static testMethod void test_pto_balance_validation_with_bulk_delete() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);
 
		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 160);
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);

		Time_Off_Request__c tor1 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);		
		pto_tests_common.validate_time_off_request_status(tor1.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 8);

		Time_Off_Request__c tor2 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 6, 16), Date.newInstance(2007, 7, 19), false);		
		pto_tests_common.validate_time_off_request_status(tor2.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);

		tor1.Status__c = 'Rejected';
		update tor1;
		pto_tests_common.validate_time_off_request_status(tor1.Id, subordinate.Id, 'Rejected');
		pto_tests_common.validate_balances(subordinate.Id, 160, 192);
		
		tor2.Status__c = 'Canceled';
		update tor2;
		pto_tests_common.validate_time_off_request_status(tor2.Id, subordinate.Id, 'Canceled');
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
		
		Time_Off_Request__c tor3 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 3, 6), false);		
		pto_tests_common.validate_time_off_request_status(tor3.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 96);

		Time_Off_Request__c tor4 = pto_tests_common.insert_request(subordinate.Id, 'Not Submitted', Date.newInstance(2007, 6, 16), Date.newInstance(2007, 7, 4), false);		
		pto_tests_common.validate_time_off_request_status(tor4.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);		
		
		try {
			delete new Time_Off_Request__c[]{tor1, tor2};
			System.assert(false);
		} catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
		}

		tor3.Status__c = 'Approved';
		update tor3;
		pto_tests_common.validate_time_off_request_status(tor3.Id, subordinate.Id, 'Approved');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		tor4.Status__c = 'Processed';
		update tor4;
		pto_tests_common.validate_time_off_request_status(tor4.Id, subordinate.Id, 'Processed');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		try {
			delete new Time_Off_Request__c[]{tor3, tor4};
			System.assert(false);
		} catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
		}

		tor3.Status__c = 'Not Submitted';
		update tor3;
		pto_tests_common.validate_time_off_request_status(tor3.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		tor4.Status__c = 'Not Submitted';
		update tor4;
		pto_tests_common.validate_time_off_request_status(tor4.Id, subordinate.Id, 'Not Submitted');
		pto_tests_common.validate_balances(subordinate.Id, 160, 200);
		
		delete new Time_Off_Request__c[]{tor3, tor4};
		tor3 = null;
		tor4 = null;
		pto_tests_common.validate_balances(subordinate.Id, 160, 0);
	}

}