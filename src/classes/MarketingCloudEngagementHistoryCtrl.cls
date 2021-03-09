public class MarketingCloudEngagementHistoryCtrl  {
    
    @AuraEnabled
    public static customSettingDetails getCustomSettingsData(String customSettingName){
       
        CustomSettingDetails csd = new CustomSettingDetails();
        String soql='';
        if(customSettingName == 'Journeys'){
            soql = 'select Channel__c, Date_Sent__c , Name_of_Communication__c from Journeys__c';
            csd.colHeaders = new List<string>{'Name of Communication', 'Channel', 'Date Sent'};
            csd.records.addAll(Database.query(soql));
        }else if (customSettingName == 'Individual Email Results'){
            soql= 'select Bounced__c, Email_Name__c, Date_Sent__c, Opened__c, Clicked__c from Individual_Email_Results__c ';
            csd.colHeaders = new List<string>{'Email Name', 'Date Sent', 'Opened', 'Clicked', 'Bounced'};
            csd.records.addAll(Database.query(soql)); 
        }
        system.debug('csd$$$$$' + csd);
       return csd;
    }
    
    public class CustomSettingDetails{
        @AuraEnabled
        public List<String> colHeaders{get;set;}
        @AuraEnabled
        public List<Sobject> records{get;set;}
        public customSettingDetails(){
            records = new List<Sobject>();
        }
    }
}