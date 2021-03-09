@isTest
public class ReferralSubmitTest {

    @isTest static void testComponentApex() {
        Referral__c ref = new Referral__c(); 
        ref.First_Name__c = 'Shane';
        ref.Last_Name__c = 'McLaughlin';
        string serialized = JSON.serialize(ref);
        
        Referral__c newRef = ReferralSubmit.saveRef(serialized);
        system.assertEquals(newRef, null);
            
    }
    
    //trigger test
    @isTest static void testTrigger(){
        Referral__c ref = new Referral__c(); 
        ref.First_Name__c = 'Shane';
        ref.Last_Name__c = 'McLaughlin';
        ref.Email__c = 'shane.mclaughlin@salesforce.com';
        insert ref;
    }
    
     
}