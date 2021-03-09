//This trigger can be used to delete trigger-created Bot Cases after the chat session ends if the Subject field isn't updated during the Bot session by Natural Language or Dialogs selected Menus or Buttons
trigger EinsteinBotsCleanup_Chat on LiveChatTranscript (after update) {
    if(System.isBatch()) return;
    for (LiveChatTranscript lct : Trigger.New){
        if(lct.Status == 'Completed' || lct.Status == 'Missed'){
            if(lct.CaseId != null){
                Case[] thisCase = [SELECT Id, Subject FROM Case WHERE Id = :lct.CaseId];
                if(thisCase[0].Subject.Contains('New Chat Case') || thisCase[0].Subject == null){
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