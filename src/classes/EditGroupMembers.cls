global class EditGroupMembers{
    @future
    global static void add(List<Id> groupIds, List<Id> userIds)
    {
        List<GroupMember> newMembers = new List<GroupMember>();
        for(integer i=0;i<groupIds.size();i++)
        {
            newMembers.add(new GroupMember(GroupId=groupIds[i],UserOrGroupId=userIds[i]) );
        }
        
        List<Database.SaveResult> srList = Database.insert(newMembers,false);
        // Iterate through each returned result
        for(Database.SaveResult sr : srList)
        {    
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted GroupMember: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        
    }
    @future
    global static void del(List<Id> groupdIds)
    {
        List<GroupMember> membs = [select Id from GroupMember where Id in :groupdIds];
        delete membs;
    }
}