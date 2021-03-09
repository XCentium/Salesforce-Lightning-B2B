global class OmniDirectToAgentRoutingHelper {
    
    @InvocableMethod (label='Omni - Route Case Direct to Agent')
    public static void routeDirectToAgent(List<CaseDirectRoutingRequest> requests){
        for (CaseDirectRoutingRequest request : requests){
            List<AgentWork> Aw = new List<AgentWork>();            
            //This is the developer Service Channel name found in Setup|Omni|Service Channels
            ServiceChannel SC = [select Id from ServiceChannel where DeveloperName = :request.serviceChannelName];            
            //Get the Case ID
            Case caseObj = [Select Id, OwnerId from Case where Id = :request.caseId];
			//Get the User ID - This is the User for assigning the work            
            User username = [SELECT Id FROM User WHERE Id = :request.userId];
            //Get User Service Presence - Used to check if the Agent is online/available
            List<UserServicePresence> usp = [select Id,UserId from UserServicePresence where UserId = :username.Id and ServicePresenceStatusId != '' and IsCurrentState = true];
            //Check if the user is available
            if (usp.size() > 0 && usp[0].UserId != null)
            {
                Aw.add(new AgentWork(UserId = usp[0].UserId, WorkItemId = caseObj.Id,ServiceChannelId=SC.Id));
                insert Aw;
            }
            else if (request.fallbackQueue != null){
                //Assign to fallback Queue
                //This is the developer Queue name found in Setup|Manage Users|Queues
                Group Grp = [select Id,Name from Group where DeveloperName = :request.fallbackQueue];
                if (Grp.Id != null){
                    caseObj.OwnerId = Grp.Id;
                    update caseObj;
                }
            }
        }
    }
    
    global class CaseDirectRoutingRequest{
        @InvocableVariable (label = 'Case Id' required=true)
        global String caseId;
        @InvocableVariable (label = 'User ID to Assign to' required=true)
        global String userId;
        @InvocableVariable (label = 'Service Channel Developer Name' required=true)
        global String serviceChannelName;
        @InvocableVariable (label = 'Fallback Queue Developer Name')
        global String fallbackQueue;
    }
}