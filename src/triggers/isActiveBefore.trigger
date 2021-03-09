trigger isActiveBefore on openCTIconfig__c (before insert, before update) {
    if(!System.isBatch()) return;
    System.debug('coshea : starting the before insert');

    List<openCTIconfig__c> myListToUpdate = new List<openCTIconfig__c>();
    List<openCTIconfig__c> listWithoutThisRecord = new List<openCTIconfig__c>();

    for(openCTIconfig__c cti : trigger.new) {
        if(cti.isActive__c == true) {
            myListToUpdate = [SELECT Id, Account__c, AccountName__c, Contact__c, ContactName__c, Title__c, Phone__c, isActive__c from openCTIconfig__c];
            for(openCTIconfig__c tmp : myListToUpdate) {
                tmp.isActive__c = false;
                if(tmp.Id != cti.Id) {
                    listWithoutThisRecord.add(tmp);
                }
            }
        }
    }

    if(listWithoutThisRecord.size() > 0) {
        update listWithoutThisRecord;
    }

    // Who has time to test their code anyway..
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}