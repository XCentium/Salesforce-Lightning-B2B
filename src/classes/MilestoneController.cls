public with sharing class MilestoneController {
    @AuraEnabled
    public static List<CaseMilestone> getCurrentMilestones(Id caseId) {
        // Perform isAccessible() check here
        return [SELECT Id, MilestoneType.Name, CompletionDate, IsViolated, IsCompleted, TimeRemainingInMins, TimeSinceTargetInMins, TargetDate
                FROM CaseMilestone 
                WHERE CaseId=:caseId AND IsCompleted=False
                ORDER BY CompletionDate ASC];
    }
    @AuraEnabled    
    public static List<CaseMilestone> getAllMilestones(Id caseId) {
        // Perform isAccessible() check here
        return [SELECT Id, MilestoneType.Name, CompletionDate, IsViolated, IsCompleted, TimeRemainingInMins, TimeSinceTargetInMins, TargetDate
                FROM CaseMilestone 
                WHERE CaseId=:caseId
                ORDER BY CompletionDate ASC];
    }
}