//This trigger automatically updates the Status of Cases associated with LiveChatTranscript to Working when an agent joins the chat session.
trigger EinsteinBotsUpdateCaseOnScreenPop_Chat on LiveChatTranscript (after update) {
    if(System.isBatch()) return;
    for (LiveChatTranscript lct : Trigger.New){
        if(lct.Status == 'InProgress'){
            if (lct.CaseId != null && String.IsNotBlank(lct.CaseId)){
                Case[] thisCase = [SELECT Id, Status FROM Case WHERE Id = :lct.CaseId];
                if(thisCase[0].Status != 'Working'){
                    try {
                      thisCase[0].OwnerId = lct.OwnerId;
                      thisCase[0].Status = 'Working';
                      update thisCase[0];
                    } catch (DmlException e) {
                      system.debug('Case update error: ' + e);
                    }
                }
            }
        }
    }
}