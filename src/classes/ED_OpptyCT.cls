public class ED_OpptyCT {
    
    @AuraEnabled
    public static Opportunity getEDInfo(String opptyId) {
        
        Opportunity oppty = new Opportunity();
        
        try {
            oppty = [SELECT Id, Name, ED_Close_Date_Delta__c, ED_Outcome__c, ED_Leading_Causes__c, ED_Prescription__c, ED_Predicted_Close_Date__c, Exec_Meeting__c, Interactive_Demo__c
                     FROM Opportunity
                     WHERE id =: opptyId];
            
        } catch (Exception e) {
            System.debug('Oppty: ' + opptyId);
        }
        return oppty;
    }
    
    @AuraEnabled 
    public static void checkExecMeeting(String opptyId) {
        
        Opportunity o = [SELECT Id, Exec_Meeting__c FROM Opportunity WHERE id =: opptyId][0];
        system.debug('o: ' + o);
        o.Exec_Meeting__c = true;
        
        update o;
        
    }
}