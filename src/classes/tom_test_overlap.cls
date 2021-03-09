public class tom_test_overlap {
	
	static testMethod void test_overlap()
	{
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();

		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);
		System.assert(subordinate.Employee_Number__c != null);
 
		User subordinate2 = test_users.get('Subordinate2');
		System.assert(subordinate.Id != null);
		System.assert(subordinate.Employee_Number__c != null);

		// Give the subordinates some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 320);
		pto_tests_common.validate_balances(subordinate.Id, 320, 0);
		pto_tests_common.set_pto_balance(subordinate2.Id, 320);
		pto_tests_common.validate_balances(subordinate.Id, 320, 0);
		
		Id[] user_ids = new Id[]{subordinate.Id, subordinate.Id};

		Time_Off_Request__c[] tors = new Time_Off_Request__c[2];
		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
	    try {
			pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 320, 0);
		pto_tests_common.validate_balances(subordinate2.Id, 320, 0);

		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 19), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 19), Date.newInstance(2007, 2, 21), false);
	    try {
			pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 320, 0);
		pto_tests_common.validate_balances(subordinate2.Id, 320, 0);

		user_ids = new Id[]{subordinate.Id, subordinate.Id, subordinate.Id};
		tors = new Time_Off_Request__c[3];
		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		tors[2] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
	    try {
			pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted', 'Not Submitted'});
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 3);
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
			System.assert(e.getDmlMessage(2).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(2) == 2);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 320, 0);
		pto_tests_common.validate_balances(subordinate2.Id, 320, 0);

		user_ids = new Id[]{subordinate.Id, subordinate2.Id};
		tors = new Time_Off_Request__c[2];
		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 19), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 19), Date.newInstance(2007, 2, 21), false);
		pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted'});

		pto_tests_common.validate_balances(subordinate.Id, 320, 16);
		pto_tests_common.validate_balances(subordinate2.Id, 320, 16);

		Requested_Day__c[] days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c in :tors) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 4);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tors[0].Id, '02-February', 8, subordinate.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 19), tors[0].Id, '02-February', 8, subordinate.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 19), tors[1].Id, '02-February', 8, subordinate2.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 2, 21), tors[1].Id, '02-February', 8, subordinate2.Employee_Number__c, 'Not Submitted', false);

		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 19), Date.newInstance(2007, 2, 19), false);
	    try {
			pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
	    	System.assert(false);
	    } catch (System.DmlException e) {
	    	System.assert(e.getNumDml() == 2);
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(0) == 0);
			System.assert(e.getDmlMessage(1).indexOf('You have already requested time off during this same time period.') > -1);
			System.assert(e.getDmlIndex(1) == 1);
	    }
		pto_tests_common.validate_balances(subordinate.Id, 320, 16);
		pto_tests_common.validate_balances(subordinate2.Id, 320, 16);
	}
}