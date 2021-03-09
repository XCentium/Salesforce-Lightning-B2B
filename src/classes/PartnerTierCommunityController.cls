/**
 * Created by cxu on 31/05/2017.
 */

public with sharing class PartnerTierCommunityController {

    @AuraEnabled
    public static Account getPartnerAccount() {
        String userId = UserInfo.getUserId();
        User user = [SELECT AccountId FROM User WHERE Id = :userId];

        if (user.AccountId != null) {
            Account account =
            [
                    SELECT
                    Id,
                    Name,
                    PhotoUrl,
                    Total_Partner_Points__c,
                    Points_to_Next_Level__c,
                    Pending_Level__c,
                    Pending_Level__r.Name,
                    Current_Partner_Level__r.Name,
                    Current_Partner_Level__r.Icon_URL__c,
                    Current_Partner_Level__r.Benefits__c,
                    Current_Partner_Level__r.Next_Level__r.Name,
                    Current_Partner_Level__r.Next_Level__r.Benefits__c,
                    Current_Partner_Level__r.Next_Level__r.Minimum_Point__c, 
                    (
                            SELECT
                                    Activity_Date__c,
                                    Partner_Activity_Type__r.Name,
                                    Partner_Activity_Type__r.Category__c,
                                    Partner_Activity_Type__r.Category_Icon_URL__c,
                                    Description__c,
                                    Points_Awarded__c
                            FROM Partner_Activities__r
                            ORDER BY Activity_Date__c DESC
                            LIMIT 15
                    )
                    FROM Account
                    WHERE Id =: user.AccountId
            ];
            return account;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<Partner_Level_Requirement__c> getLevelRequirements(String levelId) {
        return [
                SELECT
                        Id,
                        Name,
                		Partner_Activity_Type__c,
                        Partner_Activity_Type__r.Name,
                        Minimum_Point_Requirement__c
                FROM Partner_Level_Requirement__c
                WHERE Partner_Level__c = :levelId
        ];
    }

    @AuraEnabled
    public static Map<Id, Integer> getAccountPointsByType (String accountId) {
        List<Partner_Activity__c> activities = [SELECT Partner_Activity_Type__c, Points_Awarded__c FROM Partner_Activity__c WHERE Partner_Account__c =: accountId];

        return PartnerTierLevelCalculation.getPointTypeMap(activities);

    }

    @AuraEnabled
    public static List<Partner_Activity_Type__c> getFeaturedActivityTypes() {
        return
        [
                SELECT Id, Name, Category__c, Category_Icon_URL__c, Points__c FROM Partner_Activity_Type__c WHERE Featured__c = true
        ];
    }
}