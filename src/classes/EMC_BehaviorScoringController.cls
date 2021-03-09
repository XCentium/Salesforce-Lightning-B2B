public class EMC_BehaviorScoringController {
    
    public static String API_VERSION = 'v48.0';
    
    @AuraEnabled
    public static Object getRecordData(String recordId, String sobjectType){
        return EMC_Utilities.queryAllFields(sobjectType, recordId);
    }
    
    @AuraEnabled
    public static String getLeadFields(){
        return EMC_Utilities.getObjectFields('Lead');
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
        String[] query = new String[]{'Select Id, ExternalId, FeatureType, Factor1, Factor2, SourceField1, SourceField2, Type, Value, Version, ConversionCorrelation, ScoreCorrelation',
            'From ModelFactor',
            'Where FeatureType = \'EngagementScoring\''
            };
                
                return Database.query( String.join(query,' ') );
    }
    
    @AuraEnabled
    public static Object getLeadInsights(String leadId){
        String[] query = new String[]{'Select Id, ParentId, FeatureType, ModelFactor, ExtractionTime, ExternalId, Intensity, IntensityLevel, Value',
            'From LeadInsight',
            'Where ParentId = \'' + leadId + '\'',
            'And FeatureType = \'EngagementScoring\''
            };
                
                return Database.query(String.join(query, ' '));
    }
    
    @AuraEnabled
    public static Object getEngagementScore(String recordId){
        String query = 'SELECT BaseId,EngagementScore,Id,LastModifiedTimeOnRecord From EngagementScore Where BaseId = :recordId Limit 1';
        return Database.query(query);
    }

    public static String getSession(){
        User restUser = [Select Username From User Where CommunityNickname = 'euser' Limit 1];
        HttpRequest request = new HttpRequest();
        
        String endpoint = 'https://login.salesforce.com/services/oauth2/token';
        endpoint += '?grant_type=password';
        endpoint += '&client_id=3MVG9KsVczVNcM8zdoozgJaLPPYhYyCTdBF5O2FEjAShjwa.x7YBtZq1jm52I3mqom4QqIPMGs5Ww89tI7WDe';
        endpoint += '&client_secret=3636748017614097236';
        endpoint += '&username=' + restUser.Username;
        endpoint += '&password=z6wcfF7vYJo1GFB0Xxlm';
        request.setMethod('POST');
        
        System.debug(endpoint);
        request.setEndpoint(endpoint);
        HttpResponse res = (new Http()).send(request);
        System.debug(res);
        
        Map<String,Object> session = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        return String.valueOf(session.get('access_token'));
    }
    
    public static void sendRequest(String sid, String endpoint, String method, String body){
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sid);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + API_VERSION + endpoint);
        req.setMethod(method);
        
        if(method != 'GET' && body != null){
            req.setBody(body);
        }
        
        HttpResponse res = (new Http()).send(req);
        System.debug(res);
        System.debug(res.getBody());
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
    public static String handleSaveRecords(String endpoint, String method, String data){
        /*String sid = getSession();
        try{
            sendRequest(sid,'/'+sobjectName,'POST', recordsJSON);
            return true;
        }catch(Exception e){
            return false;
        }*/
        String sid = getSession();

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer '+sid);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Url.getSalesforceBaseURL().toExternalForm() + endpoint);
        req.setBody(data);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }


    @AuraEnabled
    public static Object restInsertRequest(Boolean singleRecord, String objectName, Object data){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String sid = getSession();
        req.setHeader('Authorization', 'Bearer ' + sid );
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
        
        String sid = getSession();

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer '+sid);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Url.getSalesforceBaseURL().toExternalForm() + endpoint);
        req.setBody(data);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }
}