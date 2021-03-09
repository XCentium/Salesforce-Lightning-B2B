public class tom_test_user_no_manager{

	public static testMethod void test_time_off_request_for_user_without_manager()
	{
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Manager');
		System.assert(user.Id != null);
		System.assert(user.Manager_PTO__c == null);

		// Give the user some vacation time
		pto_tests_common.set_pto_balance(user.Id, 160);
		pto_tests_common.validate_balances(user.Id, 160, 0);

		Time_Off_Request__c tor = pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 26), false);
		
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Not Submitted');
		pto_tests_common.validate_balances(user.Id, 160, 48);
		
		Requested_Day__c[] days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 6);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 19), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 21), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 2, 22), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[4], Date.newInstance(2007, 2, 23), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[5], Date.newInstance(2007, 2, 26), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);

		// Next modify the request and make sure that the Days_Requested__c objects are correct
		tor.End_Date__c = Date.newInstance(2007, 2, 21);
		update tor;

		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Not Submitted');
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 3);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 19), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 21), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		
		// Make sure that a NULL Status__c gets set to 'Not Submitted'
		tor.Status__c = null;
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Not Submitted');
		
		// Submit an overlapping request and make sure we get an error
	    try {
			pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 21), Date.newInstance(2007, 2, 22), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		// But I should be able to submit a request adjacent to a request, even if that request 
		// would have overalapped the previous request before that request was modified.
		Time_Off_Request__c tor2 = pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 22), Date.newInstance(2007, 2, 22), false);
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tor2.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 1);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 22), tor2.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_balances(user.Id, 160, 32);

		// Now try changing that request to an overlapping date
	    try {
			tor2.Start_Date__c = Date.newInstance(2007, 2, 21);
			update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You have already requested time off during this same time period.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 32);
		
		// Next move the date and make sure that works
		tor2.Start_Date__c = Date.newInstance(2007, 2, 23);
		tor2.End_Date__c = Date.newInstance(2007, 2, 23);
		update tor2;
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tor2.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 1);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 23), tor2.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_balances(user.Id, 160, 32);
		
		// Now delete that second request and make sure the balances are OK
		delete tor2;
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		// Cycle through all the different Status__c values, and valudate the request
		// Since we can't submit a request for approval via Apex Code (yet), instead we have to
		// implement all the actions that happen on approval

		tor.Status__c = 'Pending Approval';
		tor.Date_Submitted__c = System.now();
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Pending Approval');
		pto_tests_common.validate_balances(user.Id, 160, 24);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		tor.Status__c = 'Approved';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Approved');
		pto_tests_common.validate_balances(user.Id, 160, 24);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		// Rather than just setting the status to 'Requires Re-Approval' directly, change the request, which, because
		// the current status is 'Approved', should cause the status to change to 'Requires Re-Approval'.
		tor.End_Date__c -= 1;
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Requires Re-Approval');
		pto_tests_common.validate_balances(user.Id, 160, 16);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		
		// Do 'Rejected' after 'Requires Re-Approval' since the owner stays the same, which 
		// requires the code to actually delete the shares
		tor.Status__c = 'Rejected';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Rejected');
//		pto_tests_common.validate_balances(user.Id, 160, 0);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 0);
		
		// Make sure that any changes from the 'Rejected' status will change the status to 'Requires Re-Approval'.
		tor.End_Date__c += 1;
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Requires Re-Approval');
//		pto_tests_common.validate_balances(user.Id, 160, 24);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);
		
		tor.Status__c = 'Processed';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Processed');
//		pto_tests_common.validate_balances(user.Id, 160, 24);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);

		tor.Status__c = 'Pending Approval';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Pending Approval');
//		pto_tests_common.validate_balances(user.Id, 160, 24);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 24);

		tor.Status__c = 'Canceled';
		update tor;
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Canceled');
//		pto_tests_common.validate_balances(user.Id, 160, 0);
	    try {
	    	delete tor;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 0);
	}

}