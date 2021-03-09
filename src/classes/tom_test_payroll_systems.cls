public class tom_test_payroll_systems{

	public static testMethod void test_payroll_systems() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		Payroll_System__c test_payroll_system = pto_tests_common.get_test_payroll_system('TEST');
		System.assert([select Id from Payroll_System__c where Name = 'TEST'].Id == test_payroll_system.Id);
		
		test_payroll_system.Max_Negative_PTO_Balance__c = -8;
		update test_payroll_system;
		pto_tests_common.clear_test_payroll_system();

		Map<String, User> test_users = pto_tests_common.get_test_user_ids();
		User user = test_users.get('Subordinate');
		System.assert(user.Id != null);
		System.assert(user.Manager_PTO__c != null);

		pto_tests_common.validate_balances(user.Id, 0, 0);
		
		// Go negative the max amount for PTO
		Time_Off_Request__c tor = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 16), false);
		insert tor;
		pto_tests_common.validate_balances(user.Id, 0, 8);
		
		// Now go over the max negative amount for PTO
		Time_Off_Request__c tor2 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 3, 16), Date.newInstance(2007, 3, 16), false);
	    try {
	    	insert tor2;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You may not exceed your available PTO Balance (-1.0 days) by more than 1 days.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 0, 8);
		
		// Next increase the allowed PTO negative balance but disable the Payroll System for the Time Off Manager
		test_payroll_system.Enabled_For_Time_Off_Manager__c = false;
		test_payroll_system.Max_Negative_PTO_Balance__c = -16;
		update test_payroll_system;
		pto_tests_common.clear_test_payroll_system();
		ptoPackage.clear_user_time_off_info();
		
		// Try and create a time off request, which should fail because the payroll system is disabled
		Time_Off_Request__c tor5 = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 4, 16), Date.newInstance(2007, 4, 16), false);
	    try {
	    	insert tor5;
	    	System.assert(false);
	    } catch (System.DmlException e) {
			System.assert(e.getDmlMessage(0).indexOf('You can not create Time Off Requests because your payroll system is not enabled for this application.') > -1);
	    }
		pto_tests_common.validate_balances(user.Id, 0, 8);
		
		// Make sure we can deal with payroll systems that do not exist
	    try {
			Payroll_System__c missing_payroll_system = ptoPackage.get_payroll_system('INVALID');
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('There must be exactly one Payroll System named \'INVALID\'.') > -1);
	    }
	}

}