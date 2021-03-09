public class SCContactHighlightController {
    public String cID {get;set;}
    public String aID {set;get;}
    public Contact c {get;set;}
    public Account a {get;set;}
    public Boolean cleans {get;set;}
    public Integer total {get;set;}
    public List <Event> elist {get;set;}  
    public List <Task> tlist {get;set;}
    
    public SCContactHighlightController (){
        ApexPages.currentPage().getParameters().get('id');
        ID currRecordId = ID.valueOf(ApexPages.currentPage().getParameters().get('Id'));
        String primaryTabObjectType = String.valueOf(currRecordId.getSObjectType());
        
        // Determine whether this is an account or a contact object...
        if (primaryTabObjectType == 'Contact') {
            // Populate the contact details
            // Grab the account details from the contat record
            cID = currRecordId;
            c = [SELECT Name, LeadSource, Activity_Indicator__c, Total_of_Activities__c, Days_Since_Last_Activity__c, Phone, Email,
                Title, AccountId, Account.Name, Account.Industry, Account.Type, Account.Closed_Won_Value__c, Account.Rating_Indicator__c FROM Contact WHERE id =:cID];
            aID = c.AccountId;
        } else if (primaryTabObjectType == 'Account') { 
            aID = currRecordId;
        } else {
            System.debug('Ummmmm.... I cannot handle a ' + primaryTabObjectType + ' object.');
        }
                                     
        a = [Select Name, Id, Site, Phone, NumberOfEmployees, AccountSource, Website, Industry, Type, Closed_Won_Value__c, Rating_Indicator__c, Region__c, Days_Since_Activity__c From Account Where id =:aID];        
        
        elist = [Select Id, AccountId From Event Where AccountId = :a.Id];
        
        tlist = [Select Id, AccountId From Task Where AccountId =:a.Id];
        
        /*IF(a.CleanStatus == 'In Sync'){ 
            cleans= true;
        } */   
        
        total = elist.size() + tlist.size();
        
        
    }

}