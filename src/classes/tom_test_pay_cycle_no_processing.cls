public class tom_test_pay_cycle_no_processing {

	static testMethod void tom_test_pay_cycle_no_processing() {
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

		// Give the subordinates some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 200);
		pto_tests_common.validate_balances(subordinate.Id, 200, 0);

/*		
		// Make sure that the flag to prevent processing works
		Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Approved', 2, 0, Date.newInstance(2007, 2, 2));
		pto_tests_common.validate_balances(subordinate.Id, 200, 200, 0, 16);
		
		Requested_Day__c day = [select Id, Do_not_include_in_Pay_Cycle__c from Requested_Day__c where Time_Off_Request__c = :tor.Id limit 1];
		System.assert(day != null);
		day.Do_not_include_in_Pay_Cycle__c = true;
		update day;
		pto_tests_common.validate_balances(subordinate.Id, 200, 200, 0, 8);
		
    	Integer num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
    	System.assert(num_processed == 1);
     	System.assert([select count() from Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (Do_not_include_in_Pay_Cycle__c = true) and (Pay_Cycle__c = null)] == 1);
    	System.assert([select count() from Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (Do_not_include_in_Pay_Cycle__c = false) and (Pay_Cycle__c != null)] == 1);
		pto_tests_common.validate_balances(subordinate.Id, 200, 200, 0, 0);

    	num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
     	System.assert(num_processed == 1);
    	System.assert([select count() from Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (Do_not_include_in_Pay_Cycle__c = true) and (Pay_Cycle__c = null)] == 1);
    	System.assert([select count() from Requested_Day__c where (Time_Off_Request__c = :tor.Id) and (Do_not_include_in_Pay_Cycle__c = false) and (Pay_Cycle__c = null)] == 1);
 		pto_tests_common.validate_balances(subordinate.Id, 200, 200, 0, 8);
    	
		day.Do_not_include_in_Pay_Cycle__c = false;
		update day;
		pto_tests_common.validate_balances(subordinate.Id, 200, 200, 0, 16);

    	tor.Status__c = 'Not Submitted';
    	update tor;
    	delete tor;
*/
	}
}