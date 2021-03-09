public class AgentOmniChannelStatusController {
    
    @AuraEnabled
    public static UserServicePresence getUserStatus(Id recordId) {
        UserServicePresence us = null;
        
        List<UserServicePresence> userStatus = [
            SELECT Id, User.Name, ServicePresenceStatus.MasterLabel, StatusDuration, StatusStartDate, StatusEndDate, ConfiguredCapacity, IsAway, IsCurrentState
			FROM UserServicePresence 
			WHERE User.Id = :recordId
            ORDER BY StatusStartDate Desc LIMIT 5
            ];       
        
       	us = userStatus[0];      
		
        return us;
    }
    
    @AuraEnabled
    public static User getUser(Id recordId) {
        User u = [
            SELECT Name, Id, LastLoginDate, ManagerId, FullPhotoUrl, MediumPhotoUrl, IsProfilePhotoActive
            FROM User
            WHERE Id = :recordId
                        
        ];
       
        return u;
    }  
    
    @AuraEnabled
    public static List <Case> getCases(Id recordId) {
        List<Case> c = [
            SELECT CaseNumber, Subject, Status, Priority, IsClosed 
            FROM Case
			WHERE OwnerId = :recordId
                        
        ];
       
        return c;
    } 
    
    @AuraEnabled
    public static List <ServicePresenceStatus> getOnlinePresenceStatus() {
        List<ServicePresenceStatus> sp = [
            SELECT DeveloperName,Id,IsDeleted,MasterLabel 
            FROM ServicePresenceStatus 
            WHERE IsDeleted = false AND Id IN (SELECT ServicePresenceStatusId FROM ServiceChannelStatus)
            ORDER by MasterLabel ASC
                        
        ];
       
        return sp;
    } 
    
    @AuraEnabled
    public static List <ServicePresenceStatus> getBusyPresenceStatus() {
        List<ServicePresenceStatus> sp = [
            SELECT DeveloperName,Id,IsDeleted,MasterLabel 
            FROM ServicePresenceStatus 
            WHERE IsDeleted = false AND Id NOT IN (SELECT ServicePresenceStatusId FROM ServiceChannelStatus)
            ORDER by MasterLabel ASC
                        
        ];
       
        return sp;
    } 
}