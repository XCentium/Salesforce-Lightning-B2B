global class pto_web_services{
	
	webService static Integer reset_pay_cycle(Id pay_cycle_id) {
		Integer result = ptoPackage.reset_pay_cycle_without_commit(pay_cycle_id);
		return result;
	}
	
	webService static void cancelRequest(Id request_id) {
		ptoPackage.cancel_request_without_commit(request_id);
	}
	
	webService static Integer process_pay_cycle(Id pay_cycle_id) {
		Integer result = ptoPackage.process_pay_cycle_without_commit(pay_cycle_id);
		return result;
	}
	
	webService static Time_Off_Info__c get_time_off_info_for_current_user() {
		Time_Off_Info__c result = null;
		
		Time_Off_Info__c[] toi = [select Note__c, User__c, User__r.Name, Name, Employee_Number__c, Payroll_System__c, Payroll_System__r.Name, Total_PTO_Accrued__c, Total_PTO_Available__c, Total_Pending_PTO_Requests__c from Time_Off_Info__c where User__c = :UserInfo.getUserId()];
		System.assert(toi.size() <= 1);
		if (toi.size() == 1) {
			result = toi[0];
		}
		
		return result;
	}
	
	webService static Holiday_Calendar__c[] get_holidays_for_users(String[] employee_numbers, String year) {
		Holiday_Calendar__c[] result = null;
		
		Time_Off_Info__c[] tois = [select Payroll_System__c from Time_Off_Info__c where Name in :employee_numbers];
		Set<Id> payroll_system_ids = new Set<Id>();
		for (Time_Off_Info__c toi : tois) {
			if (toi.Payroll_System__c != null) {
				payroll_system_ids.add(toi.Payroll_System__c);
			}
		}
		if (payroll_system_ids.size() > 0) {
			result = [select Id, Name, Year__c, Date__c From Holiday_Calendar__c where (Payroll_System__c in :payroll_system_ids) and (Year__c = :year)];
		}
		
		return result;
	}
}