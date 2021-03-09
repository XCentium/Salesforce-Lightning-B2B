global with sharing class ConsoleCaseShortCutsEXT {
   
    public String uID {get;set;}
    
    public ConsoleCaseShortCutsEXT(){
        uID = UserInfo.getUserId();
    }
    
    public static List<Id> getQueuesForUser(String userId) 
    {
        List<Id> listGroupIds = new List<Id>();
        List<GroupMember> listGroupMembers = [Select g.GroupId From GroupMember g 
                                                where g.Group.Type='Queue'
                                                and g.UserOrGroupId=:userId];
                                                
        if (listGroupMembers!=null && listGroupMembers.size()>0) {      
            for (GroupMember gm:listGroupMembers) {
                listGroupIds.add(gm.GroupId);
            }
        }
        
        return listGroupIds;
    }
    
    @RemoteAction
    global static Id retrieveNextCase(String userId){
            
            //First find out which queues this user is a member of
            List<Id> listGroupIds = getQueuesForUser(userId);
            Id nextcaseID;
        
            if(listGroupIds.size()>0) 
            {
                //Find an open case that is assigned to one of those queues
                Case caseObj = [select c.Id,c.OwnerId from Case c where 
                                                            c.IsClosed=false 
                                                            and c.OwnerId in :listGroupIds 
                                                            limit 1 
                                                            for update];
                                                    
                if (caseObj!=null) {        
                    //If we found one, assign it to the current user
                    caseObj.OwnerId = userId;
                    update caseObj;
                    
                    nextcaseID = caseObj.Id;
                    
                    return caseObj.Id;
                }
            }
            return nextcaseID;
     } 
    
    @RemoteAction
    global static String retrieveCaseNumber(String cId){
        Case c = [SELECT CaseNumber FROM Case Where Id=: cId];
        return c.CaseNumber;
    }
    
    @RemoteAction
    global static String closeCase(String cId){
        Case c = [SELECT Id, Status FROM Case Where Id=: cId];
        c.Status = 'Closed';
        Update c;
        return null;
    }    
}