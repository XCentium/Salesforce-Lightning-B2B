public class PartnerTierLevelCalculation {
	@InvocableMethod(label='Update Partner Tier Level' description='Evaluate the points and activities of accounts and update their partner level information correspondingly')
    public static void UpdatePartnerTierLevel(List<Id> AccountId) {
        
        List<Account> accounts = getAllAccounts(AccountId);
        
        List<Partner_Level__c> partnerLevels = getAllPartnerLevels();
        
        List<Account> accountsToBeUpdated = new List<Account>();
        for (Account account : accounts) {
            List<Partner_Activity__c> activities = account.Partner_Activities__r;
            Map<Id,Integer> pointsInEachType = getPointTypeMap(activities);
            Partner_Level__c newLevel = getNewLevel(account, pointsInEachType, partnerLevels);
            if (newLevel.Id != account.Current_Partner_Level__c) {
                if (newLevel.Minimum_Point__c > account.Current_Partner_Level__r.Minimum_Point__c || account.Current_Partner_Level__c == null) {
                    // leveling up
                    account.Pending_Level__c = null;
                    account.Current_Partner_Level__c = newLevel.Id;
                } else {
                    // level down
                	account.Pending_Level__c = newLevel.Id;
                }
                accountsToBeUpdated.add(account);
            } else {
                if (account.Pending_Level__c != null) {
                	account.Pending_Level__c = null;
                    accountsToBeUpdated.add(account);
                }
            }
        }
        update accountsToBeUpdated;
    }
    
    public static List<Account> getAllAccounts(List<Id> AccountIds) {
        return [
            SELECT Id, 
            Total_Partner_Points__c, 
            Current_Partner_Level__c,
            Current_Partner_Level__r.Minimum_Point__c,
            Pending_Level__c,
            (
                SELECT 
                Partner_Activity_Type__c, 
                Points_Awarded__c
                FROM Partner_Activities__r
            ) 
            FROM Account
            WHERE Id IN :AccountIds
        ];
    }
    
    public static List<Partner_Level__c> getAllPartnerLevels() {
        return [
          	SELECT Id, 
            Minimum_Point__c, 
            (
                SELECT
                Partner_Activity_Type__c,
                Minimum_Point_Requirement__c
                FROM
                Partner_Level_Requirements__r
            )
            FROM Partner_Level__c
            ORDER BY Minimum_Point__c DESC
        ];
    }
    
    public static Map<Id,Integer> getPointTypeMap (List<Partner_Activity__c> activities) {
        Map<Id,Integer> pointsInEachType = new Map<Id,Integer>();
        for (Partner_Activity__c activity : activities) {
            if (!pointsInEachType.containsKey(activity.Partner_Activity_Type__c)) {
                pointsInEachType.put(activity.Partner_Activity_Type__c, 0);
            }
            Integer newValue = pointsInEachType.get(activity.Partner_Activity_Type__c);
            pointsInEachType.put(activity.Partner_Activity_Type__c, newValue + Integer.valueof(activity.Points_Awarded__c));
        }
        return pointsInEachType;
    }
    
    public static Partner_Level__c getNewLevel(Account account, Map<Id,Integer> pointsInEachType, List<Partner_Level__c> partnerLevels) {
        for (Partner_Level__c level : partnerLevels) {
            if (account.Total_Partner_Points__c < level.Minimum_Point__c) {
                continue;
            }
            boolean requirementsFulfilled = true;
            // check if fulfill each requirement
            for (Partner_Level_Requirement__c requirement : level.Partner_Level_Requirements__r) {
                if (!pointsInEachType.containsKey(requirement.Partner_Activity_Type__c) ||
                    pointsInEachType.get(requirement.Partner_Activity_Type__c) < requirement.Minimum_Point_Requirement__c ) {
                        requirementsFulfilled = false;
                        break;
                    }
            }
            if (requirementsFulfilled) {
                return level;
            }
        }
        return null;
    }
}