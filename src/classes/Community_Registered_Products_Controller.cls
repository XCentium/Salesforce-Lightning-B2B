public class Community_Registered_Products_Controller{

    User loggedInUser = [Select id, ContactId__c from User where id = :UserInfo.getUserId()];
    
    public List<Asset> MyRegisteredProducts {get;set;}
    
    public Community_Registered_Products_Controller(){
        MyRegisteredProducts = new List<Asset>();
        try{
        MyRegisteredProducts = [select id,Name,SerialNumber,InstallDate,UsageEndDate,Status,Image__c 
                                from Asset 
                                where ContactId = :loggedInUser.ContactId__c 
                                order by SerialNumber desc limit 5];
        } catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
}