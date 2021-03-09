public without sharing class cqb_ContactHighlight_CT {    
    
    @auraenabled
    public static cqb_wrapperClass getContact(String recId){
        Id myId = recId;
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String contactQuery;
        String myContactId;
        
        if (String.valueOf(sobjectType) == 'MessagingSession'){
            contactQuery = 'EndUserContactId';
        } else if (String.valueOf(sobjectType) == 'VoiceCall'){
            VoiceCall vc = [SELECT ID, FromPhoneNumber FROM VoiceCall Where ID = :recId];
            if (vc != null){
               List<Contact> vcContactList = [SELECT ID FROM Contact where Phone = :vc.FromPhoneNumber OR MobilePhone = :vc.FromPhoneNumber];
                if (vcContactList.size()>0){
                    myContactId = vcContactList[0].Id;
                }
            }
        }         
        else {
            contactQuery = 'ContactId';            
        }
        
        if (contactQuery != null){
            String queryString = 'Select Id, ' + contactQuery + ' from ' + sobjectType + ' Where Id=:recId Limit 1';
            SObject myRecord = Database.query(queryString);
            myContactId = String.valueOf(myRecord.get(contactQuery));
        }
        
        User myU;
        try{
            myU = [select FullPhotoUrl from User where ContactId=:myContactId Limit 1];
        } catch(Exception ex){
            myU = null;
        }        
        Contact myC = [Select Id, Name, Title, Salutation from Contact Where Id=:myContactId];
        cqb_wrapperClass wc = new cqb_wrapperClass(myU, myC);
        return wc;
    }               
}