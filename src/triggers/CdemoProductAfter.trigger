trigger CdemoProductAfter on Product2 (after insert, after update) {
    if(System.isBatch()) return;
    if(trigger.isAfter && trigger.new.size()<50){
        ProductUtility.AfterTriggerProcessor(Trigger.new, Trigger.isInsert);
    }
}