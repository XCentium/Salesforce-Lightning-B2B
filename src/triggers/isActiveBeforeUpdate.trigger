trigger isActiveBeforeUpdate on openCTIconfig__c (before update) {
    if(!System.isBatch()) return;
    System.debug('coshea : starting the before update');

    List<openCTIconfig__c> myListToUpdate = new List<openCTIconfig__c>();

    for(openCTIconfig__c cti : trigger.new) {
        if(cti.isActive__c == true) {
            myListToUpdate = [SELECT Id, Account__c, AccountName__c, Contact__c, ContactName__c, Title__c, Phone__c, isActive__c from openCTIconfig__c WHERE isActive__c=:true];
            for(openCTIconfig__c tmp : myListToUpdate) {
                tmp.isActive__c = false;
            }
        }
    }

    if(myListToUpdate.size() > 0) {
        update myListToUpdate;
    }
}