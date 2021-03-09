public class scrubDemo_IAVisController {

    @AuraEnabled
    public static List<scrubDemo_Interaction_Analysis__c> getIAs (string caseID){
        system.debug('CaseID : ' + caseID);
        return [select id, createdDate, prediction_value__c, Prediction_Conf_1__c, Prediction_Result_1__c, Prediction_Conf_2__c, Prediction_Result_2__c, Analyzed_Object__c, Analyzed_Object_ID__c from scrubDemo_Interaction_Analysis__c Where Case__c = :CaseID order by CreatedDate Asc];
    }
}