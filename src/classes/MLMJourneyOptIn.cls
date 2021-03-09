public class MLMJourneyOptIn {

    @AuraEnabled 
    public static List<IDO_Customer_Journey__c > getAllJourneys() { 
        return [SELECT Name,ID,Audience__c,Description__c,Image__c, Total_Contacts_Completed__c, Total_Participants__c,Completed_without_purchase_count__c, Open_Rate__c,Not_Opened_Count__c, Unsubscribed_Count__c FROM IDO_Customer_Journey__c];
    } 
    @AuraEnabled 
    public static String getUserInfo() { 
        string userid = UserInfo.getUserId();
        String contid = [SELECT ContactId From USER WHERE id = :userid].ContactId;
        return contid;
    } 
    
    @AuraEnabled
    public static String getContactId(String commId){
        return [SELECT ContactId FROM User WHERE ID = : commID].ContactId;
    }
    @AuraEnabled 
    public static List<Contact> GetOptInContacts(String cID,String journeyid) { 
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        List<Id > journeyoptin = new List<Id>();
        for(IDO_Journey_Opt_In__c j : [SELECT Contact__c FROM IDO_Journey_Opt_In__c WHERE Journey__c = :journeyid]){
            journeyoptin.add(j.Contact__c);
        } 
        return [SELECT Id,Name, Total_Order_Amount__c  FROM Contact WHERE Id NOT in:journeyoptin AND Id != :cID LIMIT 10]; 
    } 
    @AuraEnabled 
    public static List<Contact> CommunityAddToJourney(String journeyid,String cID) { 
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        String journeyName = [SELECT Name FROM IDO_Customer_Journey__c WHERE Id = :journeyid].Name;

        IDO_Journey_Opt_In__c jopt = New IDO_Journey_Opt_In__c();
            jopt.Contact__c = cID;
            jopt.Journey__c = journeyid;
            jopt.Name  = journeyName + ' - Opt In';
        try {
            Insert jopt;
        }catch (DmlException e) {
            System.debug('Error while inserting Opt In Record');
        }
        
        List<Id> journeyoptin = new List<Id>();
        for(IDO_Journey_Opt_In__c j : [SELECT Contact__c FROM IDO_Journey_Opt_In__c WHERE Journey__c = :journeyid]){
            journeyoptin.add(j.Contact__c);
        } 
        return [SELECT Id,Name, Total_Order_Amount__c  FROM Contact WHERE Id NOT in:journeyoptin AND Id != :cID LIMIT 10];
    }
    @AuraEnabled
    public static Integer CheckJourneyOptIn(String cID,String journeyid){
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        return [SELECT count() FROM IDO_Journey_Opt_In__c WHERE Contact__c = :cID AND Journey__c = :journeyid];
    }
    @AuraEnabled
    public static List<IDO_Journey_Opt_In__c> ContactJourneyOptIn(String cID,String journeyid){
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        return [SELECT Id,Name, Journey__c, Contact__c FROM IDO_Journey_Opt_In__c WHERE Contact__c = :cID AND Journey__c = :journeyid];
    }
    @AuraEnabled
    public static List<IDO_Journey_Opt_In__c > getOptInJourney(String cID){
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        return [SELECT Contact__c, Journey__c FROM IDO_Journey_Opt_In__c WHERE Contact__c = :cID];
    }
    @AuraEnabled 
    public static List<IDO_Customer_Journey__c > AddtoJourneys(String cID,String Journey) { 
        Id userId = UserInfo.getUserId();
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        
        
        
        String journeyName = [SELECT Name FROM IDO_Customer_Journey__c WHERE Id = :Journey].Name;
        
        IDO_Journey_Opt_In__c jopt = New IDO_Journey_Opt_In__c();
            jopt.Contact__c = cId;
            jopt.Journey__c = Journey;
            jopt.Name  = journeyName;
        try {
                    Insert jopt;
        }catch (DmlException e) {
                    System.debug('Error while inserting Opt In Record');
        }
        
        return [SELECT Name,ID,Audience__c,Description__c,Image__c FROM IDO_Customer_Journey__c];
    }
    @AuraEnabled 
    public static List<IDO_Customer_Journey__c > RemovetoJourneys(String cID,String Journey) { 
        String journeyName = [SELECT Name FROM IDO_Customer_Journey__c WHERE Id = :Journey].Name;
        Id userId = UserInfo.getUserId();
        IDO_Journey_Opt_In__c[] opt;
        if(cID == null){
            cID = [select contactid from user where id =:UserInfo.getUserId()].contactid;
        }
        opt = [SELECT Id FROM IDO_Journey_Opt_In__c WHERE Contact__c = :cID AND Journey__c = :Journey];
        
        try {
            delete opt;
        } catch (DmlException e) {
            System.debug('Error while deleting Opt In Record');
        }
        
        return [SELECT Name,ID,Audience__c,Description__c,Image__c FROM IDO_Customer_Journey__c];
    }  
    @AuraEnabled 
    public static List<IDO_Journey__c> getJourneyDetails(String jId) { 
        return [SELECT Name,Description__c, Timing_Information__c,Status__c FROM IDO_Journey__c WHERE Journey__c = :jId Order By Order__c ];
    } 

}