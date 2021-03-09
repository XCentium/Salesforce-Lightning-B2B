public class AccountInsightsController {

    @AuraEnabled
    public static List<Account_Insight_Article__c> findAll(String accId) {

        List<Account_Insight_Article__c> articles = new List<Account_Insight_Article__c>();

        try {
          articles = [SELECT Article_Text__c,Id,Name,News_Agency__c, InsightGroup__r.Id,
                             InsightGroup__r.Annual_Revenue_Big__c, Order__c, 
                             InsightGroup__r.Annual_Revenue_Small__c,
                             InsightGroup__r.CreatedDate,InsightGroup__r.Employees_Big__c,
                             InsightGroup__r.Employees_Small__c,InsightGroup__r.Name,
                             InsightGroup__r.Net_Income__c, InsightGroup__r.RelatedAccount__c
                      FROM   Account_Insight_Article__c
                      WHERE  InsightGroup__r.RelatedAccount__c =: accId];

        } catch (Exception e) {
          System.Debug('Account: ' + accId + ' not associated with any articles');
        }
        return articles;
    }

}