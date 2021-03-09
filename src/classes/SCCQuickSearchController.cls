global class SCCQuickSearchController {
	global SCCQuickSearchController() {
		
	}

	@remoteAction
	global static List<Lead> getLeads(String inputString){
		String temp = '%' + inputString + '%';
		//List<sObject> theLeads = Database.query('SELECT Id, Name, Phone, Email, Status FROM Lead WHERE Name LIKE '+inputString+' OR Compagny LIKE '+inputString+'');
		List<Lead> theLeads = [Select Id, Name, Phone, Email, Status from Lead where Name LIKE :temp];
		return theLeads;
	}

	@remoteAction
	global static List<Contact> getContacts(String inputString){
		String temp = '%' + inputString + '%';
		//List<sObject> theLeads = Database.query('SELECT Id, Name, Phone, Email, Status FROM Lead WHERE Name LIKE '+inputString+' OR Compagny LIKE '+inputString+'');
		List<Contact> theContacts = [Select Id, Name, Phone, Email from Contact where Name LIKE :temp];
		return theContacts;
	}

	@remoteAction
	global static List<Account> getAccounts(String inputString){
		String temp = '%' + inputString + '%';
		//List<sObject> theLeads = Database.query('SELECT Id, Name, Phone, Email, Status FROM Lead WHERE Name LIKE '+inputString+' OR Compagny LIKE '+inputString+'');
		List<Account> theAccounts = [Select Id, Name, Phone, Industry from Account where Name LIKE :temp];
		return theAccounts;
	}

	@remoteAction
	global static List<Case> getCases(String inputString){
		String temp = '%' + inputString + '%';
		//List<sObject> theLeads = Database.query('SELECT Id, Name, Phone, Email, Status FROM Lead WHERE Name LIKE '+inputString+' OR Compagny LIKE '+inputString+'');
		List<Case> theCases = [Select Id, CaseNumber, Subject, Status from Case where Subject LIKE :temp OR CaseNumber LIKE :temp];
		return theCases;
	}
}