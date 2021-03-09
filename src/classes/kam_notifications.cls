public with sharing class kam_notifications {
        @AuraEnabled(Cacheable=true)
        public static KAM_Notification__c[] getAllNotifications() {
            return [SELECT Id, Name, Priority__c,Start_Date__c,End_Date__c,Description__c,Notification_Type__c,Notification_origin__c,Einstein_Score__c
                FROM KAM_Notification__c WHERE remind_me__c = false ORDER BY End_Date__c];
        }
    
        @AuraEnabled(Cacheable=true)
        public static KAM_Notification__c[] getRemindMe(String temp) {
            // upd Idd
            return [SELECT Id, Name, Priority__c,Start_Date__c,End_Date__c,Description__c,Notification_Type__c,Notification_origin__c,Einstein_Score__c
                FROM KAM_Notification__c WHERE remind_me__c = true ORDER BY End_Date__c];
        }

        @AuraEnabled
        public static KAM_Notification__c[] updRemindMe(String idd) {
            system.debug('in there'+idd);
            KAM_Notification__c mtn = [SELECT Id, Name,remind_me__c, Priority__c,Start_Date__c,End_Date__c,Description__c,Notification_Type__c,Notification_origin__c,Einstein_Score__c
            FROM KAM_Notification__c WHERE Id =: idd Limit 1];
            mtn.remind_me__c = true;
            update mtn;

            return [SELECT Id, Name, Priority__c,Start_Date__c,End_Date__c,Notification_Type__c,Notification_origin__c,Einstein_Score__c,Description__c
                FROM KAM_Notification__c WHERE remind_me__c = false ORDER BY End_Date__c];
        }
}