public class tom_test_pay_cycle_mgmt{

	static testMethod void test_pay_cycle_management() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		// First create two pay cycles. Make them different from the standard US 2 week cycles, just
		// to make sure there's nothing special about "2 weeks" in the code.
		Pay_Cycle__c c1 = pto_tests_common.insert_pay_cycle('TEST 2007-FEB', Date.newInstance(2007, 2, 28), '2007', 'TEST');
		Pay_Cycle__c c2 = pto_tests_common.insert_pay_cycle('TEST 2007-MAR', Date.newInstance(2007, 3, 30), '2007', 'TEST');
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();

		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);
		System.assert(subordinate.Employee_Number__c != null);

		User subordinate2 = test_users.get('Subordinate2');
		System.assert(subordinate.Id != null);
		System.assert(subordinate.Employee_Number__c != null);

		// Give the subordinates some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 200);
		pto_tests_common.validate_balances(subordinate.Id, 200, 0);
		pto_tests_common.set_pto_balance(subordinate2.Id, 200);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 0);

		// Now create 8 requests: 
		//		1) An approved request before both pay cycles
		//		2) An approved request in the first pay cycle
		//		3) An approved request overlapping the two pay ctycles
		//		4) An approved request in the second pay cycle
		//		5) An approved request ending beyond the second pay cycle (but having some days in that cycle)
		//		6) An approved request beyond the second pay cycle
		//		7) A request not yet submitted, in the first pay cycle
		Time_Off_Request__c[] tors = new Time_Off_Request__c[9];
		tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 1, 31), Date.newInstance(2007, 1, 31), false);		// 1/31/07
		tors[1] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 1), Date.newInstance(2007, 2, 1), false);		// 2/1/07
		tors[2] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), false);		// 2/28/07, 3/1/07
		tors[3] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 3, 2), Date.newInstance(2007, 3, 2), false);		// 3/2/07
		tors[4] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 3, 30), Date.newInstance(2007, 4, 2), false);		// 3/30/07, 4/2/07
		tors[5] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 4, 3), Date.newInstance(2007, 4, 3), false);		// 4/3/07
		tors[6] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 2), Date.newInstance(2007, 2, 2), false);		// 2/2/07
		tors[7] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), false);		// 2/28/07, 3/1/07
		tors[8] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), true);		// 2/28/07, 3/1/07

		Id[] owner_ids = new Id[tors.size()];
		for (Integer i = 0; i < owner_ids.size(); i++) {
			owner_ids[i] = subordinate.Id;
		}
		owner_ids[7] = subordinate2.Id;
		owner_ids[8] = subordinate2.Id;
		
		String[] status = new String[tors.size()];
		for (Integer i = 0; i < status.size(); i++) {
			status[i] = 'Approved';
		}
		status[6] = 'Not Submitted';
		
		pto_tests_common.insert_requests(tors, owner_ids, status);

		pto_tests_common.validate_balances(subordinate.Id, 200, 72);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 16);
		
	    try {
	    	ptoPackage.process_pay_cycle_without_commit(null);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('process_pay_cycle called with NULL ID.') > -1);
	    }

	    try {
	    	ptoPackage.process_pay_cycle_without_commit('a0030000007sWYmAAM');
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('The pay cycle with ID \'a0030000007sWYmAAM\' does not exist.') > -1);
	    }

		Integer num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
		System.assert(num_processed == 5);

	    try {
	    	ptoPackage.process_pay_cycle_without_commit(c1.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('This Pay Cycle has already been processed, and must be reset before it can be processed again.') > -1);
	    }

		Requested_Day__c[] days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Pay_Cycle__c = :c1.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 5);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 1, 31), tors[0].Id, '01-January', 8, subordinate.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 2, 1), tors[1].Id, '02-February', 8, subordinate.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 2, 28), tors[2].Id, '02-February', 8, subordinate.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 2, 28), tors[7].Id, '02-February', 8, subordinate2.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[4], Date.newInstance(2007, 2, 28), tors[8].Id, '02-February', -8, subordinate2.Employee_Number__c, 'Processed', true);
		
		// Make sure all the days that were supposed to be processed were, in fact, processed
		Integer num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c != 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 5);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c = 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 3);
		num = [select count() from Pay_Cycle__c where (Processed__c != null) and (Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 1);

		pto_tests_common.validate_balances(subordinate.Id, 200, 48);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 8);

		num_processed = ptoPackage.process_pay_cycle_without_commit(c2.Id);
		System.assert(num_processed == 5);
		
		days = [select Time_Off_Request__c, Time_Off_Request__r.Status__c, Requested_Day__c, Month_of_Request__c, Hours__c, Employee_Number__c, Pay_Cycle__r.Processed__c From Requested_Day__c where (Pay_Cycle__c = :c2.Id) and (IsDeleted = false) order by Requested_Day__c];
		System.assert(days.size() == 5);
		pto_tests_common.validate_requested_day(days[0], Date.newInstance(2007, 3, 1), tors[2].Id, '03-March', 8, subordinate.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[1], Date.newInstance(2007, 3, 1), tors[7].Id, '03-March', 8, subordinate2.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[2], Date.newInstance(2007, 3, 1), tors[8].Id, '03-March', -8, subordinate2.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[3], Date.newInstance(2007, 3, 2), tors[3].Id, '03-March', 8, subordinate.Employee_Number__c, 'Processed', true);
		pto_tests_common.validate_requested_day(days[4], Date.newInstance(2007, 3, 30), tors[4].Id, '03-March', 8, subordinate.Employee_Number__c, 'Processed', true);
		
		// Make sure all the days that were supposed to be processed were, in fact, processed
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c != 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 2);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c = 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 1);
		num = [select count() from Pay_Cycle__c where (Processed__c != null) and (Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 2);
		
		pto_tests_common.validate_balances(subordinate.Id, 200, 24);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 0);
		
	    try {
	    	ptoPackage.reset_pay_cycle_without_commit(null);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('reset_pay_cycle called with NULL ID.') > -1);
	    }

	    try {
	    	ptoPackage.reset_pay_cycle_without_commit('a0030000007sWYmAAM');
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('The pay cycle with ID \'a0030000007sWYmAAM\' does not exist.') > -1);
	    }

		num_processed = ptoPackage.reset_pay_cycle_without_commit(c2.Id);
		System.assert(num_processed == 5);

		// Make sure all the days that we just "unprocessed" are, in fact, no longer processed
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = :c2.Id) and (IsDeleted = false)];
		System.assert(num == 0);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c != 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 5);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c = 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 3);
		num = [select count() from Pay_Cycle__c where (Processed__c != null) and (Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 1);
		
		pto_tests_common.validate_balances(subordinate.Id, 200, 48);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 8);
		
	    try {
	    	ptoPackage.reset_pay_cycle_without_commit(c2.Id);
	    	System.assert(false);
	    } catch (ptoPackage.Time_Off_Exception e) {
			System.assert(e.getMessage().indexOf('This Pay Cycle has not yet been processed, and so it cannot be reset.') > -1);
	    }

		num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
		System.assert(num_processed == 5);
		
		// Make sure all the days that we just "unprocessed" are, in fact, no longer processed
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = :c1.Id) and (IsDeleted = false)];
		System.assert(num == 0);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c != 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 13);
		num = [select count() from Requested_Day__c where (Pay_Cycle__c = null) and (Time_Off_Request__r.Status__c = 'Processed') and (Time_Off_Request__r.Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 0);
		num = [select count() from Pay_Cycle__c where (Processed__c != null) and (Payroll_System__r.Name = 'TEST') and (IsDeleted = false)];
		System.assert(num == 0);

		pto_tests_common.validate_balances(subordinate.Id, 200, 72);
		pto_tests_common.validate_balances(subordinate2.Id, 200, 16);
	}

}