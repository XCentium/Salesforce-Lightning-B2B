public class QSR_DailyPlannerController {
	@AuraEnabled
    public static string createDailyPlanner(Boolean allFMSArrived, Boolean deploymentChartsPosted, String shift, String weather, Decimal transactionActual, Decimal transactionGoal){
        Daily_Planner__c planner = new Daily_Planner__c();
        planner.All_FMs_Arrived__c = allFMSArrived;
        planner.Date_Completed__c = DateTime.now();
        planner.Deployment_Chart_Posted__c = deploymentChartsPosted;
        planner.PIC__c = 'Alicia Cruz';
        planner.Shift__c = shift;
        planner.Weather__c = weather;
        planner.Transaction_Actual__c = transactionActual;
        planner.Transaction_Goal__c	= transactionGoal;

        insert planner;
        return planner.Id;
    }
}