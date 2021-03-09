//This trigger can be used to delete trigger-created Bot Cases after the Messaging session ends if the Subject field isn't updated during the Bot session by Natural Language or Dialogs selected Menus or Buttons
trigger EinsteinBotsCleanup_Messaging on MessagingSession (after update) {
    if(System.isBatch()) return;
    for (MessagingSession ms : Trigger.New){
        if(ms.Status == 'Ended'){
            if(ms.CaseId != null){
                Case[] thisCase = [SELECT Id, Subject FROM Case WHERE Id = :ms.CaseId];
                if(thisCase[0].Subject.Contains('New Messaging Case') || thisCase[0].Subject == null){
                    try {
                        delete thisCase;
                    } catch (DmlException e) {
                        system.debug('Case delete error: ' + e);
                    }
                }
            }
        }
    }
}