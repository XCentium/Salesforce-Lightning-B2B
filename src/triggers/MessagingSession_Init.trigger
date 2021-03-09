//This trigger creates a new Case for each new Messaging session record created and associates it with the correct Contact record.
trigger MessagingSession_Init on MessagingSession (before insert) {
    if(System.isBatch()) return;
    for (MessagingSession ms : Trigger.New){
        if(ms.CaseId == null && ms.Origin != 'Triggered Outbound'){
            Case newCase = new Case();
            newCase.Subject = 'New Messaging Case';
            List<MessagingChannel> thisMessagingChannel = [SELECT MessageType FROM MessagingChannel WHERE Id = :ms.MessagingChannelId LIMIT 1];
            if (thisMessagingChannel[0].MessageType == 'Text') {
                newCase.Origin = 'SMS';
            }
            if(thisMessagingChannel[0].MessageType == 'Facebook') {
                newCase.Origin = 'Facebook Messenger';
            }
            
            MessagingEndUser thisMessagingEndUser = [SELECT Id, ContactId FROM MessagingEndUser WHERE Id = :ms.MessagingEndUserId LIMIT 1];
            newCase.ContactId = thisMessagingEndUser.ContactId;

            try {
            insert newCase;
            ms.CaseId = newCase.Id;
            }
            catch(dmlexception e){
                system.debug('Case creation error: ' + e);
            }
        }
    }
}