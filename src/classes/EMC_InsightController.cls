global class EMC_InsightController {

    global EMC_InsightController(){}
    global EMC_InsightController(EMC_Controller emcCtrl){}
    
    @RemoteAction@AuraEnabled
    global static List<Object> getInsightTypes(String sSupportedInsightTypes){
        List<String> supportedInsightTypes = (List<String>)JSON.deserialize(sSupportedInsightTypes, List<String>.class);
        List<InsightType> insightTypes = [Select Id, MasterLabel, Description, DeveloperName From InsightType Where DeveloperName In :supportedInsightTypes Order By MasterLabel ASC NULLS First];
        return insightTypes;
    }
    
    @RemoteAction@AuraEnabled
    global static List<Object> getInsights(String insightTypeId){
        List<Insight> insights = [Select Id, SupportingData, Parent.Name, InsightType.DeveloperName, InsightType.MasterLabel, (Select Id, Owner.Id, Owner.Name From InsightUserValues) From Insight Where InsightTypeId = :insightTypeId];
        return insights;
    }
	
    @RemoteAction@AuraEnabled
	global static List<Object> getLookupData(String displayField, String lookupObject,  String lookupField, String lookupString){
	    String queryString = 'Select Id, ' + displayField + ' From ' + lookupObject + ' Where ' + lookupField + ' Like \'' + lookupString + '%\' Limit 5';
	    return database.query(queryString);
	}
	
	
    @RemoteAction@AuraEnabled
    global static List<User> getUsers(){
        return [Select Id, Name From User Where IsActive = true And UserType = 'Standard' Order By Name ASC];
    }
	
    @RemoteAction@AuraEnabled
    global static List<Object> generateInsights(String payload){
        List<Insight> newInsights = (List<Insight>)JSON.deserialize(payload, List<Insight>.class);
        insert newInsights;
        return newInsights;
    }
    
    @RemoteAction@AuraEnabled
    global static Boolean deleteInsight(String insightId){
        Insight dInsight = new Insight();
        dInsight.Id = insightId;
        delete dInsight;
        return true;
    }
    
    @RemoteAction@AuraEnabled
    global static Boolean deleteInsightUserValue(String insightUserValueId){
        InsightUserValue dInsightUserValue = new InsightUserValue();
        dInsightUserValue.Id = insightUserValueId;
        delete dInsightUserValue;
        return true;
    }
    
    @RemoteAction@AuraEnabled
    global static Boolean deleteInsightUserValues(String insightId){
        delete [Select Id From InsightUserValue Where InsightId = :insightId];
        return true;
    }
    
    
    @RemoteAction@AuraEnabled
    global static Object assignInsight(String sInsightUserValue){
        InsightUserValue insightAssignment = (InsightUserValue)JSON.deserialize(sInsightUserValue, InsightUserValue.class);
        insert insightAssignment;
        return insightAssignment;
    }
    
    @RemoteAction@AuraEnabled
    global static List<Object> assignInsights(String sInsightUserValues){
        List<InsightUserValue> insightAssignments = (List<InsightUserValue>)JSON.deserialize(sInsightUserValues, List<InsightUserValue>.class);
        insert insightAssignments;
        return insightAssignments;
    }
}