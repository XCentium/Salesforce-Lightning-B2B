public with sharing class Community_Recent_Cases_Controller {

    User loggedInUser = [Select id,contactId,Contact.AccountId from User where id = :UserInfo.getUserId()];
    
    public List<Case> recentCases {get;set;}
    
    public Community_Recent_Cases_Controller() {
        recentCases = [Select Id, Subject, Status, CaseNumber,LastModifiedDate 
                     From Case 
                     Where ContactId = :loggedInUser.ContactId 
                     Order by LastModifiedDate Desc Limit 5];       
    }
}