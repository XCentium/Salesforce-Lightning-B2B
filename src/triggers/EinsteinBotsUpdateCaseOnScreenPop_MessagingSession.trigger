//This trigger automatically updates the Status of Cases associated with the Messaging session to Working when an agent joins the session.
trigger EinsteinBotsUpdateCaseOnScreenPop_MessagingSession on MessagingSession (after update) {
    if(System.isBatch()) return;
    for (MessagingSession ms : Trigger.New){
        if (ms.CaseId != null && String.IsNotBlank(ms.CaseId)){
            Case[] thisCase = [SELECT Id, Status, ContactId FROM Case WHERE Id = :ms.CaseId LIMIT 1];
            MessagingEndUser[] thisMessagingEndUser = [SELECT Id, ContactId FROM MessagingEndUser WHERE Id = :ms.MessagingEndUserId LIMIT 1];
            try {
                thisCase[0].ContactId = thisMessagingEndUser[0].ContactId;
                update thisCase[0];
            } catch (DmlException e) {
                system.debug('Case update error: ' + e);
            }
            if(ms.Status == 'Active'){
                if(thisCase[0].Status != 'Working'){
                    try {
                      thisCase[0].OwnerId = ms.OwnerId;
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