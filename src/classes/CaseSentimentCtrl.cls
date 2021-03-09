public class CaseSentimentCtrl {

	@AuraEnabled
    public static scrubDemo_Interaction_Analysis__c getCaseAnalysis(String caseId){
        scrubDemo_Interaction_Analysis__c analysis = [SELECT Id, Prediction_Conf_1__c, Prediction_Conf_2__c, Prediction_Conf_3__c, 
                                                      Prediction_Result_1__c, Prediction_Result_2__c, Prediction_Result_3__c
                                                      FROM scrubDemo_Interaction_Analysis__c
                                                      WHERE Case__c = :caseId
                                                      ORDER BY CreatedDate DESC
                                                      LIMIT 1];
        
        return analysis;
    }
}