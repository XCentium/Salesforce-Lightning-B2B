public class SCLeadHighlightController {
    public Lead l {get;set;}
    public SCLeadHighlightController(ApexPages.StandardController controller) {
        l = [SELECT Lead_Total__c, Name, Status, LeadSource, Know_Decision_Maker__c, Project_Defined__c, Region__c, Days_Since_Last_Activity__c, Phone, Email,
                Has_Budget__c, Title, Company FROM Lead WHERE id =: controller.getId()];
    }

}