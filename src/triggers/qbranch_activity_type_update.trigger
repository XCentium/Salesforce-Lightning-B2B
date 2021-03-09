trigger qbranch_activity_type_update on Task (before insert, before update) {
 if(System.isBatch()) return;
  try{
        for(Task t: Trigger.new){
            t.Type__c = t.Type; 
        } 
    }
    catch(Exception e){
    System.debug('Trigger exception: '+e);  
    }
}