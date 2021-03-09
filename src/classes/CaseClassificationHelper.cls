public class CaseClassificationHelper {
    
    public static void createRecommendations(Case c){
        DateTime now = DateTime.now();
        String currentTime = now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Map<String,List<cc_AiInsightValue>> predictionFieldsMap = new Map<String,List<cc_AiInsightValue>>();
        
        List<Einstein_Agent_Helper__c> helperConfig = [Select Id,Field__c,Comparator__c,Value__c,Confidence__c,
                                                       Recommendation_Field__c,Recommendation_Value__c,
                                                       Recommended_Article_Score__c
                                                       From Einstein_Agent_Helper__c 
                                                       Where Active__c = true];
        
        
        for(Einstein_Agent_Helper__c rule: helperConfig){
            if( c.get(rule.Field__c) != null){
                String dataType = getType(c.get(rule.Field__c));
                Boolean validRule = evaluateRule(dataType, c, rule);
                
                if(validRule){
                    if(rule.Recommendation_Field__c != null && rule.Recommendation_Value__c != null){
                        cc_AiInsightValue insightValue = new cc_AiInsightValue(rule.Recommendation_Value__c, rule.Confidence__c);
                        if(predictionFieldsMap.containsKey(rule.Recommendation_Field__c)){
                            List<cc_AiInsightValue> insightValues = predictionFieldsMap.get(rule.Recommendation_Field__c);
                            insightValues.add(insightValue);
                            predictionFieldsMap.put(rule.Recommendation_Field__c, insightValues);
                        } else {
                            List<cc_AiInsightValue> insightValues = new List<cc_AiInsightValue>(); 
                            insightValues.add(insightValue);
                            predictionFieldsMap.put(rule.Recommendation_Field__c, insightValues);
                        }
                    }
                }
            }
        }
        
        if(predictionFieldsMap.size() > 0){
            List<cc_Insights> insights = new List<cc_Insights>();
            for(String fieldName: predictionFieldsMap.keySet()){
                cc_Insights insight = new cc_Insights(fieldName, predictionFieldsMap.get(fieldName));
                insights.add(insight);
            }
            
            System.debug(insights);
            c.demoRecommendations__c = JSON.serialize(new Map<String,List<cc_Insights>>{'insights' => insights});
        }
    }
    
    public static Boolean evaluateRule(String dataType, Case c, Einstein_Agent_Helper__c rule){
        Boolean evaluation = false;
        System.debug('EVALUATING');
        
        //Gets messy since you cannot type dynamically. Move code up to cast before evaluation
        switch on rule.Comparator__c {
            when 'EQ' {
                System.debug('EQ');
                evaluation = c.get(rule.Field__c) == rule.Value__c;
            }
            when 'NOT_EQ' {
                System.debug('NOT EQ');
                evaluation = c.get(rule.Field__c) != rule.Value__c;
            } 
            when 'STARTS' {
                System.debug('STARTS');
                String caseStringValue = String.valueOf(c.get(rule.Field__c));
                String ruleStringValue = String.valueOf(rule.Value__c);
                evaluation = caseStringValue.startsWithIgnoreCase(ruleStringValue);
            }
            when 'ENDS' {
                System.debug('ENDS');
                String caseStringValue = String.valueOf(c.get(rule.Field__c));
                String ruleStringValue = String.valueOf(rule.Value__c);
                evaluation = caseStringValue.endsWithIgnoreCase(ruleStringValue);
            }
            when 'CONTAINS'{
                System.debug('CONTAINS');
                String caseStringValue = String.valueOf(c.get(rule.Field__c));
                String ruleStringValue = String.valueOf(rule.Value__c);
                evaluation = caseStringValue.containsIgnoreCase(ruleStringValue);
            }
            when 'LT' {
                System.debug('LT');
                switch on dataType {
                    //insure proper typing
                    when 'Integer' {
                        evaluation = Integer.valueOf(c.get(rule.Field__c)) < Integer.valueOf(rule.Value__c);
                    }
                    when 'Double' {
                        evaluation = Double.valueOf(c.get(rule.Field__c)) < Double.valueOf(rule.Value__c);
                    }
                    when 'Date' {
                        evaluation = Date.valueOf(c.get(rule.Field__c)) < Date.valueOf(rule.Value__c);
                    }
                    when 'DateTime' {
                        evaluation = DateTime.valueOf(c.get(rule.Field__c)) < DateTime.valueOf(rule.Value__c);
                    }
                }
            }
            when 'LTE' {
                System.debug('LTE');
                switch on dataType {
                    //insure proper typing
                    when 'Integer' {
                        evaluation = Integer.valueOf(c.get(rule.Field__c)) <= Integer.valueOf(rule.Value__c);
                    }
                    when 'Double' {
                        evaluation = Double.valueOf(c.get(rule.Field__c)) <= Double.valueOf(rule.Value__c);
                    }
                    when 'Date' {
                        evaluation = Date.valueOf(c.get(rule.Field__c)) <= Date.valueOf(rule.Value__c);
                    }
                    when 'DateTime' {
                        evaluation = DateTime.valueOf(c.get(rule.Field__c)) <= DateTime.valueOf(rule.Value__c);
                    }
                }
            }
            when 'GTE' {
                System.debug('GTE');
                switch on dataType {
                    //insure proper typing
                    when 'Integer' {
                        evaluation = Integer.valueOf(c.get(rule.Field__c)) >= Integer.valueOf(rule.Value__c);
                    }
                    when 'Double' {
                        evaluation = Double.valueOf(c.get(rule.Field__c)) >= Double.valueOf(rule.Value__c);
                    }
                    when 'Date' {
                        evaluation = Date.valueOf(c.get(rule.Field__c)) >= Date.valueOf(rule.Value__c);
                    }
                    when 'DateTime' {
                        evaluation = DateTime.valueOf(c.get(rule.Field__c)) >= DateTime.valueOf(rule.Value__c);
                    }
                }
            }
            when 'GT' {
                System.debug('GT');
                switch on dataType {
                    //insure proper typing
                    when 'Integer' {
                        evaluation = Integer.valueOf(c.get(rule.Field__c)) > Integer.valueOf(rule.Value__c);
                    }
                    when 'Double' {
                        evaluation = Double.valueOf(c.get(rule.Field__c)) > Double.valueOf(rule.Value__c);
                    }
                    when 'Date' {
                        evaluation = Date.valueOf(c.get(rule.Field__c)) > Date.valueOf(rule.Value__c);
                    }
                    when 'DateTime' {
                        evaluation = DateTime.valueOf(c.get(rule.Field__c)) > DateTime.valueOf(rule.Value__c);
                    }
                }
            }
        }
        
        System.debug(evaluation);
        return evaluation;
    }
    
    public static string getType(Object o) {
        if(o==null) return '';
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Double';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }
    
    public class cc_Insights {
        public String predictionField;
        public List<cc_AiInsightValue> aiInsightValues;
        
        public cc_Insights(String f, List<cc_AiInsightValue> ai){
            this.predictionField = f;
            this.aiInsightValues = ai;
        }
    }
    
    public class cc_AiInsightValue {
        public String value;
        public Decimal confidence;
        
        public cc_AiInsightValue(String v, Decimal c){
            this.value = v;
            this.confidence = c;
        }
    }
}