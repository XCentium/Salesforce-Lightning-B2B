trigger CdemoProductBefore on Product2 (before insert) {
    
    if(!Test.isRunningTest() && trigger.new.size()<50){
        ProductUtility.BeforeTriggerProcessor(trigger.new);
    }
}