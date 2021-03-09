public class Insights_InsightGeneratorCtrl {
    
    public static String API_VERSION =  'v48.0'; 
    
    @AuraEnabled
    public static List<Object> getPredictionDefinitions(){
        String predictionDefinitionsQuery = 'SELECT Id, DeveloperName,Language,MasterLabel,Mode,SobjectType,SortOrder,Status,Type ';
        predictionDefinitionsQuery += 'FROM PredictionDefinition ';
        predictionDefinitionsQuery += 'Where SobjectType IN (\'Opportunity\',\'Account\',\'Campaign\')';
        
        List<SObject> predictionDefinitions = Database.query(predictionDefinitionsQuery);
        return predictionDefinitions;
    }
    
    @AuraEnabled
    public static List<Object> getAccountInsights(Id accountId){
        List<AccountInsight> accountInsights = [SELECT AccountId,AccountName,Activity,ActualHeardWithinDays,
                                                CompetitorName,ContactName,ContactTitle,ExpectedHeardWithinDays,
                                                Id,LastHeard,Name,NumberOfNewsArticles,Rationale,Score,Title,TrendType,Type
                                                FROM AccountInsight 
                                                WHERE AccountId = :accountId];
        return accountInsights;
    }
    
    @AuraEnabled
    public static List<Object> getContactSuggestionInsight(Id accountId){
        List<ContactSuggestionInsight> contactSuggestionInsight = [SELECT AccountId,AccountName,Activity,Address,City,ContactTitle,
                                                                   Country,Email,FirstName,GeocodeAccuracy,Id,LastName,Latitude,Longitude,
                                                                   Name,Phone,PostalCode,RationaleLabel,Score,State,Status,Street 
                                                                   FROM ContactSuggestionInsight
                                                                   WHERE AccountId = :accountId];
        return contactSuggestionInsight;
    }
    
    @AuraEnabled
    public static List<Object> getAccountInsightNewsArticles(Id insightId){
        List<AccountInsightNewsArticle> newsArticles = [SELECT AccountId,AccountInsightId, DateTime,ExternalIdentifier,
                                                        Id,ImageUrl,Name,SourceName,Title,Url 
                                                        FROM AccountInsightNewsArticle
                                                        WHERE AccountInsightId = :insightId];
        return newsArticles;
    }
    
    
    @AuraEnabled
    public static List<Object> getOpportunityInsights(Id opportunityId){
        List<OpportunityInsight> opportunityInsight = [SELECT Activity,ActualHeardWithinDays,CloseDate,CompetitorName,ContactName,
                                                       ContactTitle,ExpectedHeardWithinDays,Id,LastHeard,Name,OpportunityId,Rationale,
                                                       Reason,Score,TaskDue,Title,TrendType,Type
                                                       FROM OpportunityInsight
                                                       WHERE OpportunityId =: opportunityId];
        return opportunityInsight;
    }
    
    @AuraEnabled
    public static List<Object> getOpportunityContactSuggestion(Id opportunityId){
        List<OpportunityContactRoleSuggestionInsight> opportunityContactRoleSuggestionInsight = [SELECT Activity,ContactId,ContactTitle,CreatedRecordId,Email,
                                                                                                 FirstName,Id,LastName,Name,OpportunityId,OpportunityName,Phone,
                                                                                                 RationaleLabel,Role,Score,Status 
                                                                                                 FROM OpportunityContactRoleSuggestionInsight
                                                                                                 WHERE OpportunityId = :opportunityId];
        return opportunityContactRoleSuggestionInsight;
    }
    
    @AuraEnabled
    public static List<Object> getCampaignInsights(Id campaignId){
        List<CampaignInsight> campaignInsights = [SELECT AssetField1,CampaignId,Id,InsightType,InternalTitle,InternalType,LastReferencedDate,MarketingAssetId,Name,Score,Title,TrendType
                                                  FROM CampaignInsight 
                                                  WHERE CampaignId = :campaignId];
        return campaignInsights;
    }
    
    @AuraEnabled
    public static List<Object> getCampaignRationales(Id campaignInsightId){
        List<CampaignInsightRationale> campaignRationales = [SELECT Id, InsightType,AvgEngagementRate,EmailTitlePhrase,EngagementRate,NumberOfDays
                                                             FROM CampaignInsightRationale 
                                                             WHERE CampaignInsightId = :campaignInsightId];
        return campaignRationales;
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
    public static Boolean upsertRecords(String sobjectName, String recordsJSON){
        try{
            System.debug(recordsJSON);
            List<CompositeRequest> requests = new List<CompositeRequest>();
            List<Map<String,String>> records = (List<Map<String,String>>)JSON.deserialize(recordsJSON, List<Map<String,String>>.class);
            
            Integer referenceCounter = 1;
            String sid = getSession();
            for(Map<String,Object> record: records){
                CompositeRequest compReq = new CompositeRequest();
                compReq.method = 'POST';
                
                if(record.containsKey('Id')){
                    compReq.url = '/services/data/' + API_VERSION + '/sobjects/' + sobjectName + '/' + record.get('Id');
                    compReq.method = 'PATCH';
                    record.remove('AccountId');
                    record.remove('AccountName');
                    record.remove('CampaignId');
                    record.remove('Id');
                    record.remove('Name');
                    record.remove('Rationale');
                    record.remove('Title');
                    System.debug(JSON.serialize(record));
                } else {
                    compReq.url = '/services/data/' + API_VERSION + '/sobjects/' + sobjectName;
                    System.debug(JSON.serialize(record));
                }
                
                System.debug(record);
                compReq.body = record;
                compReq.referenceId = 'Insight ' + referenceCounter;
                
                requests.add(compReq);
                referenceCounter++;
            }
            System.debug(JSON.serialize(requests));
            Map<String,Object> compositeRequestBody = new Map<String,Object>();
            compositeRequestBody.put('compositeRequest', requests);
            sendRequest(sid,'/composite','POST', JSON.serialize(compositeRequestBody));
            
            System.debug(records);
            
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean upsertCampaignInsight(String recordJSON){
        
        String sid = getSession();
        CampaignInsight campaignInsight = (CampaignInsight)JSON.deserialize(recordJSON, CampaignInsight.class);
        
        if(campaignInsight.Id != null) {
            sendRequest(sid,'/sobjects/CampaignInsight?_HttpMethod=PATCH','POST', JSON.serialize(campaignInsight));
        }
        else {
            sendRequest(sid,'/sobjects/CampaignInsight','POST', JSON.serialize(campaignInsight));
        }
        
        return true;
    }
    
    @AuraEnabled
    public static Boolean deleteRecord(String sobjectName, String recordId){
        String sid = getSession(); 
        sendRequest(sid, '/sobjects/' + sobjectName + '/' + recordId, 'DELETE', null);
        return true;
    }
    
    @AuraEnabled
    public static Boolean upsertAccountInsights(String insightJSON){
        try{
            String sid = getSession();
            List<CompositeRequest> requests = new List<CompositeRequest>();
            sendRequest(sid,'/composite/tree','POST', JSON.serialize(requests));
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static List<Object> getRecordRecommendations(String sessionId, String targetId, String insightId){
        //APEX does not support RecordRecommendation object
        String recordRecommendationQuery = 'SELECT AcceptCount,ExternalDataSourceId,ExternalId,Id,InsightId,OwnerId,';
        recordRecommendationQuery += 'RecommendationDefinitionId,RecommendationScore,RecommendationStatus,';
        recordRecommendationQuery += 'RecommendationType,ReferenceDate,TargetId,TargetSobjectType ';
        recordRecommendationQuery += 'FROM RecordRecommendation ';
        recordRecommendationQuery += 'WHERE InsightId = \'' + insightId+ '\' ';
        recordRecommendationQuery += 'AND TargetId = \'' + targetId + '\' ';
        recordRecommendationQuery += 'AND TargetSobjectType = \'Account\'';
        
        System.debug(recordRecommendationQuery);
        List<Object> recordRecommendations = Database.query('Select AcceptCount,ExternalDataSourceId,ExternalId,Id,InsightId,OwnerId,RecommendationDefinitionId,RecommendationScore,RecommendationStatus,RecommendationType,ReferenceDate,TargetId,TargetSobjectType FROM RecordRecommendation WHERE InsightId = \'17aB00000008OIKIA2\' AND TargetId = \'001B000000hnP2mIAE\' AND TargetSobjectType = \'Account\'');
        System.debug(recordRecommendations);
        
        return recordRecommendations;
    }
    
    @AuraEnabled
    public static List<Object> getInternalUsers(){
        List<Object> internalUsers = [Select Id, Name From User];
        return internalUsers;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getPicklistOptions(String sobjectName, String fieldName){
        List<Map<String,String>> picklistOptions = new List<Map<String,String>>();
        Schema.sObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectName);
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        
        // Get a map of fields for the SObject
        Map<String,Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry picklistValue: picklistValues) {
            Map<String,String> picklistOption = new Map<String,String>();
            picklistOption.put('label', picklistValue.getLabel());
            picklistOption.put('value', picklistValue.getValue());
            picklistOptions.add(picklistOption);
        }
        
        return picklistOptions;
    }
    
    @AuraEnabled
    public static Object[] getLookup(String sobjectType, String sobjectField, String searchString){
        String likeSearchString = searchString+'%';
        String queryString = 'Select Id, ' + sobjectField;
        queryString += ' From ' + sobjectType;
        queryString += ' Where ' + sobjectField + ' Like \'' + likeSearchString + '\'';
        queryString += ' Limit 5';
        
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static Object httpQuery(String auth, String endpoint, String method){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + auth);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Url.getSalesforceBaseURL().toExternalForm() + endPoint);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }
    
    @AuraEnabled
    public static Object httpRequest(String auth, String endpoint, String method, String data){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setHeader('Authorization', 'Bearer ' + auth);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Url.getSalesforceBaseURL().toExternalForm() + endPoint);
        
        if(data != null) req.setBody(data);
        
        HttpResponse res = http.send(req);
        return res.getBody();
    }
    
    @AuraEnabled
    public static Boolean insertData(List<SObject> records){
        try{
            List<Database.SaveResult> results = Database.insert(records, true);
            
            for(Database.SaveResult result: results){
                if(!result.isSuccess()){
                    System.debug(result.getErrors());
                }
            }
            
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean upsertData(List<SObject> records){
        try{
            List<Database.UpsertResult> results = Database.upsert(records, true);
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean updateData(List<SObject> records){
        try{
            List<Database.SaveResult> results = Database.update(records, true);
            for(Database.SaveResult result: results){
                if(!result.isSuccess()){
                    System.debug(result.getErrors());
                }
            }
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean deleteData(List<Id> recordIds){
        try{
            List<Database.DeleteResult> results = Database.delete(recordIds, true);
            return true;
        } catch(Exception e){
            return false;
        }
    }
    
    public class CompositeRequest {
        @AuraEnabled
        public String method;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String referenceId;
        @AuraEnabled
        public Map<String,Object> body;
        
        public CompositeRequest(){}
        public CompositeRequest(String m, String u, String r, Map<String,Object> b){
            this.method = m;
            this.url = u;
            this.referenceId = r;
            this.body = b;
        }
    }
}