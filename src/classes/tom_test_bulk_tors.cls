public class tom_test_bulk_tors{
 
	static testMethod void test_bulk_ops_on_time_off_requests() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();

		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Subordinate');
		System.assert(user.Id != null);
		System.assert(user.Manager_PTO__c != null);

		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(user.Id, 320);
		pto_tests_common.validate_balances(user.Id, 320, 0);
		
		Id[] user_ids = new Id[]{user.Id, user.Id};

		Time_Off_Request__c[] tors = new Time_Off_Request__c[2];
		tors[0] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 26), false);
		tors[1] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 3, 16), Date.newInstance(2007, 3, 23), false);
		pto_tests_common.insert_requests(tors, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
		
		Id[] tor_ids = new Id[]{tors[0].Id, tors[1].Id};
		
		pto_tests_common.validate_time_off_requests_status(tor_ids, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
		pto_tests_common.validate_balances(user.Id, 320, 96);
		
		Requested_Day__c[] days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tors[0].Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 6);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 19), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 21), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 2, 22), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[4], Date.newInstance(2007, 2, 23), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[5], Date.newInstance(2007, 2, 26), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);

		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tors[1].Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 6);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 3, 16), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 3, 19), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 3, 20), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 3, 21), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[4], Date.newInstance(2007, 3, 22), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[5], Date.newInstance(2007, 3, 23), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);

		// Next modify the request and make sure that the Days_Requested__c objects are correct
		tors[0].End_Date__c = Date.newInstance(2007, 2, 21);
		tors[1].End_Date__c = Date.newInstance(2007, 3, 20);
		update tors;

		pto_tests_common.validate_time_off_requests_status(tor_ids, user_ids, new String[]{'Not Submitted', 'Not Submitted'});
		pto_tests_common.validate_balances(user.Id, 320, 48);
		
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tors[0].Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 3);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 19), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 21), tors[0].Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);
		
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tors[1].Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 3);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 3, 16), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 3, 19), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 3, 20), tors[1].Id, '03-March', 8, user.Employee_Number__c, 'Not Submitted', false);		

		delete tors;
		pto_tests_common.validate_balances(user.Id, 320, 0);
		System.assert([select count() from Time_Off_Request__c where Payroll_System__r.Name = 'TEST'] == 0);
	}

}