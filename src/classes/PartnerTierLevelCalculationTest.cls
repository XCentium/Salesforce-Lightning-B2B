@isTest
public class PartnerTierLevelCalculationTest {

    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Partner_Level__c silver = new Partner_Level__c(Name = 'Silver');
        silver.Minimum_Point__c = 50;
        insert silver;

        Partner_Level__c bronze = new Partner_Level__c(Name = 'Bronze');
        bronze.Minimum_Point__c = 0;
        bronze.Next_Level__c = silver.Id;
        insert bronze;

        Partner_Activity_Type__c type1 = new Partner_Activity_Type__c(Name = 'Type 1');
        type1.Points__c = 20;
        insert type1;

        Partner_Activity_Type__c type2 = new Partner_Activity_Type__c(Name = 'Type 2');
        type2.Points__c = 10;
        insert type2;

        Partner_Level_Requirement__c requirement = new Partner_Level_Requirement__c();
        requirement.Partner_Level__c = silver.Id;
        requirement.Partner_Activity_Type__c = type2.Id;
        requirement.Minimum_Point_Requirement__c = 20;
        insert requirement;

        Partner_Activity__c activity1 = new Partner_Activity__c();
        activity1.Activity_Date__c = Date.today();
        activity1.Partner_Activity_Type__c = type1.Id;
        activity1.Partner_Account__c = account.Id;
        insert activity1;

        Partner_Activity__c activity2 = new Partner_Activity__c();
        activity2.Activity_Date__c = Date.today();
        activity2.Partner_Activity_Type__c = type2.Id;
        activity2.Partner_Account__c = account.Id;
        insert activity2;
    }

    @isTest
    static void getAllAccountsTest() {
        Account account = [SELECT Id FROM Account];
        Partner_Level__c bronze = [SELECT Id FROM Partner_Level__c WHERE Name = 'Bronze'];

        List<Account> accounts = PartnerTierLevelCalculation.getAllAccounts(new List<Id> {account.Id});
        System.assertEquals(1, accounts.size());

        System.assertEquals(30, accounts[0].Total_Partner_Points__c);
        System.assertEquals(bronze.Id, accounts[0].Current_Partner_Level__c);
    }

    @isTest
    static void getAllPartnerLevelsTest() {
        List<Partner_Level__c> levels = PartnerTierLevelCalculation.getAllPartnerLevels();
        System.assertEquals(2, levels.size());
    }

    @isTest
    static void getPointTypeMapTest() {
        List<Partner_Activity__c> activities = [SELECT Partner_Activity_Type__c, Points_Awarded__c FROM Partner_Activity__c];
        Partner_Activity_Type__c type1 = [SELECT Id FROM Partner_Activity_Type__c WHERE Name = 'Type 1'];
        Partner_Activity_Type__c type2 = [SELECT Id FROM Partner_Activity_Type__c WHERE Name = 'Type 2'];

        Map<Id,Integer> pointTypeMap = PartnerTierLevelCalculation.getPointTypeMap(activities);
        System.assertEquals(2, pointTypeMap.size());
        System.assertEquals(20, pointTypeMap.get(type1.Id));
        System.assertEquals(10, pointTypeMap.get(type2.Id));
    }

    @isTest
    static void UpdatePartnerTierLevelTest() {
        Account account = [SELECT Id FROM Account];
        Partner_Activity_Type__c type1 = [SELECT Id FROM Partner_Activity_Type__c WHERE Name = 'Type 1'];
        Partner_Activity_Type__c type2 = [SELECT Id FROM Partner_Activity_Type__c WHERE Name = 'Type 2'];
        Partner_Level__c bronze = [SELECT Id FROM Partner_Level__c WHERE Name = 'Bronze'];
        Partner_Level__c silver = [SELECT Id FROM Partner_Level__c WHERE Name = 'Silver'];

        Partner_Activity__c activity = new Partner_Activity__c();
        activity.Activity_Date__c = Date.today();
        activity.Partner_Activity_Type__c = type1.Id;
        activity.Partner_Account__c = account.Id;
        insert activity;

        PartnerTierLevelCalculation.UpdatePartnerTierLevel(new List<Id> {account.Id});

        account = [SELECT Id, Current_Partner_Level__c, Pending_Level__c FROM Account];
        System.assertEquals(bronze.Id, account.Current_Partner_Level__c);
        System.assert(account.Pending_Level__c == null);

        Partner_Activity__c activity2 = new Partner_Activity__c();
        activity2.Activity_Date__c = Date.today();
        activity2.Partner_Activity_Type__c = type2.Id;
        activity2.Partner_Account__c = account.Id;
        insert activity2;


        account = [SELECT Id, Current_Partner_Level__c, Pending_Level__c FROM Account];
        System.assertEquals(silver.Id, account.Current_Partner_Level__c);
        System.assert(account.Pending_Level__c == null);

        delete activity;


        account = [SELECT Id, Current_Partner_Level__c, Pending_Level__c FROM Account];
        System.assertEquals(silver.Id, account.Current_Partner_Level__c);
        System.assertEquals(bronze.Id, account.Pending_Level__c);

    }
}