global with sharing class SurveyLinkManager 
{
    public static SurveyInvitation createSurveyRequest(Id SurveyId, Id ParticipantId, Id NetworkId, String AdditionalIdField, Id AdditionalId)
    {
        SurveyInvitation invite = new SurveyInvitation(
            SurveyId = SurveyId,
            ParticipantId = ParticipantId,
            OptionsAllowGuestUserResponse = true,
            CommunityId = NetworkId,
            Name = 'Private Invitation_' + String.valueOfGmt(DateTime.now()),
            OwnerId = UserInfo.getUserId()
        );
        
        if (String.isNotBlank(AdditionalIdField))
        {
            invite.put(AdditionalIdField, AdditionalId);
        }
        
        return invite;
    }
    
    public static SurveyInvitation createSurveyRequestWithLookup(String SurveyIdOrName, Id ParticipantId, String NetworkIdOrName, String AdditionalIdField, Id AdditionalId)
    {
        Id surveyId;
        if (!isSalesforceIdFormat(SurveyIdOrName)) {
            List<Survey> surveys = [SELECT Id
                                    FROM Survey
                                    WHERE DeveloperName = :SurveyIdOrName
                                    OR Name = :SurveyIdOrName
                                    LIMIT 1];
            surveyId = surveys[0].Id;
        } else {
            surveyId = SurveyIdOrName;
        }
        
        Id networkId;
        if (!isSalesforceIdFormat(NetworkIdOrName)) {
            List<Network> networks = [SELECT Id
                                      FROM Network
                                      WHERE UrlPathPrefix = :NetworkIdOrName
                                      OR Name = :NetworkIdOrName
                                      LIMIT 1];
            networkId = networks[0].Id;
        } else {
            networkId = NetworkIdOrName;
        }
        
        return createSurveyRequest(surveyId, ParticipantId, networkId, AdditionalIdField, AdditionalId);
    }
    
    @InvocableMethod
    public static List<SurveyInvitationResult> createSurveyRequests(List<SurveyInvitationRequest> requests)
    {
        List<SurveyInvitationResult> results = new List<SurveyInvitationResult>();
        List<SurveyInvitation> invites = new List<SurveyInvitation>();
        
        for (SurveyInvitationRequest request : requests)
        {
            SurveyInvitation newSI = createSurveyRequestWithLookup(
                request.surveyId,
                request.participantId,
                request.networkId,
                request.additionalIdField,
                request.additionalId
            );
            invites.add(newSI);
        }
        
        insert invites;
        
        List<Id> inviteIds = new List<Id>();
        
        for (SurveyInvitation invite : invites)
        {
            String inviteId = invite.Id;
            
            inviteIds.add(invite.Id);
            
            SurveyInvitationResult result = new SurveyInvitationResult();
            result.inviteId = inviteId;
            result.success = true;
            results.add(result);
        }
        
        List<Case> cases = [SELECT Id,
                            (SELECT I.InvitationLink
                             FROM Survey_Invitations__r I
                             WHERE I.Id IN :inviteIds)
                            FROM Case
                            WHERE Id IN (SELECT Case__c
                                         FROM SurveyInvitation
                                         WHERE Id IN :inviteIds)];
        
        for (Case c : cases)
        {
            c.Survey_Url__c = c.Survey_Invitations__r[0].InvitationLink;
        }
        
        update cases;
        
        return results;
    }
    
    /**
	* Test a String to see if it is SFDC ID format
	* @param  	sfdcId The ID to test.
	* @return  Returns true if the ID is valid-looking, false if it is not.
	*/
    public static Boolean isSalesforceIdFormat(String sfdcId){
        try {
            if ( Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(sfdcId).matches()){
                // Try to assign it to an Id
                Id id = sfdcId;
                
                // If the tests passed, it's valid
                return true;
            }
        } catch (Exception e) {
            // StringException
        }
        
        // ID is not valid
        return false;
    }
    
    global class SurveyInvitationRequest {
        @InvocableVariable(label='Survey Id or Name' description='Id, Name, or Developer Name of Survey' required=true)
        global String surveyId;
        
        @InvocableVariable(label='Participant Id' description='Id of Contact or User' required=true)
        global Id participantId;
        
        @InvocableVariable(label='Community Id or Name' description='Id, Name, or Url Path Prefix of Community aka Network' required=true)
        global String networkId;
        
        @InvocableVariable(label='Additional Id Field Name' description='An optional lookup id field, for example to Case, API like Case__c' required=false)
        global String additionalIdField;
        
        @InvocableVariable(label='Additional Id' description='An optional lookup id, e.g. Id of Case' required=false)
        global Id additionalId;
    }
    
    global class SurveyInvitationResult {
        @InvocableVariable
        global Id inviteId;
        
        @InvocableVariable
        global Boolean success;
    }
}