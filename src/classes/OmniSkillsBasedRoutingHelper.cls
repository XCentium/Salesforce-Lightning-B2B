Global class OmniSkillsBasedRoutingHelper {
    @InvocableMethod (label='Omni - Route Case to Skills')
    public static void routeUsingSkills(List<CaseSkillsRoutingRequest> requests) {     
        
        for (CaseSkillsRoutingRequest request : requests) {
            // Add SkillsBased PendingServiceRouting
            // Make sure that IsReadyForRouting = False until Skills are added
            PendingServiceRouting psrObj = new PendingServiceRouting(
                CapacityWeight = 1,
                IsReadyForRouting = FALSE,
                RoutingModel  = 'MostAvailable',
                RoutingPriority = request.Priority,
                RoutingType = 'SkillsBased',
                ServiceChannelId = getChannelId('Cases'),
                WorkItemId = request.caseId
            );
            insert psrObj;
            //Get the ID of the newly created PendingServiceRouting to use for attaching Skills
            psrObj = [select id, IsReadyForRouting from PendingServiceRouting where id = : psrObj.id];
            
            // Now add SkillRequirement(s)
            SkillRequirement srObj = new SkillRequirement(
                RelatedRecordId = psrObj.id,
                SkillId = getSkillId(request.SkillName),
                SkillLevel = request.SkillLevel
            );
            insert srObj;
            
            // Add other Skill Requirements as required
            // Copy/Paste below to add a 3rd, 4th, nth Skill Requirement
            if (request.SkillName2!=null){
                SkillRequirement srObj2 = new SkillRequirement(
                    RelatedRecordId = psrObj.id,
                    SkillId = getSkillId(request.SkillName2),
                    SkillLevel = request.SkillLevel2
                );
                insert srObj2;
            }
            
            // Update PendingServiceRouting as IsReadyForRouting
            psrObj.IsReadyForRouting = TRUE;
            update psrObj;
            
        }
        return;
    }
    
    public static String getChannelId(String channelName) {
        ServiceChannel channel = [Select Id From ServiceChannel Where DeveloperName = :channelName];
        return channel.Id;
    }
    
    public static String getSkillId(String skillName) {      
        Skill skill = [Select Id From Skill Where DeveloperName = :skillName];
        return skill.Id;
    }
    
    global class CaseSkillsRoutingRequest
    {
        @InvocableVariable(required=true label = 'Case ID')
        global string caseId;
        @InvocableVariable(required=true label = 'Skill 1 Developer Name')
        global String SkillName;
        @InvocableVariable(required=true label = 'Skill 1 Level')
        global Integer SkillLevel;
        @InvocableVariable(required=true label = 'Routing Priority')
        global Integer Priority;      
        @InvocableVariable (label = 'Skill 2 Developer Name')
        global String SkillName2;
        @InvocableVariable (label = 'Skill 2 Level')
        global Integer SkillLevel2;
    }    
}