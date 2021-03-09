public class EMC_InsightsCtrl {

    @AuraEnabled
    public static Object[] getInsightTypes(String parentObject){
        return [Select Id, MasterLabel, DeveloperName, DefaultTrendType 
                From InsightType 
                Where ParentType = :parentObject];
    }
    
    @AuraEnabled
    public static Object[] getInsights(String parentId){
        return [Select Id,AcceptanceStatus,CustomTitle,EmailMatchingEmailAddress,
                InsightTypeId, InsightType.DeveloperName, InsightType.MasterLabel,Name,ParentId,Rationale,Score,Status,SupportingData,TrendType 
                From Insight 
                Where ParentId = :parentId];
    }
    
	@AuraEnabled
    public static Object upsertInsight(Insight insight){
        upsert insight;
        return insight;
    }
    
    @AuraEnabled
    public static Object[] getInsightUserValues(String insightId){
        String queryString = 'Select Id, OwnerId, Owner.Name, InsightId';
        queryString += ' From InsightUserValue';
        queryString += ' Where InsightId =  \'' + insightId + '\'';
        
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static Object upsertInsightUserValue(SObject insightUserValue){
        upsert insightUserValue;
        return insightUserValue;
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
    public static Object getRecord(String sobjectType, String sobjectField, String recordId){
        String queryString = 'Select Id, ' + sobjectField;
        queryString += ' From ' + sobjectType;
        queryString += ' Where Id =  \'' + recordId + '\'';
        queryString += ' Limit 1';
        
        return Database.query(queryString);
    }
    
    @AuraEnabled
    public static Boolean deleteRecord(SObject record){
        Database.deleteAsync(record);
        return true;
    }
}