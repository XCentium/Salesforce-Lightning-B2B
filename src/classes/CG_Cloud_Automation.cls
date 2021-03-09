public class CG_Cloud_Automation {
	
    /** Generate Visits for CG Cloud Events **/
    @AuraEnabled
    public static List<ActionPlan> getAPs() {
        ActionPlan[] aplans = [SELECT Id,Name,ActionPlanTemplateVersionId FROM ActionPlan WHERE isTemplate__c = true]; 
        return aplans;
    } 
    /** Generate Visits for CG Cloud Events **/
    @AuraEnabled
    public static List<Visit> generateVisits(Integer totalVisits, String AssignedId,String ActionPlan,String RetailStoreId) {
        String UserId = AssignedId;
        String StoreId = RetailStoreId; 
		String PlanTemplate = ActionPlan;
        String ActionPlanType = [SELECT ActionPlanType FROM ActionPlanTemplate LIMIT 1].ActionPlanType;
       
        /* Create Records */
        Visit[] visits = new List<Visit>();
        ActionPlan[] aplans = new List<ActionPlan>();
        
        try {
            for(Integer i = 0; i < totalVisits; i++) {
                Integer hourstoadd = 1 + i;
                Integer endHoursToAdd = 2 + i;
                
                Visit v = new Visit (
                    PlannedVisitStartTime = DateTime.now().AddHours(hourstoadd),
                    PlannedVisitEndTime = DateTime.now().AddHours(endHoursToAdd),
                    InstructionDescription = '',
                    Status = 'Planned',
                    VisitPriority = 'High',
                    VisitorId = UserId,
                    PlaceId = StoreId
                );
                visits.add(v);
            }
    		insert visits;
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }

        return [SELECT Id,Name,PlannedVisitStartTime,PlannedVisitEndTime,PlaceId, Status  FROM Visit WHERE CreatedDate > :Datetime.now().addMinutes(-1)];
    }
    /** Generate Visits for CG Cloud Events **/
    @AuraEnabled
    public static void createActionPlans(String VisitId,String ActionPlan) {
        ActionPlan[] aplans = new List<ActionPlan>();
        String PlanTemplate = ActionPlan;
        String vId = VisitId;
        String ActionPlanType = [SELECT ActionPlanType FROM ActionPlanTemplate LIMIT 1].ActionPlanType;

        ActionPlan ap = new ActionPlan (
            Name = 'Visit Plan',
            StartDate = Date.today(),
            ActionPlanTemplateVersionId = PlanTemplate,
            TargetId = vId,
            ActionPlanState ='Not Started',
            ActionPlanType = 'Retail' 
        );
        aplans.add(ap);
        
        insert aplans;   

    }
    /** Generate Visits for CG Cloud Events **/
    @AuraEnabled
    public static String getRetailStoreId(String recid) {
		String accName = [Select Name FROM Account Where id = :recid].Name;
        String StoreId = [SELECT ID From RetailStore WHere Name = :accName].Id;
        Return StoreId;
    }
    /** Generate Visits for CG Cloud Events **/
    @AuraEnabled
    public static List<Visit> CreateVisit( String AssignedId,String ActionPlan,String RetailStoreId, DateTime visitDate, String instructions) {
		String PlanTemplate = ActionPlan;
        String ActionPlanType = [SELECT ActionPlanType FROM ActionPlanTemplate LIMIT 1].ActionPlanType;
       
        /* Create Records */
        Visit[] visits = new List<Visit>();
        ActionPlan[] aplans = new List<ActionPlan>();
        
        try {
            Visit v = new Visit (
                PlannedVisitStartTime = visitDate,
                PlannedVisitEndTime = visitDate.AddHours(1),
                InstructionDescription = instructions,
                Status = 'Planned',
                VisitPriority = 'High',
                VisitorId = AssignedId,
                PlaceId = RetailStoreId
            );
            visits.add(v);
    		insert visits;  
            
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }

        return [SELECT Id,Name,PlannedVisitStartTime,PlannedVisitEndTime,PlaceId, Status  FROM Visit WHERE CreatedDate > :Datetime.now().addMinutes(-1)];
    }
}