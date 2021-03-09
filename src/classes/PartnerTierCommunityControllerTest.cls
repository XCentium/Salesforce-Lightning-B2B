/**
 * Created by Cynthia on 6/1/2017.
 */
@isTest
public with sharing class PartnerTierCommunityControllerTest {

    @testSetup
    static void setup() {

        User communityUser = new User();
        communityUser.FirstName = 'Test';
        communityUser.LastName = 'Test';

        Id profileId = [select id from profile where name='Customer Community User'].id;

        communityUser.Username = 'test@test.test';
        communityUser.Email = 'test@test.test';
        communityUser.Alias = 'ttest';
        communityUser.CommunityNickname = 'ttest';
        communityUser.TimeZoneSidKey = UserInfo.getTimeZone().getID();
        communityUser.LocaleSidKey = UserInfo.getLocale();
        communityUser.EmailEncodingKey = 'ISO-8859-1';
        communityUser.ProfileId = profileId;
        communityUser.LanguageLocaleKey = UserInfo.getLanguage();

        Account account = new Account();
        account.Name = 'Test Account';
        account.OwnerId = UserInfo.getUserId();

        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = communityUser.FirstName;
        contact.LastName = communityUser.LastName;

        insert contact;

        communityUser.ContactId = contact.Id;
        insert communityUser;
    }

    static User getCommunityUser() {
        return [SELECT Id, ContactId, AccountId from User WHERE FirstName = 'Test' AND LastName = 'Test'];
    }

    @isTest
    static void getPartnerAccountTest() {
        User partnerUser = getCommunityUser();
        System.runAs(partnerUser) {
            Account partner = PartnerTierCommunityController.getPartnerAccount();
            System.assert(partner != null);
            System.assertEquals('Test Account', partner.Name);

            Map<Id, Integer> pointsMap = PartnerTierCommunityController.getAccountPointsByType(partner.Id);
            System.assert(pointsMap.size() == 0);
        }
    }

    @isTest
    static void getLevelRequirementsTest() {
        Partner_Level__c silver = new Partner_Level__c(Name = 'Silver');
        silver.Minimum_Point__c = 50;
        insert silver;

        Partner_Activity_Type__c type1 = new Partner_Activity_Type__c(Name = 'Type 1');
        type1.Points__c = 20;
        insert type1;

        Partner_Level_Requirement__c requirement = new Partner_Level_Requirement__c();
        requirement.Partner_Level__c = silver.Id;
        requirement.Partner_Activity_Type__c = type1.Id;
        requirement.Minimum_Point_Requirement__c = 20;
        insert requirement;

        List<Partner_Level_Requirement__c> requirements = PartnerTierCommunityController.getLevelRequirements(silver.Id);
        System.assertEquals(1, requirements.size());
    }
}