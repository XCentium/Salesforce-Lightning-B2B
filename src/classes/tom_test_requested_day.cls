public class tom_test_requested_day{

	public static testMethod void test_requested_day_trigger() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Subordinate');
		System.assert(user.Id != null);
		System.assert(user.Manager_PTO__c != null);

		// Give the subordinate some vacation time
		pto_tests_common.set_pto_balance(user.Id, 160);
		pto_tests_common.validate_balances(user.Id, 160, 0);

		Time_Off_Request__c tor = pto_tests_common.insert_request(user.Id, 'Not Submitted', Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		
		pto_tests_common.validate_time_off_request_status(tor.Id, user.Id, 'Not Submitted');
		pto_tests_common.validate_balances(user.Id, 160, 8);
		
		Requested_Day__c[] days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 1);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 2, 16), tor.Id, '02-February', 8, user.Employee_Number__c, 'Not Submitted', false);

		Pay_Cycle__c c1 = pto_tests_common.insert_pay_cycle('TEST 2007-FEB', Date.newInstance(2007, 2, 28), '2007', 'TEST');
		System.assert(c1 != null);
		
		days[0].Pay_Cycle__c = c1.Id;
		update days;
		
		pto_tests_common.validate_balances(user.Id, 160, 0);
		
		days[0].Pay_Cycle__c = null;
		update days;
		
		pto_tests_common.validate_balances(user.Id, 160, 8);
		
		delete tor;
		tor = null;
		pto_tests_common.validate_balances(user.Id, 160, 0);
	}

}