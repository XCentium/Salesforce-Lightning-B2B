trigger SmartFridgeReadingReceived on Smart_Fridge_Reading__e (after insert) {
List<SmartFridge__c> records = new List<SmartFridge__c>();
for (Smart_Fridge_Reading__e event : Trigger.New) {
    SmartFridge__c record = new SmartFridge__c();
    record.deviceId__c = event.deviceId__c;
    record.temperature__c = event.temperature__c;
    record.humidity__c = event.humidity__c;
    record.door__c = event.door__c;
    record.ts__c = event.ts__c;
    records.add(record);
}
insert records;
}