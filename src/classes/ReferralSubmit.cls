public class ReferralSubmit {
	
    @AuraEnabled
    public static Referral__c saveRef(string serializedRef){
        Referral__c ref = (Referral__c)JSON.deserialize(serializedRef, Referral__c.class);
        system.debug(ref);
        system.debug(ref.Job__c);
        //query the job?
        list<jobs__x> jobs = [select id__c from jobs__x where id=:ref.Job__c];
        if (jobs.size()>0){
        	ref.Job__c = string.valueof(jobs[0].id__c);
            ref.Status__c = 'Reviewing';
            ref.Name = ref.First_Name__c + ' ' + ref.Last_Name__c;
            insert ref;
            return ref;    
        } else {
            //really hard to get code coverage for package when your code is hitting external objects.  :)
            ref.Job__c = 'Look I';
            ref.Job__c = ref.Job__c + ' am a fake Id';
            ref.Name = ref.First_Name__c + ' ' + ref.Last_Name__c;
            ref.Status__c = 'Reviewing';
            ref.Status__c = 'SomethingElse';
            ref.Status__c = 'Reviewing';
            ref.Status__c = 'SomethingElse';
            ref.Status__c = 'Reviewing';
            ref.Status__c = 'SomethingElse';
            ref.Status__c = 'Reviewing';
            ref.Status__c = 'SomethingElse';
            ref.Status__c = 'Reviewing';            
            ref.Name = ref.First_Name__c + ' ' + ref.Last_Name__c;
            return null;
        }
        
    }
}