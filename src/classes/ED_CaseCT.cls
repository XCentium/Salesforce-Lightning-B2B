public class ED_CaseCT {
	@AuraEnabled
    public static Case getEDInfo(String caseId) {
        
        Case c = new Case();
        
        try {
            c = [SELECT ED_Outcome__c, ED_Leading_Causes__c, ED_Prescription__c  
                     FROM Case
                     WHERE id =: caseId];
            
        } catch (Exception e) {
            System.debug('Case: ' + caseId);
        }
        return c;
    }
}