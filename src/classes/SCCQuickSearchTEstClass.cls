@isTest 
private class SCCQuickSearchTEstClass {
    static testMethod void validateHelloWorld() {
    	SCCQuickSearchController sc = new SCCQuickSearchController();

    	Contact c = new Contact();
    	c.FirstName = 'Test';
    	c.LastName ='Marcel';
    	insert c;

    	List<Contact> cs = SCCQuickSearchController.getContacts('Test');
    	System.assertEquals(c.Id, cs[0].Id);

    	Case ca = new Case();
    	ca.Subject = 'Test';
    	insert ca;

    	List<Case> cas = SCCQuickSearchController.getCases('Test');
    	System.assertEquals(ca.Id, cas[0].Id);

    	Lead l = new Lead();
   		l.FirstName = 'test';
   		l.LastName ='Marcel';
   		insert l;

    	List<Lead> ls = SCCQuickSearchController.getLeads('test');
    	System.assertEquals(l.Id, ls[0].Id);

    	/*
    	Account a = new Account();
    	a.Name = 'Test';
    	insert a;
		----- Throws 'Unexpected token 'List'.... ??????????? -------
    	List<Account> as = SCCQuickSearchController.getAccounts('Test');
    	System.assertEquals(a.Id, as[0].Id);
    	*/

    }
}