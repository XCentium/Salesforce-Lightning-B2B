public with sharing class ctiApexController {
	public ctiApexController() {

	}


	@auraEnabled
	public Static List<Contact> getTheContacts(String searchTerm) {
		String srch = '%' + searchTerm + '%';
		return [SELECT Email,HomePhone,Id,MobilePhone,Name,Phone FROM Contact WHERE Name LIKE: srch];
	}


	@AuraEnabled
	public Static String createMyCase(String targetId) {
		try {
			Case myCase = new Case();
			myCase.Subject = ' ';
			myCase.Description = ' ';

			String objectType = ctiApexController.getPopupObjectType(targetId);
			if(objectType == 'Account') {
				myCase.AccountId = targetId;
			}
			if(objectType == 'Contact') {
				myCase.ContactId = targetId;
			}

			insert myCase;
            System.debug('myCase.Id : ' + myCase.Id);
			return myCase.Id;
		} catch(Exception excep) {
			return 'Exception : createMyCase : ' + excep.getMessage();
		}
	}


	@AuraEnabled
	public Static String createMyLead(String telephoneNumber) {
		try {
			Lead myLead = new Lead();
			myLead.Company = 'Provide Company Name';
			myLead.LastName = 'New Lead';
			myLead.Phone = telephoneNumber;
			insert myLead;
			return myLead.Id;
		} catch(Exception excep) {
			return 'Exception : createMyLead : ' + excep.getMessage();
		}
	}



	@auraEnabled
	public Static String createMyTask(String theId, String myDescription) {
		//System.debug('coshea : ' + myDuration);
		//Integer myInt = Integer.valueOf(myDuration);

		Task tsk = new Task();
		tsk.CallDisposition = 'Internal';
		tsk.CallObject = 'DemoCall';
		tsk.Subject = 'Call Log';
		tsk.Priority = 'Normal';
		tsk.Description = myDescription;
		//tsk.CallDurationInSeconds = myInt;
		tsk.Type = 'Call';
		tsk.CallType = 'Inbound';
        tsk.TaskSubtype = 'Call';
        tsk.Status = 'Completed';
        tsk.ActivityDate = system.today();

		String objectType = ctiApexController.getPopupObjectType(theId);
		if(objectType == 'Account') {
			tsk.WhatId = theId;
		}
		if(objectType == 'Lead' || objectType == 'Contact') {
			tsk.WhoId = theId;
		}

		insert tsk;

		return tsk.Id;
	}

	// ******************************************************** Here's where my new Apex starts ********************************************************

	@AuraEnabled
	public static String getSessionId() {
		return UserInfo.getSessionId();
	}


	@AuraEnabled
	public static void publishNotifications(List<String> messages, String target) {
		List<CTI_Status_Changed__e> notifications = new List<CTI_Status_Changed__e>();
		for (String message: messages) {
			notifications.add(new CTI_Status_Changed__e(Status__c = message, Target__c = target));
		}
		List<Database.SaveResult> results = EventBus.publish(notifications);
		// Inspect publishing results
		for (Database.SaveResult result : results) {
			if (!result.isSuccess()) {
				for (Database.Error error : result.getErrors()) {
					System.debug('Error returned: ' +
					error.getStatusCode() +' - '+
					error.getMessage());
				}
			}
		}
	}


	public Static String getPopupObjectType(String theId) {
		List<Account> accs = [SELECT Id, Name FROM Account WHERE Id =: theId];
		List<Contact> cons = [SELECT Id, Name FROM Contact WHERE Id =: theId];
		List<Lead> lds = [SELECT Id, Name FROM Lead WHERE Id =: theId];

		if(accs.size() > 0) {
			return 'Account';
		}
		if(cons.size() > 0) {
			return 'Contact';
		}
		if(lds.size() > 0) {
			return 'Lead';
		}
		return 'nada';
	}


	@auraEnabled
	public Static String getAvailableStatusId() {
		List<ServicePresenceStatus> myList = [SELECT DeveloperName,Id,MasterLabel FROM ServicePresenceStatus WHERE DeveloperName = 'Phone_Available'];
		if(myList.size() > 0) {
			return myList[0].Id;
		} else {
			return 'status not found';
		}
	}


	@auraEnabled
	public Static String getBusyStatusId() {
		List<ServicePresenceStatus> myList = [SELECT DeveloperName,Id,MasterLabel FROM ServicePresenceStatus WHERE DeveloperName = 'Busy'];
		if(myList.size() > 0) {
			return myList[0].Id;
		} else {
			return 'status not found';
		}
	}


	@AuraEnabled
	public static String getTheDomainName() {
		return URL.getSalesforceBaseUrl().toExternalForm();
	}

}