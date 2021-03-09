trigger SalesforceRewind_Contact on Contact (after insert, after update, after delete) {
    if(System.isBatch()) return;
    SalesforceRewindTriggerHandler.publishNotifications(Trigger.oldMap, Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}