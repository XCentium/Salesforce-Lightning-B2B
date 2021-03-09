public class EinsteinVisionCtrl {
    
    @AuraEnabled
    public static Lead getLead(String Id){
        Lead thisLead = [SELECT Name, Street, Roof_Type__c, Shadow_Roof_Type__c 
                         FROM Lead 
                         WHERE Id =: Id LIMIT 1];
        return thisLead;
    }
    
    @AuraEnabled
    public static Lead updateRoofType(String leadId){
        Lead thisLead = [SELECT Name, Roof_Type__c, Shadow_Roof_Type__c 
                         FROM Lead 
                         WHERE Id =: leadId LIMIT 1];
        
        if (thisLead != null && thisLead.Shadow_Roof_Type__c != null){
            thisLead.Roof_Type__c = thisLead.Shadow_Roof_Type__c;
            update thisLead;
        }
        return thisLead; 
    }

}