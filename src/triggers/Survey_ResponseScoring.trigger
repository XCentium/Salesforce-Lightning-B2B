trigger Survey_ResponseScoring on SurveyResponse (after update) {
    // get all the responses, that are completed
    Set<Id> responseIds = new Set<Id>();
    for (SurveyResponse sr : Trigger.new)
    {
        if (sr.Status == 'Completed')
        {
            responseIds.add(sr.Id);
        }
    }

    // are there any responses that we need to process?
    if (responseIds.size() > 0)
    {
        // get the question responses for the responses
        // for the correct type to score, 'Rating' is of interest here
        List<SurveyQuestionResponse> sqrs = [SELECT ResponseShortText, InvitationId
                                             FROM SurveyQuestionResponse
                                             WHERE Question.QuestionType = 'Rating'
                                             AND ResponseId in :responseIds];
        
        // are there any cases we need to process?
        if (sqrs.size() > 0)
        {
            // gather all the Cases that are under consideration
            Set<Id> inviteIds = new Set<Id>();
            for (SurveyQuestionResponse sqr : sqrs)
            {
                inviteIds.add(sqr.InvitationId);
            }
            
            // get the invitations
            List<SurveyInvitation> inviteList = [SELECT Id, Score__c
                                                 FROM SurveyInvitation
                                                 WHERE Id in :inviteIds];
            Map<Id, SurveyInvitation> inviteMap = new Map<Id, SurveyInvitation>(inviteList);
            
            // add the values of the question response to the cases
            for (SurveyQuestionResponse sqr : sqrs)
            {
                SurveyInvitation inv = inviteMap.get(sqr.InvitationId);
                String scoreStr = sqr.ResponseShortText;
                if (String.isNotBlank(scoreStr))
                {
                    Double score = Double.valueOf(scoreStr);
                    if (inv.Score__c == null)
                    {
                        inv.Score__c = score;
                    }
                    else
                    {
                        inv.Score__c = inv.Score__c + score;
                    }
                }
            }
            
            // update the cases
            update inviteList;
        }
    }
}