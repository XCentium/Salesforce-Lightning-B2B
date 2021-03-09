trigger Case_EinsteinAgent on Case (before insert, after insert) {
    
    if(Trigger.isBefore){
        for(Case c: Trigger.New){
            System.debug(c);
            CaseClassificationHelper.createRecommendations(c);
        }
        /*List<Einstein_Agent_Helper__c> helperConfig = [Select Id, Field__c, Comparator__c, Value__c, Auto_Triage__c, Recommendation_Field__c, Recommendation_Value__c, Recommended_Article__c,Recommended_Article_Score__c 
                                                       From Einstein_Agent_Helper__c 
                                                       Where Active__c = true
                                                       And Auto_Triage__c = true];
        
        
        for(Case c: Trigger.New){
            for(Einstein_Agent_Helper__c rule: helperConfig){
                if( c.get(rule.Field__c) != null){
                    String dataType = EinsteinAgentTriggerHelper.getType(c.get(rule.Field__c));
                    Boolean validRule = EinsteinAgentTriggerHelper.evaluateRule(dataType, c, rule);
                    
                    if(validRule){
                        c.put(rule.Recommendation_Field__c, rule.Recommendation_Value__c);
                    }
                }
            }
        }*/
    }
    
    if(System.isBatch()) return;
    if(Trigger.isAfter){
        for(Case c: Trigger.new){
            if(Trigger.isAfter){
                EinsteinAgentTriggerHelper.createRecommendations(c.Id);
            }
        }
    }
}