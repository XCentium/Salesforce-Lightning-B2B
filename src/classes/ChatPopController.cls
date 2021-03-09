public class ChatPopController {


   
    @AuraEnabled
    public static LiveChatTranscript getChatRecords(String recordId) {
        LiveChatTranscript vc = [SELECT Id,  Contactid, caseid from LiveChatTranscript where ID = :recordId];
        return vc;
    }    
    @AuraEnabled
    public static String getCaseId(String recordId) {
        LiveChatTranscript vc = [SELECT Id, Contactid, caseid from LiveChatTranscript where ID = :recordId];
        return vc.caseid;
    }
    @AuraEnabled
    public static String getContactId(String recordId) {
        LiveChatTranscript vc = [SELECT Id,  Contactid from LiveChatTranscript where ID = :recordId];
        return vc.Contactid;
    }    
}