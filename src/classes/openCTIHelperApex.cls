global class openCTIHelperApex {

	public openCTIHelperApex() {

	}

	@remoteAction
	global Static Contact getContactViaId(String myContactId) {
		myContactId = myContactId.trim();
		return [SELECT AccountId,Account.Name,Email,HomePhone,Id,MobilePhone,Name,Phone,Title FROM Contact WHERE Id=:myContactId];
	}

	@remoteAction
	global Static String createMyConfig(String myContactName, String myAccountName, String myContactId, String myAccountId, String myTitle, String myPhone, Boolean myActive, Boolean popMyContact) {
		openCTIconfig__c cti = new openCTIconfig__c();
		cti.Account__c = myAccountId;
		cti.AccountName__c = myAccountName;
		cti.Contact__c = myContactId;
		cti.ContactName__c = myContactName;
		cti.isActive__c = myActive;
		cti.Phone__c = myPhone;
		cti.Title__c = myTitle;

		cti.popContact__c = popMyContact;

		insert cti;

		return cti.Id;
	}

}