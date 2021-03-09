//This trigger creates a new Case for each new Voice Call record created and associates it with the correct Contact record.
trigger VoiceCall_Init on VoiceCall (before insert) {
    if(System.isBatch()) return;
    for (VoiceCall vc : Trigger.New){
        List<Contact> thisContact = [SELECT Id, Name FROM Contact WHERE Phone = :vc.FromPhoneNumber OR Phone = :vc.ToPhoneNumber ORDER BY LastModifiedDate DESC LIMIT 1];
        if((thisContact.isEmpty() == false) && vc.RelatedRecordId == null){
            vc.Contact__c = thisContact[0].Id;
            Case newCase = new Case();
            newCase.Subject = vc.CallType + ' call with ' + thisContact[0].Name;
            newCase.Origin = 'Phone';
            newCase.ContactId = thisContact[0].Id;
            
            try {
                insert newCase;
                vc.RelatedRecordId = newCase.Id;
            }
            catch(dmlexception e){
                system.debug('Case creation error: ' + e);
            }
        }
    }
}