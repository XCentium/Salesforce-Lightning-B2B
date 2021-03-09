@isTest(SeeAllData=true) 
private class SoftphoneSearchControllerTest {   
    
    private static testMethod void testDoSearch() {
       SoftphoneSearchController softphoneSearchController = new SoftphoneSearchController();       
       softphoneSearchController.contactName = 'Lauren';
       softphoneSearchController.doSearch();
       System.assert(softphoneSearchController.contactList.size() > 0, 'Result list should contain at least one contact');       
    }

    private static testMethod void testGetContacts() {
        
        // ANI to search on
        string ANI = '1234567890'; 
        // Create Contact
        Contact contact = new Contact();
        contact.FirstName = 'Test' + DateTime.now();
        contact.LastName = 'SoftphoneSearchControllerTest';
        contact.phone = ANI;
        insert contact; 
        try {
            // Test contact query method
            System.assert(SoftphoneSearchController.getContacts(ANI).contains(ANI), 'Result should contain at least one contact with ANI');
        } finally {
            // Delete Contact
            delete contact;
        }
    }
    
    private static testMethod void testGetCases() {
        // We're going to hardcode the case number here because the call control always looks for case 00001001
        string CaseNumber = '00001001';    
        System.assert(SoftphoneSearchController.getCases(CaseNumber).contains(CaseNumber), 'Result should contain at least one case with this case number');
    }
}