public class tom_test_pay_cycle_boundaries{
	
	static testMethod void test_pay_cycle_management() {
		// Delete any left over requests from previous tests
		pto_tests_common.clean_data('TEST');
		pto_tests_common.create_core_test_objects();
		
		// First create a pay cycle that covers a large time period 
		Pay_Cycle__c c1 = pto_tests_common.insert_pay_cycle('TEST 2007-FEB', Date.newInstance(2007, 4, 30), '2007', 'TEST');
		
		// Make sure we can process and reset  pay cycles that have no vacation days
    	Integer num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
    	System.assert(num_processed == 0);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c != null)] == 1);
    	num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
     	System.assert(num_processed == 0);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c = null)] == 1);
		
		Map<String, User> test_users = pto_tests_common.get_test_user_ids();

		User subordinate = test_users.get('Subordinate');
		System.assert(subordinate.Id != null);
		System.assert(subordinate.Employee_Number__c != null);

		// Give the subordinates some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 8 * (ptoPackage.max_records_to_process_for_pay_cycle + 1));
		pto_tests_common.validate_balances(subordinate.Id, 8 * (ptoPackage.max_records_to_process_for_pay_cycle + 1), 0);
		
		// Make sure we can process requests that are on the boundary of the number
		// of requests processed in each iteration, when processing/reseting pay cycles
		
		// First process exactly the number of requests that are processed in one iteration.
		// ####### Note that if ptoPackage.max_records_to_process_for_pay_cycle changes, then the end date here also
		// needs to change.
		Time_Off_Request__c tor = pto_tests_common.insert_request(subordinate.Id, 'Approved', Date.newInstance(2007, 2, 2), Date.newInstance(2007, 2, 15), false);
		pto_tests_common.validate_balances(subordinate.Id, 8 * (ptoPackage.max_records_to_process_for_pay_cycle + 1), 8 * ptoPackage.max_records_to_process_for_pay_cycle);

    	num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
    	System.assert(num_processed == ptoPackage.max_records_to_process_for_pay_cycle);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c != null)] == 1);

    	num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
     	System.assert(num_processed == ptoPackage.max_records_to_process_for_pay_cycle);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c = null)] == 1);
    	
    	// Now add one more vacation day and make sure everything is right
		Time_Off_Request__c tor2 = pto_tests_common.insert_request(subordinate.Id, 'Approved', Date.newInstance(2007, 2, 1), Date.newInstance(2007, 2, 1), false);
		pto_tests_common.validate_balances(subordinate.Id, 8 * (ptoPackage.max_records_to_process_for_pay_cycle + 1), 8 * (ptoPackage.max_records_to_process_for_pay_cycle + 1));
		
    	num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
    	System.assert(num_processed == ptoPackage.max_records_to_process_for_pay_cycle);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c = null)] == 1);
		
    	num_processed = ptoPackage.process_pay_cycle_without_commit(c1.Id);
    	System.assert(num_processed == 1);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c != null)] == 1);
		
    	num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
     	System.assert(num_processed == ptoPackage.max_records_to_process_for_pay_cycle);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c != null)] == 1);
		
    	num_processed = ptoPackage.reset_pay_cycle_without_commit(c1.Id);
     	System.assert(num_processed == 1);
    	System.assert([select count() from Pay_Cycle__c where (Id = :c1.Id) and (Processed__c = null)] == 1);
	}		
}