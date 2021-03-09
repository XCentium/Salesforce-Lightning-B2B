public class tom_test_error_conditions{

	static testMethod void test_package_error_conditions() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();

		// Make sure we handle the case where the payroll queue doesn't exist. This has to
		// be the first test, because otherwise the queue will get cached.
		Group payroll_queue = [select Id, Name from Group where (Name = 'Time_Off_Manager_Payroll') and (Type = 'Queue')];
		System.assert(payroll_queue != null);
		payroll_queue.Name = 'XXX-YYY-TEST';
		update payroll_queue;
	    try {
			payroll_queue = ptoPackage.get_payroll_queue();
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('Exactly one Queue named Time_Off_Manager_Payroll must exist, and instead 0 were found.') > -1);
	    }
		payroll_queue.Name = 'Time_Off_Manager_Payroll';
		update payroll_queue;
		
	    try {
	    	Time_Off_Info__c toi = new Time_Off_Info__c();
	    	insert toi;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('The User__c field is required when inserting a new Time_Off_Info__c record.') > -1);
	    }

	    try {
	    	ptoPackage.get_user_and_manager('a0030000007sWYmAAM');
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('User records could not be found for the following IDs: a0030000007sWYmAAM ') > -1);
	    }

		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Subordinate');
		System.assert(user.Id != null);
		System.assert(user.Employee_Number__c != null);

		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(user.Id, 400);

		// Make sure we deal with very large numbers of requested days
	    try {
			Time_Off_Request__c tor = pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 4, 16), false);
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot request time off for more than 40.0 days.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 400, 0);
		
		// But make sure we can ask for the maximum number of vacation days.
		Time_Off_Request__c tor = pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 4, 13), false);
		pto_tests_common.validate_balances(user.Id, 400, 320);
		delete tor;
		pto_tests_common.validate_balances(user.Id, 400, 0);
		
		pto_tests_common.set_pto_balance(user.Id, 160);
		pto_tests_common.validate_balances(user.Id, 160, 0);
		
		// Make sure that time off requests cannot be submimtted with a Status other than Not Submitted
	    try {
			Time_Off_Request__c tor2 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
			tor2.Status__c = 'Approved';
			insert tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('New Time Off Requests must be created with a Status of \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 0);
	    
		// Make sure requests that are submitted with a NULL status are correctly set to Not Submitted status
		Time_Off_Request__c tor2 = pto_tests_common.insert_request(user.Id, null, Date.newInstance(2007, 1, 31), Date.newInstance(2007, 2, 1), false);
		pto_tests_common.validate_time_off_request_status(tor2.Id, user.Id, 'Not Submitted');
		pto_tests_common.validate_balances(user.Id, 160, 16);
		
		// Next change the Requestor__c, which should be an error
	    try {
			tor2.Requestor__c = user.Manager_PTO__c;
	    	update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('The Requestor field cannot be changed.') > -1);
			tor2.Requestor__c = user.Id;
	    }
		
		// Try and update the request so that it is for zero days.
		// First make sure it detects weekdend-only vacations
		Date old_start_date = tor2.Start_Date__c;
		Date old_end_date = tor2.End_Date__c;
	    try {
			tor2.Start_Date__c = Date.newInstance(2007, 2, 17);
			tor2.End_Date__c = Date.newInstance(2007, 2, 18);
	    	update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot request time off for zero days.') > -1);
			tor2.Start_Date__c = old_start_date;
			tor2.End_Date__c = old_end_date;
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		// Now make sure it detects holiday-only vacations.
	    try {
			tor2.Start_Date__c = Date.newInstance(2007, 2, 20);
			tor2.End_Date__c = Date.newInstance(2007, 2, 20);
	    	update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot request time off for zero days.') > -1);
			tor2.Start_Date__c = old_start_date;
			tor2.End_Date__c = old_end_date;
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);

		// Check to make sure we handle Time_Off_Request__c validation
		tor2.Status__c = 'Processed';
		update tor2;
		pto_tests_common.validate_time_off_request_status(tor2.Id, user.Id, 'Processed');
		pto_tests_common.validate_balances(user.Id, 160, 16);

	    try {
	    	delete tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		
		old_start_date = tor2.Start_Date__c;
	    try {
			tor2.Start_Date__c = Date.newInstance(2007, 1, 1);
	    	update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not modify the start date for a Time Off Request that has already been processed.') > -1);
			tor2.Start_Date__c = old_start_date;
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		pto_tests_common.validate_time_off_request_status(tor2.Id, user.Id, 'Processed');
		
		old_end_date = tor2.End_Date__c;
	    try {
			tor2.End_Date__c = Date.newInstance(2007, 2, 5);
	    	update tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not modify the end date for a Time Off Request that has already been processed.') > -1);
			tor2.End_Date__c = old_end_date;
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		pto_tests_common.validate_time_off_request_status(tor2.Id, user.Id, 'Processed');

		// Make sure we handle the case where the user has more than one Time_Off_Info__c records
	    try {
			Time_Off_Info__c toi = new Time_Off_Info__c();
			toi.User__c = user.Id;
			insert toi;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('The User \'' + user.Id + '\' already has a Time_Off_Info__c record, and only one is permitted.') > -1);
	    }
	    
	    // Make sure NULL dates are processed properly
	    try {
			Time_Off_Request__c tor3 = pto_tests_common.build_unsubmitted_request(user.Id, null, Date.newInstance(2007, 2, 16), false);
			insert tor3;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('The Start Date is required.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
	    try {
			Time_Off_Request__c tor3 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), null, false);
			insert tor3;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('The End Date is required.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);
		
	    // Make sure the end date does not come before the start date
	    try {
			Time_Off_Request__c tor3 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 15), false);
			insert tor3;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('ou cannot request time off for zero days.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 160, 16);

	    // Make sure we handle the case where the user is not enabled for Time-Off Requests
		Time_Off_Info__c toi = [select Id, Disable_time_off_requests__c from Time_Off_Info__c where User__c = :user.Id];
		System.assert(toi != null);
		System.assert(toi.Disable_time_off_requests__c != null);
		System.assert(!toi.Disable_time_off_requests__c);
		toi.Disable_time_off_requests__c = true;
		update toi;
		ptoPackage.remove_user_time_off_info(user.Id);
		toi = [select Id, Disable_time_off_requests__c from Time_Off_Info__c where User__c = :user.Id];
		System.assert(toi != null);
		System.assert(toi.Disable_time_off_requests__c != null);
		System.assert(toi.Disable_time_off_requests__c);
	    try {
			Time_Off_Request__c tor3 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
			insert tor3;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You can not create Time Off Requests because you are not eligible for time off.') > -1);
	    }
		toi.Disable_time_off_requests__c = false;
		update toi;
		toi = [select Id, Disable_time_off_requests__c from Time_Off_Info__c where User__c = :user.Id];
		System.assert(toi != null);
		System.assert(toi.Disable_time_off_requests__c != null);
		System.assert(!toi.Disable_time_off_requests__c);
		Time_Off_Request__c tor3 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
		insert tor3;
		delete tor3;
	    
		// Make sure we handle the case where there is no Time Off Info record
		toi = [select Id from Time_Off_Info__c where User__c = :user.Id];
		System.assert(toi != null);
		delete toi;
		ptoPackage.remove_user_time_off_info(user.Id);
	    try {
			Time_Off_Request__c tor4 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
			insert tor4;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You cannot create Time Off Requests because your Time-Off Balances and your Payroll System have not been configured.') > -1);
	    }
	}

}