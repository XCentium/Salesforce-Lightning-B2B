trigger trigger_SBQuote on SBQQ__Quote__c (after insert, after update) {
    if(!System.isBatch()) return;
    if(trigger.isAfter && trigger.isInsert){

        SBQQ__Quote__c []newQuote = Trigger.new;
        blogic_Quote_CreateLineItems.InsertAfter(newQuote);
        }   

    if(trigger.isAfter && trigger.isUpdate){

        SBQQ__Quote__c []newQuote = Trigger.new;
        list<SBQQ__Quote__c> newQuoteList = new list<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q : trigger.new){
            if(q.SBQQ__Status__c == 'Accepted' && trigger.oldMap.get(q.Id).SBQQ__Status__c != 'Accepted'){
                newQuoteList.add(q);
            }
        }
        if(newQuoteList.size() > 0){
          blogic_Quote_CreateLineItems.UpdateAfter(newQuoteList);
        }
        }   


}



/*trigger trigger_SBQuote on SBQQ__Quote__c (after insert, after update) {
     
    if(trigger.isAfter && trigger.isInsert){

        SBQQ__Quote__c []newQuote = Trigger.new;
        blogic_Quote_CreateLineItems.InsertAfter(newQuote);
        }   
}*/