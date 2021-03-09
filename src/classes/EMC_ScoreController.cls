public class EMC_ScoreController {
    
    public static String API_VERSION = 'v45.0';
    
    
    @AuraEnabled
    public static Object getLeadData(String leadId){
        return EMC_Utilities.queryAllFields('Lead', leadId);
    }
    
    @AuraEnabled
    public static String getLeadFields(){
        return EMC_Utilities.getObjectFields('Lead');
    }
    
    @AuraEnabled
    public static Object getOpportunityScore(String opportunityId){
        String[] query = new String[]{
            'Select Id, Score, Insights, BaseId',
                'From OpportunityScore',
                'Where BaseId = \'' + opportunityId + '\''
                };
                
                return Database.query( String.join(query,' ') );
    }
    //Retrieve Highest Version for LeadIQConfig model
    @AuraEnabled
    public static Object getLeadIQConfiguration(){
        String[] query = new String[]{'Select Id, ModelVersion',
            'From LeadIQConfiguration',
            'Order By ModelVersion DESC',
            'Limit 1'
            };
                
                return Database.query( String.join(query,' ') );
    }
    
    @AuraEnabled
    public static Object[] getModelFactor(Integer version){
        String[] query = new String[]{'Select Id, ExternalId, Factor1, Factor2, SourceField1, SourceField2, Type, Value, Version, ConversionCorrelation, ScoreCorrelation',
            'From ModelFactor',
            'Where Version = ' + Integer.valueOf(version),
            'And FeatureType = \'LeadScoring\''
            };
                
                return Database.query( String.join(query,' ') );
    }
    
    @AuraEnabled
    public static Object getLeadInsights(String leadId){
        String[] query = new String[]{'Select Id, ParentId, ModelFactor, ExtractionTime, ExternalId, Intensity, IntensityLevel, Value',
            'From LeadInsight',
            'Where ParentId = \'' + leadId + '\'',
            'And FeatureType = \'LeadScoring\''
            };
                
                return Database.query(String.join(query, ' '));
    }
    
    @AuraEnabled
    public static Object getScoreIntelligence(String leadId){
        String[] query = new String[]{'Select Id, Score, BaseId, LastModifiedTimeOnRecord',
            'From ScoreIntelligence',
            'Where BaseId = :leadId',
            'Limit 1'
            };
                
                return Database.query( String.join(query,' ') );
    }
    
    @AuraEnabled
    public static Boolean deleteModelFactors(SObject[] modelFactors){
        try {
            Database.DeleteResult[] results = Database.delete(modelFactors);
            System.debug(results);
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean deleteLeadInsights(SObject[] leadInsights){
        try {
            Database.DeleteResult[] results = Database.delete(leadInsights);
            System.debug(results);
            return true;
        } catch(Exception e){
            return false;
        }
    } 
    
    @AuraEnabled
    public static Boolean saveOpportunityScore(OpportunityScore scoreData){
        try{
            scoreData.Score = Integer.valueOf(scoreData.Score);
            upsert scoreData;
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Object upsertScoreIntelligence(SObject scoreIntelligence){
        Database.UpsertResult result = Database.upsert(scoreIntelligence);
        System.debug(result);
        
        return result;
    }
    
    @AuraEnabled
    public static Object[] upsertModelFactors(SObject[] modelFactors){
        Database.UpsertResult[] results = Database.upsert(modelFactors);
        System.debug(results);
        
        return results;
    }
    
    @AuraEnabled
    public static Object[] upsertLeadInsight(SObject[] leadInsights){
        Database.UpsertResult[] results = Database.upsert(leadInsights);
        System.debug(results);
        
        return results;
    }
    
    @AuraEnabled
    public static Object upsertData(String sObjectType, String objectData){
        sObject record = Schema.getGlobalDescribe().get(sObjectType).newSObject();
        
        List<Map<String, String>> objectsMap = (List<Map<String, String>>)JSON.deserialize(objectData, List<Map<String, String>>.class);
        
        for(Map<String,String> objectMap: objectsMap){
            if(objectMap.get('fieldType') == 'boolean'){
                record.put(objectMap.get('field'), objectMap.get('value') == 'true' ? true : false);
            }
            else {
                record.put(objectMap.get('field'), objectMap.get('value'));
            }
        }
        
        upsert record;
        return record;
    }
    
    @AuraEnabled
    public static Object restInsertRequest(Boolean singleRecord, String objectName, Object data){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId() );
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(Url.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + API_VERSION + '/sobjects/' + objectName);
        req.setMethod('POST');
        
        Map<String,Object> requestBody = new Map<String,Object>();
        requestBody.put('ModelVersion', 2);
        req.setBody(JSON.serialize(data));
        
        HttpResponse res = http.send(req);
        Object resBody = res.getBody();
        
        return resBody;
    }
    
    @AuraEnabled
    public static Object restUpdateRequest(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('X-HTTP-Method-Override','PATCH');
        req.setMethod('POST');  
        
        HttpResponse res = http.send(req);
        Object resBody = res.getBody();
        
        return resBody;
    }
    
    @AuraEnabled
    public static Object httpRequest(String auth, String endpoint, String method, String data){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer '+auth);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Url.getSalesforceBaseURL().toExternalForm() + endpoint);
        req.setBody(data);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }
}