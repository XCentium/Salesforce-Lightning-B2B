public with sharing class Community_Lead_Inbox_Controller {

    
    public List<Lead> LeadInbox {get;set;}
    public String leadID        {get;set;}
    public String msg           {get;set;}
    
    public Community_Lead_Inbox_Controller(){
        LeadInbox = new List<Lead>();
        refreshLeadList();
    }
    
    public void refreshLeadList() {
        LeadInbox = [Select Id, Name, Title, City, Company, toLabel(Industry),
                     CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, 
                     LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name 
                     From Lead 
                     Where IsConverted = false 
                     and Owner.Type='Queue'
                     Order by CreatedDate desc limit 5];
    }
    
    public PageReference AcceptLead() {       
        try {
            Lead theLead = [Select id, Name, OwnerID from Lead where id =: leadID Limit 1];
            theLead.OwnerId = UserInfo.getUserID();
            update theLead; 
        } catch(Exception e) {
            msg = e.getMessage();
        }        
        refreshLeadList();
        return null;
    }

}