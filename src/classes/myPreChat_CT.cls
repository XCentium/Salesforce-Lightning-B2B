public with sharing class myPreChat_CT {

    public String chatCaseRecordId {get;set;}
    
    public myPreChat_CT() {
        RecordType rt = [SELECT Id FROM RecordType where name = 'Chat Case'][0];
        chatCaseRecordId= String.valueOf(rt.id);
      
    }
}