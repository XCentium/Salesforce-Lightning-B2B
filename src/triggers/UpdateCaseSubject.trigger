trigger UpdateCaseSubject on SocialPost (after insert) {
    if(System.isBatch()) return;
    try{
        List<SocialPost> sp = Trigger.new;
        List<SocialPost> checkformorethanone = [SELECT Id From SocialPost WHERE ParentId =: sp[0].ParentId];
        if (checkformorethanone.size() == 1){
            SocialPostSubjectUpdateClass.updateSubject(Trigger.newMap.keySet());        
        }
        else{}
    }
    catch(Exception e){}
}

// This trigger fires when a new Social Post is received and creates a case.
// The default subject for a new case from a social post is "TWEET FROM" or "POST FROM" and the customer name.
// This isn't great because the subject of the case is used by Knowledge to suggest articles.
// So this calls an Apex Class that copies the Content field of the social post to the Subject field of the case.
// It also truncates it to 50 characters, so the case subject isn't too long.subject isn't too long.
// 
// Most of the work is done by the Apex Class SocialPostSubjectUpdateClass, so look there to modify this trigger's behavior.