public class IntelligentAlerts {
	@AuraEnabled
    public static List<Intelligent_Alert__c> accountAlerts(Id recid) {
        Schema.SObjectType sobjectType = recid.getSObjectType();
        String type = String.valueOf(sobjectType);
        String filter;
        
        if(type == 'Account'){
           filter = recid; 
        }
        if(type == 'RetailStore'){
            String rstore = [SELECT AccountId FROM RetailStore WHERE Id = :recid].AccountId;
            filter = rstore;
        }
        
        return [SELECT Id,Account__r.Name,Account__r.Id, Cause_1_Detail__c,
                Cause_1_Metric__c,Cause_2_Detail__c,Cause_2_Metric__c,
                Description__c, Name,Predicted_on_Shelf_Availablility__c ,
                Product__r.Name, Product__r.purl__c FROM Intelligent_Alert__c 
                WHERE Account__c = :filter  
        ];
    }
}